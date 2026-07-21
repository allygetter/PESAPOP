import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisService extends Redis implements OnModuleDestroy {
  constructor(configService: ConfigService) {
    super({
      host: configService.get('REDIS_HOST', 'localhost'),
      port: configService.get<number>('REDIS_PORT', 6379),
      password: configService.get('REDIS_PASSWORD'),
      retryStrategy: (t) => Math.min(t * 50, 2000),
    });
  }
  async onModuleDestroy() { await this.quit(); }
  async setEx(key: string, ttl: number, value: string) { await this.set(key, value, 'EX', ttl); }
  async getJson<T>(key: string): Promise<T | null> {
    const v = await this.get(key);
    return v ? JSON.parse(v) : null;
  }
  async setJson(key: string, value: unknown, ttl?: number) {
    const s = JSON.stringify(value);
    ttl ? await this.setEx(key, ttl, s) : await this.set(key, s);
  }
}
