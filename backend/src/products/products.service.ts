import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { CreateProductDto, ProductQueryDto } from './products.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(businessId: string, query: ProductQueryDto) {
    const { search, categoryId, branchId, lowStockOnly, page = 1, limit = 50 } = query;

    const where: any = { businessId, isActive: true };
    if (search) where.name = { contains: search, mode: 'insensitive' };
    if (categoryId) where.categoryId = categoryId;

    const products = await this.prisma.product.findMany({
      where,
      include: {
        category: { select: { id: true, name: true, color: true } },
        stockItems: branchId ? { where: { branchId } } : true,
      },
      orderBy: { name: 'asc' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return products.map(p => ({
      ...p,
      stockQty: p.stockItems.reduce((sum, s) => sum + s.qty, 0),
      isLowStock: p.stockItems.reduce((sum, s) => sum + s.qty, 0) <= p.reorderLevel,
    }));
  }

  async findOne(businessId: string, id: string) {
    const product = await this.prisma.product.findFirst({
      where: { id, businessId },
      include: { category: true, stockItems: { include: { branch: true } } },
    });
    if (!product) throw new NotFoundException('Product not found.');
    return product;
  }

  async findByBarcode(businessId: string, barcode: string) {
    const product = await this.prisma.product.findFirst({
      where: { businessId, barcode, isActive: true },
      include: { stockItems: true },
    });
    if (!product) throw new NotFoundException('Product not found for that barcode.');
    return { ...product, stockQty: product.stockItems.reduce((s, i) => s + i.qty, 0) };
  }

  async create(businessId: string, dto: CreateProductDto) {
    return this.prisma.product.create({
      data: { ...dto, businessId, price: dto.price, costPrice: dto.costPrice },
      include: { category: true },
    });
  }

  async update(businessId: string, id: string, dto: Partial<CreateProductDto>) {
    await this.findOne(businessId, id);
    return this.prisma.product.update({ where: { id }, data: dto, include: { category: true } });
  }

  async remove(businessId: string, id: string) {
    await this.findOne(businessId, id);
    await this.prisma.product.update({ where: { id }, data: { isActive: false } });
    return { message: 'Product deactivated.' };
  }

  async getLowStockAlerts(businessId: string, branchId?: string) {
    const products = await this.prisma.product.findMany({
      where: { businessId, isActive: true },
      include: { stockItems: branchId ? { where: { branchId } } : true },
    });
    return products
      .map(p => ({ ...p, stockQty: p.stockItems.reduce((s, i) => s + i.qty, 0) }))
      .filter(p => p.stockQty <= p.reorderLevel);
  }
}
