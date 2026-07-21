#!/bin/bash
# PESAPOP Server Setup Script
# Run once on a fresh Ubuntu 22.04 VPS
# Usage: curl -fsSL https://raw.githubusercontent.com/.../server_setup.sh | bash

set -euo pipefail
echo "🚀 Setting up PESAPOP server..."

# ── Update system ────────────────────────────────
apt-get update && apt-get upgrade -y
apt-get install -y curl wget git ufw fail2ban

# ── Install Docker ───────────────────────────────
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USER
systemctl enable docker

# ── Install Docker Compose ───────────────────────
apt-get install -y docker-compose-plugin

# ── Firewall ─────────────────────────────────────
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# ── Create app directory ─────────────────────────
mkdir -p /opt/pesapop/nginx/ssl
cd /opt/pesapop

# ── SSL with Let's Encrypt ───────────────────────
apt-get install -y certbot
# Run this manually after DNS is pointed:
# certbot certonly --standalone -d api.pesapop.africa --email admin@pesapop.africa --agree-tos
# Then symlink:
# ln -s /etc/letsencrypt/live/api.pesapop.africa/fullchain.pem /opt/pesapop/nginx/ssl/fullchain.pem
# ln -s /etc/letsencrypt/live/api.pesapop.africa/privkey.pem /opt/pesapop/nginx/ssl/privkey.pem

# ── Auto-renew SSL ───────────────────────────────
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet && docker compose -f /opt/pesapop/docker-compose.yml restart nginx") | crontab -

echo "✅ Server setup complete!"
echo "Next steps:"
echo "  1. Copy docker-compose.yml and nginx/ to /opt/pesapop/"
echo "  2. Create /opt/pesapop/.env with your secrets"
echo "  3. Point DNS → this server IP"
echo "  4. Run: certbot certonly --standalone -d api.pesapop.africa"
echo "  5. Run: docker compose up -d"
