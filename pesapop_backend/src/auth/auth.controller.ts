import { Controller, Post, Body, Get, UseGuards, Req, HttpCode } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { RequestOtpDto, VerifyOtpDto, RegisterDto, RefreshTokenDto } from './auth.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('request-otp') @HttpCode(200)
  requestOtp(@Body() dto: RequestOtpDto) { return this.authService.requestOtp(dto.phone); }

  @Post('verify-otp') @HttpCode(200)
  verifyOtp(@Body() dto: VerifyOtpDto) { return this.authService.verifyOtp(dto.phone, dto.code); }

  @Post('register')
  register(@Body() dto: RegisterDto) { return this.authService.register(dto); }

  @Post('refresh') @HttpCode(200)
  refresh(@Body() dto: RefreshTokenDto) { return this.authService.refreshTokens(dto.refreshToken); }

  @Post('logout') @UseGuards(AuthGuard('jwt')) @HttpCode(200)
  logout(@Req() req: any) { return this.authService.logout(req.user.sessionId); }

  @Get('me') @UseGuards(AuthGuard('jwt'))
  me(@Req() req: any) { return this.authService.getMe(req.user.sub); }
}
