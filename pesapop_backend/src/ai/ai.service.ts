import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { PrismaService } from '../common/prisma/prisma.service';
import { AnalyticsService } from '../analytics/analytics.service';
import * as dayjs from 'dayjs';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private openai: OpenAI;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
    private analytics: AnalyticsService,
  ) {
    this.openai = new OpenAI({ apiKey: this.config.get('OPENAI_API_KEY') });
  }

  async chat(businessId: string, messages: Array<{ role: 'user' | 'assistant'; content: string }>) {
    // Fetch live business context to inject
    const context = await this.buildContext(businessId);

    const systemPrompt = `You are PESA AI, an expert business advisor for African SMEs using the PESAPOP Business Operating System.

You have access to REAL-TIME business data for this merchant:

${context}

Guidelines:
- Answer in clear, concise English. Use simple language.
- Always reference specific numbers from the context above when relevant.
- If asked to forecast, base it on the trends shown in the data.
- For inventory questions, flag low-stock items proactively.
- Format currency as "KES X,XXX" format.
- If a question is outside your business data, say so honestly.
- Keep responses under 200 words unless a detailed breakdown is needed.`;

    try {
      const completion = await this.openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          ...messages,
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      return {
        message: completion.choices[0].message.content,
        usage: completion.usage,
      };
    } catch (e) {
      this.logger.error('OpenAI error:', e);
      throw e;
    }
  }

  private async buildContext(businessId: string): Promise<string> {
    const [dashboard, inventory, recentSales] = await Promise.all([
      this.analytics.getDashboard(businessId, '30d'),
      this.prisma.product.findMany({
        where: { businessId, isActive: true },
        include: { stockItems: true },
        take: 20,
        orderBy: { name: 'asc' },
      }),
      this.prisma.sale.findMany({
        where: { businessId, paymentStatus: 'COMPLETED' },
        include: { items: { take: 3 } },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
    ]);

    const lowStock = inventory
      .map(p => ({ ...p, qty: p.stockItems.reduce((s, i) => s + i.qty, 0) }))
      .filter(p => p.qty <= p.reorderLevel)
      .map(p => `${p.name} (${p.qty} left)`);

    return `
=== BUSINESS OVERVIEW (Last 30 Days) ===
Revenue: KES ${dashboard.revenue.toLocaleString()}
Net Profit: KES ${dashboard.profit.toLocaleString()}
Profit Margin: ${dashboard.profitMargin.toFixed(1)}%
Transactions: ${dashboard.transactionCount}
Avg Order Value: KES ${dashboard.avgOrderValue.toFixed(0)}
Revenue Trend: ${dashboard.revenueTrend > 0 ? '+' : ''}${dashboard.revenueTrend}% vs previous period
Total Customers: ${dashboard.customers} (${dashboard.newCustomers} new)

=== TOP PRODUCTS ===
${dashboard.topProducts.map((p: any, i: number) => `${i+1}. ${p.name} — KES ${p.revenue.toLocaleString()} (${p.units} units)`).join('\n')}

=== PAYMENT BREAKDOWN ===
${Object.entries(dashboard.paymentBreakdown).map(([k,v]) => `${k}: ${v}%`).join(', ')}

=== LOW STOCK ALERTS (${lowStock.length} products) ===
${lowStock.length > 0 ? lowStock.join(', ') : 'None — all products well-stocked'}

=== TODAY'S DATE ===
${dayjs().format('dddd, MMMM D, YYYY')}
`;
  }
}
