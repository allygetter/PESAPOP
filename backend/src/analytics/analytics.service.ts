import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { RedisService } from '../common/redis/redis.service';
import * as dayjs from 'dayjs';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService, private redis: RedisService) {}

  // Owner dashboard: revenue, profit, customers, top products
  async getDashboard(businessId: string, range: '7d' | '30d' | '90d' | '1y' = '30d') {
    const cacheKey = `analytics:dashboard:${businessId}:${range}`;
    const cached = await this.redis.getJson(cacheKey);
    if (cached) return cached;

    const days = range === '7d' ? 7 : range === '30d' ? 30 : range === '90d' ? 90 : 365;
    const startDate = dayjs().subtract(days, 'day').toDate();

    const [sales, prevSales, expenses, customers, newCustomers] = await this.prisma.$transaction([
      this.prisma.sale.aggregate({
        where: { businessId, paymentStatus: 'COMPLETED', createdAt: { gte: startDate } },
        _sum: { grandTotal: true, taxTotal: true, discountTotal: true },
        _count: true,
        _avg: { grandTotal: true },
      }),
      this.prisma.sale.aggregate({
        where: {
          businessId, paymentStatus: 'COMPLETED',
          createdAt: { gte: dayjs().subtract(days * 2, 'day').toDate(), lt: startDate },
        },
        _sum: { grandTotal: true },
      }),
      this.prisma.expense.aggregate({
        where: { businessId, date: { gte: startDate } },
        _sum: { amount: true },
      }),
      this.prisma.customer.count({ where: { businessId } }),
      this.prisma.customer.count({ where: { businessId, createdAt: { gte: startDate } } }),
    ]);

    const revenue = Number(sales._sum.grandTotal ?? 0);
    const prevRevenue = Number(prevSales._sum.grandTotal ?? 0);
    const expenseTotal = Number(expenses._sum.amount ?? 0);
    const profit = revenue - expenseTotal;
    const revenueTrend = prevRevenue > 0 ? ((revenue - prevRevenue) / prevRevenue) * 100 : 0;

    // Revenue by day chart
    const revenueChart = await this.getRevenueChart(businessId, startDate, days > 30 ? 'week' : 'day');

    // Top products
    const topProducts = await this.getTopProducts(businessId, startDate);

    // Payment breakdown
    const paymentBreakdown = await this.getPaymentBreakdown(businessId, startDate);

    const result = {
      revenue, profit, expenses: expenseTotal,
      profitMargin: revenue > 0 ? (profit / revenue) * 100 : 0,
      transactionCount: sales._count,
      avgOrderValue: Number(sales._avg.grandTotal ?? 0),
      revenueTrend: Math.round(revenueTrend * 10) / 10,
      customers, newCustomers,
      revenueChart, topProducts, paymentBreakdown,
    };

    await this.redis.setJson(cacheKey, result, 300); // 5-min cache
    return result;
  }

  private async getRevenueChart(businessId: string, startDate: Date, groupBy: 'day' | 'week') {
    const sales = await this.prisma.sale.findMany({
      where: { businessId, paymentStatus: 'COMPLETED', createdAt: { gte: startDate } },
      select: { grandTotal: true, createdAt: true },
      orderBy: { createdAt: 'asc' },
    });

    const grouped: Record<string, number> = {};
    for (const s of sales) {
      const key = groupBy === 'day'
        ? dayjs(s.createdAt).format('MMM DD')
        : `Week ${dayjs(s.createdAt).week()}`;
      grouped[key] = (grouped[key] ?? 0) + Number(s.grandTotal);
    }

    return Object.entries(grouped).map(([label, value]) => ({ label, value }));
  }

  private async getTopProducts(businessId: string, startDate: Date, limit = 5) {
    const items = await this.prisma.saleItem.groupBy({
      by: ['productId', 'name'],
      where: { sale: { businessId, paymentStatus: 'COMPLETED', createdAt: { gte: startDate } } },
      _sum: { subtotal: true, qty: true },
      orderBy: { _sum: { subtotal: 'desc' } },
      take: limit,
    });

    const totalRevenue = items.reduce((s, i) => s + Number(i._sum.subtotal ?? 0), 0);
    return items.map(i => ({
      productId: i.productId,
      name: i.name,
      revenue: Number(i._sum.subtotal ?? 0),
      units: i._sum.qty ?? 0,
      pct: totalRevenue > 0 ? Math.round((Number(i._sum.subtotal ?? 0) / totalRevenue) * 1000) / 10 : 0,
    }));
  }

  private async getPaymentBreakdown(businessId: string, startDate: Date) {
    const sales = await this.prisma.sale.groupBy({
      by: ['paymentMethod'],
      where: { businessId, paymentStatus: 'COMPLETED', createdAt: { gte: startDate } },
      _sum: { grandTotal: true },
    });

    const total = sales.reduce((s, i) => s + Number(i._sum.grandTotal ?? 0), 0);
    const result: Record<string, number> = {};
    for (const s of sales) {
      result[s.paymentMethod] = total > 0
        ? Math.round((Number(s._sum.grandTotal ?? 0) / total) * 1000) / 10
        : 0;
    }
    return result;
  }

  async getProfitLoss(businessId: string, month: string) {
    const start = dayjs(month).startOf('month').toDate();
    const end = dayjs(month).endOf('month').toDate();

    const [sales, expenses] = await this.prisma.$transaction([
      this.prisma.sale.aggregate({
        where: { businessId, paymentStatus: 'COMPLETED', createdAt: { gte: start, lte: end } },
        _sum: { grandTotal: true, taxTotal: true, discountTotal: true },
        _count: true,
      }),
      this.prisma.expense.groupBy({
        by: ['category'],
        where: { businessId, date: { gte: start, lte: end } },
        _sum: { amount: true },
      }),
    ]);

    const revenue = Number(sales._sum.grandTotal ?? 0);
    const totalExpenses = expenses.reduce((s, e) => s + Number(e._sum.amount ?? 0), 0);

    return {
      revenue, totalExpenses,
      grossProfit: revenue,
      netProfit: revenue - totalExpenses,
      profitMargin: revenue > 0 ? ((revenue - totalExpenses) / revenue) * 100 : 0,
      taxCollected: Number(sales._sum.taxTotal ?? 0),
      transactionCount: sales._count,
      expensesByCategory: expenses.map(e => ({
        category: e.category,
        amount: Number(e._sum.amount ?? 0),
      })),
    };
  }
}
