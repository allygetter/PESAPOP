import { IsString, Length, IsOptional } from 'class-validator';

export class RequestOtpDto {
  @IsString() phone: string;
}
export class VerifyOtpDto {
  @IsString() phone: string;
  @IsString() @Length(6,6) code: string;
}
export class RegisterDto {
  @IsString() name: string;
  @IsString() phone: string;
  @IsString() businessName: string;
  @IsString() @IsOptional() email?: string;
  @IsString() @IsOptional() address?: string;
}
export class RefreshTokenDto {
  @IsString() refreshToken: string;
}
