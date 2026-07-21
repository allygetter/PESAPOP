import { Injectable, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../common/prisma/prisma.service';
import { RedisService } from '../common/redis/redis.service';
import { OtpService } from './otp.service';
import { RegisterDto } from './auth.dto';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
    private config: ConfigService,
    private redis: RedisService,
    private otp: OtpService,
  ) {}

  async requestOtp(phone: string) {
    const normalized = this.normalizePhone(phone);
    const code = this.otp.generate();
    await this.redis.setJson(`otp:${normalized}`, { code, attempts: 0 }, 300);
    await this.otp.sendSms(normalized,
      `Your PESAPOP code: ${code}. Valid 5 min. Do not share.`);
    return { message: 'OTP sent', phone: normalized };
  }

  async verifyOtp(phone: string, code: string) {
    const normalized = this.normalizePhone(phone);
    const stored = await this.redis.getJson<{ code: string; attempts: number }>(`otp:${normalized}`);
    if (!stored) throw new BadRequestException('OTP expired. Request a new one.');
    if (stored.attempts >= 3) {
      await this.redis.del(`otp:${normalized}`);
      throw new BadRequestException('Too many attempts. Request a new OTP.');
    }
    if (stored.code !== code) {
      await this.redis.setJson(`otp:${normalized}`, { ...stored, attempts: stored.attempts + 1 }, 300);
      throw new BadRequestException('Invalid OTP.');
    }
    await this.redis.del(`otp:${normalized}`);

    const user = await this.prisma.user.findUnique({
      where: { phone: normalized },
      include: { business: true, branch: true },
    });
    if (!user) return { action: 'REGISTER', phone: normalized };
    return this.issueTokens(user);
  }

  async register(dto: RegisterDto) {
    const phone = this.normalizePhone(dto.phone);
    const existing = await this.prisma.user.findUnique({ where: { phone } });
    if (existing) throw new BadRequestException('Phone already registered.');

    const user = await this.prisma.$transaction(async (tx) => {
      const business = await tx.business.create({
        data: { name: dto.businessName, phone, email: dto.email, address: dto.address },
      });
      const branch = await tx.branch.create({
        data: { businessId: business.id, name: 'Main Branch', isDefault: true },
      });
      return tx.user.create({
        data: { businessId: business.id, branchId: branch.id, name: dto.name, phone, email: dto.email, role: 'OWNER' },
        include: { business: true, branch: true },
      });
    });

    return this.issueTokens(user);
  }

  async refreshTokens(refreshToken: string) {
    const session = await this.prisma.session.findUnique({
      where: { refreshToken },
      include: { user: { include: { business: true, branch: true } } },
    });
    if (!session || session.expiresAt < new Date())
      throw new UnauthorizedException('Invalid or expired refresh token.');
    return this.issueTokens(session.user, session.id);
  }

  async logout(sessionId: string) {
    await this.prisma.session.delete({ where: { id: sessionId } }).catch(() => null);
    return { message: 'Logged out.' };
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { business: true, branch: true },
    });
    if (!user) throw new NotFoundException('User not found.');
    const { pin, ...safe } = user as any;
    return safe;
  }

  private async issueTokens(user: any, existingSessionId?: string) {
    const sessionId = existingSessionId ?? uuidv4();
    const refreshToken = uuidv4();
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await this.prisma.session.upsert({
      where: { id: sessionId },
      create: { id: sessionId, userId: user.id, refreshToken, expiresAt },
      update: { refreshToken, expiresAt },
    });
    await this.prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } });

    const payload = { sub: user.id, businessId: user.businessId, branchId: user.branchId, role: user.role, sessionId };
    return {
      accessToken: this.jwt.sign(payload),
      refreshToken,
      expiresIn: 900,
      user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role, business: user.business, branch: user.branch },
    };
  }

  private normalizePhone(phone: string): string {
    const d = phone.replace(/\D/g, '');
    if (d.startsWith('0') && d.length === 10) return `+254${d.slice(1)}`;
    if (d.startsWith('254')) return `+${d}`;
    if (d.startsWith('7') && d.length === 9) return `+254${d}`;
    return phone;
  }
}
