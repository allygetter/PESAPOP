import { IsString, IsArray, IsNumber, IsOptional, IsEnum, ValidateNested, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class SaleItemDto {
  @IsString() productId: string;
  @IsString() name: string;
  @IsNumber() @Min(1) qty: number;
  @IsNumber() price: number;
  @IsNumber() @IsOptional() discount?: number;
  @IsNumber() @IsOptional() tax?: number;
}

export class CreateSaleDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => SaleItemDto)
  items: SaleItemDto[];

  @IsString() paymentMethod: string;
  @IsString() @IsOptional() customerId?: string;
  @IsString() @IsOptional() mpesaPhone?: string;
  @IsNumber() @IsOptional() amountPaid?: number;
  @IsString() @IsOptional() notes?: string;
}

export class SaleQueryDto {
  @IsString() @IsOptional() startDate?: string;
  @IsString() @IsOptional() endDate?: string;
  @IsString() @IsOptional() paymentMethod?: string;
  @IsString() @IsOptional() cashierId?: string;
  page?: number;
  limit?: number;
}
