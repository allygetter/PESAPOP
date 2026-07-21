# =========================
# Builder stage
# =========================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Generate Prisma client
RUN npx prisma generate

# Build NestJS
RUN npm run build


# =========================
# Production stage
# =========================
FROM node:20-alpine AS production

WORKDIR /app

# Install OpenSSL (fixes Prisma warning)
RUN apk add --no-cache openssl

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy built app and Prisma files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY prisma ./prisma

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nestjs -u 1001

# Give ownership of the app directory to nestjs
RUN chown -R nestjs:nodejs /app

USER nestjs

EXPOSE 10000

# IMPORTANT: use generated client directly (no prisma generate here)

CMD ["node", "dist/src/main.js"]
