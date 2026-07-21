import { IsString, IsNumber, IsOptional, IsBoolean, Min } from 'class-validator';

export class CreateProductDto {
  @IsString() name: string;
  @IsNumber() price: number;
  @IsString() @IsOptional() categoryId?: string;
  @IsString() @IsOptional() sku?: string;
  @IsString() @IsOptional() barcode?: string;
  @IsString() @IsOptional() description?: string;
  @IsNumber() @IsOptional() costPrice?: number;
  @IsString() @IsOptional() unit?: string;
  @IsBoolean() @IsOptional() isVatExempt?: boolean;
  @IsNumber() @Min(0) @IsOptional() reorderLevel?: number;
}

export class UpdateProductDto extends CreateProductDto {}

export class ProductQueryDto {
  @IsString() @IsOptional() search?: string;
  @IsString() @IsOptional() categoryId?: string;
  @IsString() @IsOptional() branchId?: string;
  @IsBoolean() @IsOptional() lowStockOnly?: boolean;
  page?: number;
  limit?: number;
}
