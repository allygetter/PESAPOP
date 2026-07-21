import { Injectable, BadRequestException } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../common/prisma/prisma.service';
import { StockInDto, StockAdjustDto, TransferDto } from './inventory.dto';

@Injectable()
export class InventoryService {
  constructor(private prisma: PrismaService, private events: EventEmitter2) {}

  async getInventory(businessId: string, branchId?: string) {
    const products = await this.prisma.product.findMany({
      where: { businessId, isActive: true },
      include: {
        category: { select: { name: true, color: true } },
        stockItems: branchId ? { where: { branchId } } : true,
      },
      orderBy: { name: 'asc' },
    });

    return products.map(p => ({
      ...p,
      stockQty: p.stockItems.reduce((s, i) => s + i.qty, 0),
      isLowStock: p.stockItems.reduce((s, i) => s + i.qty, 0) <= p.reorderLevel,
      isOutOfStock: p.stockItems.reduce((s, i) => s + i.qty, 0) === 0,
    }));
  }

  async getInventoryStats(businessId: string) {
    const products = await this.prisma.product.findMany({
      where: { businessId, isActive: true },
      include: { stockItems: true },
    });

    let totalValue = 0;
    let lowStockCount = 0;
    let outOfStockCount = 0;

    for (const p of products) {
      const qty = p.stockItems.reduce((s, i) => s + i.qty, 0);
      totalValue += qty * Number(p.costPrice ?? p.price);
      if (qty === 0) outOfStockCount++;
      else if (qty <= p.reorderLevel) lowStockCount++;
    }

    const categories = await this.prisma.category.count({ where: { businessId } });

    return {
      totalProducts: products.length,
      totalValue,
      lowStockCount,
      outOfStockCount,
      categories,
    };
  }

  async stockIn(businessId: string, dto: StockInDto, createdById: string) {
    // Verify product belongs to business
    const product = await this.prisma.product.findFirst({ where: { id: dto.productId, businessId } });
    if (!product) throw new BadRequestException('Product not found.');

    await this.prisma.$transaction([
      this.prisma.stockItem.upsert({
        where: { productId_branchId: { productId: dto.productId, branchId: dto.branchId } },
        create: { productId: dto.productId, branchId: dto.branchId, qty: dto.qty },
        update: { qty: { increment: dto.qty } },
      }),
      this.prisma.stockMovement.create({
        data: {
          productId: dto.productId,
          branchId: dto.branchId,
          type: 'STOCK_IN',
          qty: dto.qty,
          reference: dto.reference,
          note: dto.note,
          createdById,
        },
      }),
    ]);

    this.events.emit('inventory.stock_in', { productId: dto.productId, qty: dto.qty });
    return { message: 'Stock added successfully.', qty: dto.qty };
  }

  async adjust(businessId: string, dto: StockAdjustDto, createdById: string) {
    const product = await this.prisma.product.findFirst({ where: { id: dto.productId, businessId } });
    if (!product) throw new BadRequestException('Product not found.');

    const current = await this.prisma.stockItem.findUnique({
      where: { productId_branchId: { productId: dto.productId, branchId: dto.branchId } },
    });

    const newQty = (current?.qty ?? 0) + dto.qty;
    if (newQty < 0) throw new BadRequestException('Adjustment would result in negative stock.');

    await this.prisma.$transaction([
      this.prisma.stockItem.upsert({
        where: { productId_branchId: { productId: dto.productId, branchId: dto.branchId } },
        create: { productId: dto.productId, branchId: dto.branchId, qty: dto.qty },
        update: { qty: newQty },
      }),
      this.prisma.stockMovement.create({
        data: {
          productId: dto.productId,
          branchId: dto.branchId,
          type: 'ADJUSTMENT',
          qty: Math.abs(dto.qty),
          note: dto.note,
          createdById,
        },
      }),
    ]);

    return { message: 'Stock adjusted.', newQty };
  }

  async transfer(businessId: string, dto: TransferDto, createdById: string) {
    const product = await this.prisma.product.findFirst({ where: { id: dto.productId, businessId } });
    if (!product) throw new BadRequestException('Product not found.');

    const fromStock = await this.prisma.stockItem.findUnique({
      where: { productId_branchId: { productId: dto.productId, branchId: dto.fromBranchId } },
    });
    if (!fromStock || fromStock.qty < dto.qty) {
      throw new BadRequestException('Insufficient stock in source branch.');
    }

    await this.prisma.$transaction([
      this.prisma.stockItem.update({
        where: { productId_branchId: { productId: dto.productId, branchId: dto.fromBranchId } },
        data: { qty: { decrement: dto.qty } },
      }),
      this.prisma.stockItem.upsert({
        where: { productId_branchId: { productId: dto.productId, branchId: dto.toBranchId } },
        create: { productId: dto.productId, branchId: dto.toBranchId, qty: dto.qty },
        update: { qty: { increment: dto.qty } },
      }),
      this.prisma.stockMovement.create({
        data: { productId: dto.productId, branchId: dto.fromBranchId, type: 'TRANSFER', qty: dto.qty, note: dto.note, createdById },
      }),
    ]);

    return { message: 'Stock transferred successfully.' };
  }

  async getMovements(businessId: string, productId?: string, branchId?: string, limit = 50) {
    const where: any = {};
    if (productId) where.productId = productId;
    if (branchId) where.branchId = branchId;
    // Filter by business via product
    if (!productId) {
      const productIds = await this.prisma.product
        .findMany({ where: { businessId }, select: { id: true } })
        .then(ps => ps.map(p => p.id));
      where.productId = { in: productIds };
    }

    return this.prisma.stockMovement.findMany({
      where,
      include: { product: { select: { name: true, sku: true } } },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async getLowStockAlerts(businessId: string) {
    const products = await this.prisma.product.findMany({
      where: { businessId, isActive: true },
      include: { stockItems: true, category: { select: { name: true } } },
    });
    return products
      .map(p => ({ ...p, stockQty: p.stockItems.reduce((s, i) => s + i.qty, 0) }))
      .filter(p => p.stockQty <= p.reorderLevel)
      .sort((a, b) => a.stockQty - b.stockQty);
  }
}
