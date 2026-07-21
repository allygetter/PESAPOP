import { Controller, Get, Post, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { SalesService } from './sales.service';
import { CreateSaleDto, SaleQueryDto } from './sales.dto';

@Controller('sales')
@UseGuards(AuthGuard('jwt'))
export class SalesController {
  constructor(private readonly svc: SalesService) {}

  @Post()
  create(@Req() req: any, @Body() dto: CreateSaleDto) {
    return this.svc.create(req.user.businessId, req.user.branchId, req.user.sub, dto);
  }
  @Get()
  findAll(@Req() req: any, @Query() q: SaleQueryDto) {
    return this.svc.findAll(req.user.businessId, q);
  }
  @Get('summary/today')
  todaySummary(@Req() req: any) {
    return this.svc.getDailySummary(req.user.businessId, req.user.branchId);
  }
  @Get(':id')
  findOne(@Req() req: any, @Param('id') id: string) {
    return this.svc.findOne(req.user.businessId, id);
  }
}
