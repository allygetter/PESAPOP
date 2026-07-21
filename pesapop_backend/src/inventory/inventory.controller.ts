import { Controller, Get, Post, Body, Query, Param, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { InventoryService } from './inventory.service';
import { StockInDto, StockAdjustDto, TransferDto } from './inventory.dto';

@Controller('inventory')
@UseGuards(AuthGuard('jwt'))
export class InventoryController {
  constructor(private readonly svc: InventoryService) {}

  @Get() getAll(@Req() req: any, @Query('branchId') branchId?: string) {
    return this.svc.getInventory(req.user.businessId, branchId ?? req.user.branchId);
  }
  @Get('stats') stats(@Req() req: any) {
    return this.svc.getInventoryStats(req.user.businessId);
  }
  @Get('low-stock') lowStock(@Req() req: any) {
    return this.svc.getLowStockAlerts(req.user.businessId);
  }
  @Get('movements') movements(@Req() req: any, @Query('productId') productId?: string) {
    return this.svc.getMovements(req.user.businessId, productId, req.user.branchId);
  }
  @Post('stock-in') stockIn(@Req() req: any, @Body() dto: StockInDto) {
    return this.svc.stockIn(req.user.businessId, dto, req.user.sub);
  }
  @Post('adjust') adjust(@Req() req: any, @Body() dto: StockAdjustDto) {
    return this.svc.adjust(req.user.businessId, dto, req.user.sub);
  }
  @Post('transfer') transfer(@Req() req: any, @Body() dto: TransferDto) {
    return this.svc.transfer(req.user.businessId, dto, req.user.sub);
  }
}
