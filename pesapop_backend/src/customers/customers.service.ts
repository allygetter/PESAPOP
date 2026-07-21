import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { CreateCustomerDto } from './customers.dto';

@Injectable()
export class CustomersService {
  constructor(private prisma: PrismaService) {}

  async findAll(businessId: string, search?: string) {
    return this.prisma.customer.findMany({
      where: {
        businessId,
        ...(search ? { OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { phone: { contains: search } },
        ]} : {}),
      },
      include: { _count: { select: { sales: true } } },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async findOne(businessId: string, id: string) {
    return this.prisma.customer.findFirst({
      where: { id, businessId },
      include: {
        sales: { orderBy: { createdAt: 'desc' }, take: 10, include: { items: true } },
        _count: { select: { sales: true } },
      },
    });
  }

  async findOrCreate(businessId: string, dto: CreateCustomerDto) {
    if (dto.phone) {
      const existing = await this.prisma.customer.findFirst({
        where: { businessId, phone: dto.phone },
      });
      if (existing) return existing;
    }
    return this.prisma.customer.create({ data: { ...dto, businessId } });
  }

  async create(businessId: string, dto: CreateCustomerDto) {
    return this.prisma.customer.create({ data: { ...dto, businessId } });
  }

  async addLoyaltyPoints(customerId: string, points: number) {
    return this.prisma.customer.update({
      where: { id: customerId },
      data: { loyaltyPoints: { increment: points } },
    });
  }
}
