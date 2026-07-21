import { Controller, Post, Get, Body, Param, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly svc: PaymentsService) {}

  @Post('mpesa/stk')
  @UseGuards(AuthGuard('jwt'))
  stkPush(@Body() body: { saleId: string; phone: string; amount: number }) {
    return this.svc.initiateMpesaPayment(body.saleId, body.phone, body.amount);
  }

  // Safaricom hits this — no auth guard
  @Post('mpesa/callback')
  mpesaCallback(@Body() body: any) {
    return this.svc.handleMpesaCallback(body);
  }

  @Get(':saleId/status')
  @UseGuards(AuthGuard('jwt'))
  status(@Param('saleId') saleId: string) {
    return this.svc.getPaymentStatus(saleId);
  }
}
