# PESAPOP AI — Backend API

NestJS + PostgreSQL + Redis backend powering the PESAPOP Flutter app.

## Quick Start (Local Dev)

```bash
# 1. Install dependencies
npm install

# 2. Copy env file and fill in your keys
cp .env.example .env

# 3. Start Postgres + Redis
docker compose -f ../pesapop_infra/docker-compose.yml up postgres redis -d

# 4. Run migrations + seed data
npx prisma migrate dev --name init
npm run prisma:seed

# 5. Start API
npm run start:dev
# API running at http://localhost:4000/api/v1
```

## Test the API

```bash
# Request OTP (any 6-digit code works in dev)
curl -X POST http://localhost:4000/api/v1/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+254712000001"}'

# Verify OTP (use 123456 in dev)
curl -X POST http://localhost:4000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+254712000001", "code": "123456"}'

# Get products (use token from above)
curl http://localhost:4000/api/v1/products \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/request-otp` | Send OTP to phone |
| POST | `/auth/verify-otp` | Verify OTP, get tokens |
| POST | `/auth/register` | Register new business |
| POST | `/auth/refresh` | Refresh access token |
| GET  | `/auth/me` | Get current user |
| GET  | `/products` | List products |
| POST | `/products` | Create product |
| GET  | `/products/low-stock` | Low stock alerts |
| GET  | `/products/barcode/:code` | Find by barcode |
| POST | `/sales` | Create sale |
| GET  | `/sales` | List sales |
| GET  | `/sales/summary/today` | Today's stats |
| GET  | `/inventory` | Stock levels |
| POST | `/inventory/stock-in` | Add stock |
| POST | `/inventory/adjust` | Adjust stock |
| POST | `/inventory/transfer` | Transfer between branches |
| GET  | `/inventory/stats` | Inventory summary |
| POST | `/payments/mpesa/stk` | Initiate M-Pesa STK push |
| POST | `/payments/mpesa/callback` | Safaricom callback (no auth) |
| GET  | `/analytics/dashboard` | Owner dashboard stats |
| GET  | `/analytics/profit-loss` | P&L report |
| GET  | `/customers` | List customers |
| POST | `/customers` | Create customer |
| POST | `/ai/chat` | Chat with PESA AI |

## Production Deploy

```bash
# On your server (after running server_setup.sh)
cd /opt/pesapop
cp docker-compose.yml .
cp .env.production .env

# Start everything
docker compose up -d

# Check logs
docker compose logs -f api
```

## M-Pesa Setup

1. Register at https://developer.safaricom.co.ke
2. Create app, get Consumer Key + Secret
3. Set callback URL to `https://api.pesapop.africa/api/v1/payments/mpesa/callback`
4. Go live by submitting for production credentials

## Africa's Talking (SMS/OTP)

1. Register at https://africastalking.com
2. Get API Key and username
3. In production, set `AT_USERNAME` to your actual username (not `sandbox`)
