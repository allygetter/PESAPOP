import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OnEvent } from '@nestjs/event-emitter';
import * as admin from 'firebase-admin';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseReady = false;

  constructor(private config: ConfigService, private prisma: PrismaService) {
    this.initFirebase();
  }

  private initFirebase() {
    try {
      const serviceAccount = this.config.get('FIREBASE_SERVICE_ACCOUNT');
      if (serviceAccount && !admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert(JSON.parse(serviceAccount)),
        });
        this.firebaseReady = true;
        this.logger.log('Firebase Admin initialized ✓');
      }
    } catch (e) {
      this.logger.warn('Firebase not configured — push notifications disabled.');
    }
  }

  async sendPushToUser(userId: string, title: string, body: string, data?: Record<string, string>) {
    if (!this.firebaseReady) return;
    // In production: store FCM tokens in DB per user, fetch here
    this.logger.debug(`Push → ${userId}: ${title}`);
  }

  async sendPushToTopic(topic: string, title: string, body: string, data?: Record<string, string>) {
    if (!this.firebaseReady) return;
    try {
      await admin.messaging().send({ topic, notification: { title, body }, data });
    } catch (e) {
      this.logger.error('Push failed:', e);
    }
  }

  @OnEvent('sale.created')
  async onSaleCreated(payload: { saleId: string; businessId: string; grandTotal: number }) {
    this.logger.debug(`Sale created: ${payload.saleId} — KES ${payload.grandTotal}`);
    // Could push to business owner's device here
  }

  @OnEvent('inventory.stock_in')
  async onStockIn(payload: { productId: string; qty: number }) {
    this.logger.debug(`Stock in: ${payload.productId} +${payload.qty}`);
  }

  @OnEvent('payment.completed')
  async onPaymentCompleted(payload: { saleId: string; success: boolean; mpesaRef?: string }) {
    if (payload.success) {
      this.logger.debug(`Payment confirmed — M-Pesa ref: ${payload.mpesaRef}`);
    }
  }
}
