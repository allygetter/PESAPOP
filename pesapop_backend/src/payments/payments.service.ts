import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../common/prisma/prisma.service';
import { RedisService } from '../common/redis/redis.service';
import { MpesaService } from './mpesa.service';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
    private mpesa: MpesaService,
    private config: ConfigService,
    private events: EventEmitter2,
  ) {}

  async initiateMpesaPayment(saleId: string, phone: string, amount: number) {
    const sale = await this.prisma.sale.findUnique({ where: { id: saleId } });
    const callbackUrl = `${this.config.get('API_BASE_URL')}/api/v1/payments/mpesa/callback`;

    const result = await this.mpesa.stkPush({
      phone,
      amount,
      accountRef: sale?.receiptNumber ?? saleId,
      description: 'PESAPOP Payment',
      callbackUrl,
    });

    // Cache checkoutRequestId → saleId for callback lookup
    await this.redis.setJson(`mpesa:${result.checkoutRequestId}`, { saleId, phone, amount }, 300);

    await this.prisma.payment.upsert({
      where: { saleId },
      create: { saleId, method: 'MPESA', amount, status: 'PENDING', gatewayRef: result.checkoutRequestId },
      update: { gatewayRef: result.checkoutRequestId, status: 'PENDING' },
    });

    return result;
  }

  async handleMpesaCallback(body: any) {
    const result = this.mpesa.processCallback(body);
    const checkoutId = body?.Body?.stkCallback?.CheckoutRequestID;
    if (!checkoutId) return;

    const cached = await this.redis.getJson<{ saleId: string }>(`mpesa:${checkoutId}`);
    if (!cached) return;

    const status = result.success ? 'COMPLETED' : 'FAILED';

    await this.prisma.$transaction([
      this.prisma.payment.update({
        where: { saleId: cached.saleId },
        data: { status: status as any, gatewayRef: result.mpesaRef ?? checkoutId, gatewayMeta: body },
      }),
      this.prisma.sale.update({
        where: { id: cached.saleId },
        data: { paymentStatus: status as any, mpesaRef: result.mpesaRef },
      }),
    ]);

    await this.redis.del(`mpesa:${checkoutId}`);
    this.events.emit('payment.completed', { saleId: cached.saleId, success: result.success, mpesaRef: result.mpesaRef });
  }

  async getPaymentStatus(saleId: string) {
    return this.prisma.payment.findUnique({ where: { saleId } });
  }
}
