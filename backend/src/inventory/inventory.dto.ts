import { IsString, IsNumber, IsOptional, IsEnum, Min } from 'class-validator';

export class StockInDto {
  @IsString() productId: string;
  @IsString() branchId: string;
  @IsNumber() @Min(1) qty: number;
  @IsString() @IsOptional() reference?: string;
  @IsString() @IsOptional() note?: string;
}

export class StockAdjustDto {
  @IsString() productId: string;
  @IsString() branchId: string;
  @IsNumber() qty: number;
  @IsString() note: string;
}

export class TransferDto {
  @IsString() productId: string;
  @IsString() fromBranchId: string;
  @IsString() toBranchId: string;
  @IsNumber() @Min(1) qty: number;
  @IsString() @IsOptional() note?: string;
}
