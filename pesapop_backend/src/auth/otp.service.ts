import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(private config: ConfigService) {}

  generate(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async sendSms(phone: string, message: string): Promise<void> {
    if (this.config.get('NODE_ENV') !== 'production') {
      this.logger.debug(`[DEV SMS] → ${phone}: ${message}`);
      return;
    }
    // Production: use Africa's Talking
    const AfricasTalking = require('africastalking');
    const at = AfricasTalking({
      apiKey: this.config.get('AT_API_KEY'),
      username: this.config.get('AT_USERNAME'),
    });
    await at.SMS.send({ to: [phone], message, from: this.config.get('AT_SENDER_ID', 'PESAPOP') });
  }
}
