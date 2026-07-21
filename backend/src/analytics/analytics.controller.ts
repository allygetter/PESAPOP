import { Controller, Get, Query, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AnalyticsService } from './analytics.service';

@Controller('analytics')
@UseGuards(AuthGuard('jwt'))
export class AnalyticsController {
  constructor(private readonly svc: AnalyticsService) {}

  @Get('dashboard')
  dashboard(@Req() req: any, @Query('range') range: '7d' | '30d' | '90d' | '1y' = '30d') {
    return this.svc.getDashboard(req.user.businessId, range);
  }

  @Get('profit-loss')
  profitLoss(@Req() req: any, @Query('month') month: string) {
    return this.svc.getProfitLoss(req.user.businessId, month ?? new Date().toISOString());
  }
}
