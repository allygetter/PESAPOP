import { Controller, Get, Post, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CustomersService } from './customers.service';
import { CreateCustomerDto } from './customers.dto';

@Controller('customers')
@UseGuards(AuthGuard('jwt'))
export class CustomersController {
  constructor(private readonly svc: CustomersService) {}
  @Get() findAll(@Req() req: any, @Query('search') search?: string) {
    return this.svc.findAll(req.user.businessId, search);
  }
  @Get(':id') findOne(@Req() req: any, @Param('id') id: string) {
    return this.svc.findOne(req.user.businessId, id);
  }
  @Post() create(@Req() req: any, @Body() dto: CreateCustomerDto) {
    return this.svc.create(req.user.businessId, dto);
  }
}
