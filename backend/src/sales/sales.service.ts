import { Injectable, BadRequestException } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../common/prisma/prisma.service';
import { PaymentsService } from '../payments/payments.service';
import { CreateSaleDto, SaleQueryDto } from './sales.dto';
import { v4 as uuidv4 } from 'uuid';
import * as dayjs from 'dayjs';

@Injectable()
export class SalesService {
  constructor(
    private prisma: PrismaService,
    private payments: PaymentsService,
    private events: EventEmitter2,
  ) {}

  async create(businessId: string, branchId: string, cashierId: string, dto: CreateSaleDto) {
    // Calculate totals
    const subtotal = dto.items.reduce((s, i) => s + (i.price * i.qty - (i.discount ?? 0)), 0);
    const taxTotal = dto.items.reduce((s, i) => s + (i.tax ?? 0) * i.qty, 0);
    const grandTotal = subtotal + taxTotal;
    const amountPaid = dto.amountPaid ?? grandTotal;
    const change = Math.max(0, amountPaid - grandTotal);
    const receiptNumber = this.generateReceiptNumber();

    // Validate stock
    for (const item of dto.items) {
      const stock = await this.prisma.stockItem.findUnique({
        where: { productId_branchId: { productId: item.productId, branchId } },
      });
      if (!stock || stock.qty < item.qty) {
        throw new BadRequestException(`Insufficient stock for product ${item.name}`);
      }
    }

    // Create sale + deduct stock in transaction
    const sale = await this.prisma.$transaction(async (tx) => {
      const sale = await tx.sale.create({
        data: {
          businessId, branchId, cashierId,
          customerId: dto.customerId,
          receiptNumber, subtotal, taxTotal, grandTotal,
          amountPaid, change, notes: dto.notes,
          paymentMethod: dto.paymentMethod as any,
          paymentStatus: dto.paymentMethod === 'MPESA' ? 'PENDING' : 'COMPLETED',
          mpesaPhone: dto.mpesaPhone,
          items: {
            create: dto.items.map(i => ({
              productId: i.productId, name: i.name, qty: i.qty,
              price: i.price, discount: i.discount ?? 0,
              tax: (i.tax ?? 0) * i.qty,
              subtotal: i.price * i.qty - (i.discount ?? 0),
            })),
          },
        },
        include: { items: true, cashier: { select: { name: true } } },
      });

      // Deduct stock
      for (const item of dto.items) {
        await tx.stockItem.upsert({
          where: { productId_branchId: { productId: item.productId, branchId } },
          create: { productId: item.productId, branchId, qty: -item.qty },
          update: { qty: { decrement: item.qty } },
        });
        await tx.stockMovement.create({
          data: { productId: item.productId, branchId, type: 'STOCK_OUT', qty: item.qty, reference: receiptNumber, createdById: cashierId },
        });
      }

      return sale;
    });

    // Initiate M-Pesa STK push if needed
    if (dto.paymentMethod === 'MPESA' && dto.mpesaPhone) {
      await this.payments.initiateMpesaPayment(sale.id, dto.mpesaPhone, grandTotal);
    } else {
      // Cash/card — create payment record as completed
      await this.prisma.payment.create({
        data: { saleId: sale.id, method: dto.paymentMethod as any, amount: grandTotal, status: 'COMPLETED' },
      });
    }

    this.events.emit('sale.created', { saleId: sale.id, businessId, branchId, grandTotal });
    return sale;
  }

  async findAll(businessId: string, query: SaleQueryDto) {
    const { startDate, endDate, paymentMethod, cashierId, page = 1, limit = 20 } = query;
    const where: any = { businessId };
    if (startDate) where.createdAt = { gte: new Date(startDate) };
    if (endDate) where.createdAt = { ...where.createdAt, lte: new Date(endDate) };
    if (paymentMethod) where.paymentMethod = paymentMethod;
    if (cashierId) where.cashierId = cashierId;

    const [data, total] = await this.prisma.$transaction([
      this.prisma.sale.findMany({
        where, orderBy: { createdAt: 'desc' },
        include: { items: true, cashier: { select: { name: true } }, customer: { select: { name: true } } },
        skip: (page - 1) * limit, take: limit,
      }),
      this.prisma.sale.count({ where }),
    ]);

    return { data, total, page, limit, pages: Math.ceil(total / limit) };
  }

  async findOne(businessId: string, id: string) {
    return this.prisma.sale.findFirst({
      where: { id, businessId },
      include: { items: { include: { product: true } }, cashier: true, customer: true, payment: true },
    });
  }

  async getDailySummary(businessId: string, branchId?: string) {
    const today = dayjs().startOf('day').toDate();
    const where: any = { businessId, createdAt: { gte: today }, paymentStatus: 'COMPLETED' };
    if (branchId) where.branchId = branchId;

    const [sales, count] = await this.prisma.$transaction([
      this.prisma.sale.aggregate({ where, _sum: { grandTotal: true, taxTotal: true }, _count: true }),
      this.prisma.sale.count({ where }),
    ]);

    return {
      totalRevenue: Number(sales._sum.grandTotal ?? 0),
      totalTax: Number(sales._sum.taxTotal ?? 0),
      transactionCount: count,
      avgOrderValue: count > 0 ? Number(sales._sum.grandTotal ?? 0) / count : 0,
    };
  }

  private generateReceiptNumber(): string {
    const d = dayjs().format('YYYYMMDD');
    const rand = Math.random().toString(36).substring(2, 7).toUpperCase();
    return `RCP-${d}-${rand}`;
  }
}
