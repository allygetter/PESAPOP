import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class MpesaService {
  private readonly logger = new Logger(MpesaService.name);
  private readonly baseUrl: string;

  constructor(private config: ConfigService) {
    const sandbox = config.get('MPESA_ENV') !== 'production';
    this.baseUrl = sandbox
      ? 'https://sandbox.safaricom.co.ke'
      : 'https://api.safaricom.co.ke';
  }

  // Get OAuth token
  private async getToken(): Promise<string> {
    const key = this.config.get('MPESA_CONSUMER_KEY');
    const secret = this.config.get('MPESA_CONSUMER_SECRET');
    const credentials = Buffer.from(`${key}:${secret}`).toString('base64');

    const res = await axios.get(
      `${this.baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
      { headers: { Authorization: `Basic ${credentials}` } },
    );
    return res.data.access_token;
  }

  // STK Push (Lipa Na M-Pesa)
  async stkPush(params: {
    phone: string;
    amount: number;
    accountRef: string;
    description: string;
    callbackUrl: string;
  }): Promise<{ checkoutRequestId: string; merchantRequestId: string }> {
    const token = await this.getToken();
    const shortcode = this.config.get('MPESA_SHORTCODE');
    const passkey = this.config.get('MPESA_PASSKEY');
    const timestamp = this.getTimestamp();
    const password = Buffer.from(`${shortcode}${passkey}${timestamp}`).toString('base64');

    const phone = this.normalizePhone(params.phone);

    this.logger.log(`STK Push → ${phone} KES ${params.amount}`);

    const res = await axios.post(
      `${this.baseUrl}/mpesa/stkpush/v1/processrequest`,
      {
        BusinessShortCode: shortcode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: 'CustomerPayBillOnline',
        Amount: Math.ceil(params.amount),
        PartyA: phone,
        PartyB: shortcode,
        PhoneNumber: phone,
        CallBackURL: params.callbackUrl,
        AccountReference: params.accountRef,
        TransactionDesc: params.description,
      },
      { headers: { Authorization: `Bearer ${token}` } },
    );

    if (res.data.ResponseCode !== '0') {
      throw new BadRequestException(`M-Pesa error: ${res.data.ResponseDescription}`);
    }

    return {
      checkoutRequestId: res.data.CheckoutRequestID,
      merchantRequestId: res.data.MerchantRequestID,
    };
  }

  // Query STK status
  async stkQuery(checkoutRequestId: string): Promise<{ status: string; resultDesc: string }> {
    const token = await this.getToken();
    const shortcode = this.config.get('MPESA_SHORTCODE');
    const passkey = this.config.get('MPESA_PASSKEY');
    const timestamp = this.getTimestamp();
    const password = Buffer.from(`${shortcode}${passkey}${timestamp}`).toString('base64');

    const res = await axios.post(
      `${this.baseUrl}/mpesa/stkpushquery/v1/query`,
      { BusinessShortCode: shortcode, Password: password, Timestamp: timestamp, CheckoutRequestID: checkoutRequestId },
      { headers: { Authorization: `Bearer ${token}` } },
    );

    return {
      status: res.data.ResultCode === '0' ? 'COMPLETED' : 'FAILED',
      resultDesc: res.data.ResultDesc,
    };
  }

  // Process STK callback from Safaricom
  processCallback(body: any): { success: boolean; mpesaRef?: string; phone?: string; amount?: number } {
    const stk = body?.Body?.stkCallback;
    if (!stk) return { success: false };

    if (stk.ResultCode !== 0) {
      this.logger.warn(`STK failed: ${stk.ResultDesc}`);
      return { success: false };
    }

    const items = stk.CallbackMetadata?.Item ?? [];
    const get = (name: string) => items.find((i: any) => i.Name === name)?.Value;

    return {
      success: true,
      mpesaRef: get('MpesaReceiptNumber'),
      phone: get('PhoneNumber')?.toString(),
      amount: get('Amount'),
    };
  }

  private getTimestamp(): string {
    return new Date().toISOString().replace(/[^0-9]/g, '').slice(0, 14);
  }

  private normalizePhone(phone: string): string {
    const d = phone.replace(/\D/g, '');
    if (d.startsWith('0')) return `254${d.slice(1)}`;
    if (d.startsWith('+')) return d.slice(1);
    return d;
  }
}
