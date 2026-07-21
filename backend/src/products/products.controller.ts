import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ProductsService } from './products.service';
import { CreateProductDto, ProductQueryDto } from './products.dto';

@Controller('products')
@UseGuards(AuthGuard('jwt'))
export class ProductsController {
  constructor(private readonly svc: ProductsService) {}

  @Get() findAll(@Req() req: any, @Query() q: ProductQueryDto) {
    return this.svc.findAll(req.user.businessId, q);
  }
  @Get('low-stock') lowStock(@Req() req: any) {
    return this.svc.getLowStockAlerts(req.user.businessId, req.user.branchId);
  }
  @Get('barcode/:code') byBarcode(@Req() req: any, @Param('code') code: string) {
    return this.svc.findByBarcode(req.user.businessId, code);
  }
  @Get(':id') findOne(@Req() req: any, @Param('id') id: string) {
    return this.svc.findOne(req.user.businessId, id);
  }
  @Post() create(@Req() req: any, @Body() dto: CreateProductDto) {
    return this.svc.create(req.user.businessId, dto);
  }
  @Put(':id') update(@Req() req: any, @Param('id') id: string, @Body() dto: CreateProductDto) {
    return this.svc.update(req.user.businessId, id, dto);
  }
  @Delete(':id') remove(@Req() req: any, @Param('id') id: string) {
    return this.svc.remove(req.user.businessId, id);
  }
}
