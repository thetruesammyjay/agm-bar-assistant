# AGM BAR - Deployment Guide

## Overview

This guide covers deploying AGM BAR's multi-tenant architecture with subdomain support. The system requires:
- MySQL database with proper indexing
- Redis for caching and sessions
- Wildcard DNS configuration for subdomains
- SSL certificates for all subdomains

---

## Architecture

```
┌─────────────────────────────────────────────┐
│         Cloudflare (DNS + CDN)              │
│         *.agmbar.com → Server IP            │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│              Load Balancer                   │
│         (Nginx / Caddy / Traefik)           │
└─────────────────────────────────────────────┘
         ↓                        ↓
┌──────────────────┐    ┌──────────────────┐
│   Frontend       │    │   Backend API    │
│   (Vercel)       │    │   (Railway)      │
│   Static Site    │    │   FastAPI        │
└──────────────────┘    └──────────────────┘
                               ↓
                    ┌──────────────────┐
                    │   MySQL Database │
                    │   (PlanetScale)  │
                    └──────────────────┘
                               ↓
                    ┌──────────────────┐
                    │   Redis Cache    │
                    │   (Upstash)      │
                    └──────────────────┘
```

---

## Prerequisites

### Domain Setup
1. Purchase domain: `agmbar.com`
2. Point nameservers to Cloudflare
3. Configure wildcard DNS: `*.agmbar.com`

### Services Needed
- **Frontend**: Vercel (free tier)
- **Backend**: Railway / Render / DigitalOcean
- **Database**: PlanetScale / Railway / AWS RDS (MySQL)
- **Redis**: Upstash / Railway
- **DNS/CDN**: Cloudflare (free tier)
- **Email**: SendGrid (free tier)

---

## Step 1: Database Deployment (PlanetScale)

### Create Database

```bash
# Install PlanetScale CLI
brew install planetscale/tap/pscale

# Login
pscale auth login

# Create database
pscale database create agmbar-db --region us-east

# Create branch
pscale branch create agmbar-db main

# Get connection string
pscale connect agmbar-db main
```

### Import Schema

```bash
# Connect to database
mysql -h <host> -u <user> -p<password> <database_name>

# Import schema
source database.sql
```

### PlanetScale Connection String

```
mysql://<user>:<password>@<host>/<database>?ssl={"rejectUnauthorized":true}
```

**For SQLAlchemy**:
```
DATABASE_URL=mysql+pymysql://<user>:<password>@<host>/<database>?charset=utf8mb4
```

---

## Step 2: Redis Deployment (Upstash)

### Create Redis Instance

1. Go to [Upstash Console](https://console.upstash.com)
2. Create new Redis database
3. Select region closest to your backend
4. Copy connection string

**Format**:
```
REDIS_URL=rediss://default:<password>@<host>:6379
```

---

## Step 3: Backend Deployment (Railway)

### Setup Railway Project

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Create new project
railway init

# Link to GitHub repo
railway link
```

### Configure Environment Variables

In Railway dashboard, add these variables:

```bash
# Application
APP_NAME=AGM BAR
ENVIRONMENT=production
DEBUG=False

# Database
DATABASE_URL=mysql+pymysql://user:pass@host/db?charset=utf8mb4

# Redis
REDIS_URL=rediss://default:pass@host:6379

# Security
SECRET_KEY=<generate-with-openssl-rand-hex-32>
JWT_SECRET_KEY=<generate-with-openssl-rand-hex-32>

# AI Keys
GROQ_API_KEY=your-groq-key
GEMINI_API_KEY=your-gemini-key

# CORS
CORS_ORIGINS=https://agmbar.com,https://*.agmbar.com

# Domain
FRONTEND_URL=https://agmbar.com
BACKEND_URL=https://api.agmbar.com

# Notifications
WHATSAPP_ACCESS_TOKEN=your-token
TELEGRAM_BOT_TOKEN=your-token
SENDGRID_API_KEY=your-key
```

### Deploy

```bash
# Deploy from CLI
railway up

# Or connect GitHub repo for auto-deployment
```

### Custom Domain Setup

1. In Railway dashboard, go to Settings → Domains
2. Add custom domain: `api.agmbar.com`
3. Update DNS records as instructed

---

## Step 4: Frontend Deployment (Vercel)

### Setup Vercel Project

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
cd frontend
vercel
```

### Configure Environment Variables

In Vercel dashboard, add:

```bash
VITE_API_URL=https://api.agmbar.com/api/v1
VITE_WS_URL=wss://api.agmbar.com/ws
VITE_APP_NAME=AGM BAR
```

### Custom Domain Setup

1. Go to Project Settings → Domains
2. Add custom domains:
   - `agmbar.com`
   - `www.agmbar.com`
   - `admin.agmbar.com`
   - `*.agmbar.com` (for subdomains)

### Subdomain Handling

Create `vercel.json`:

```json
{
  "rewrites": [
    {
      "source": "/:path*",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        }
      ]
    }
  ]
}
```

---

## Step 5: DNS Configuration (Cloudflare)

### Add DNS Records

| Type  | Name | Content | Proxy |
|-------|------|---------|-------|
| A     | @    | Vercel IP | Yes |
| CNAME | www  | cname.vercel-dns.com | Yes |
| CNAME | api  | Railway URL | Yes |
| CNAME | *    | cname.vercel-dns.com | Yes |

### Wildcard Certificate

Cloudflare automatically provisions SSL for wildcard domains when proxied.

### SSL/TLS Settings

1. Go to SSL/TLS → Overview
2. Set to "Full (strict)"
3. Enable "Always Use HTTPS"
4. Enable "Automatic HTTPS Rewrites"

---

## Step 6: Subdomain Routing

### Backend Middleware

The backend extracts business from subdomain:

```python
# app/middleware/subdomain.py
from fastapi import Request
from app.models import Business

async def get_business_from_subdomain(request: Request):
    host = request.headers.get("host", "")
    subdomain = host.split(".")[0]
    
    # Skip system subdomains
    if subdomain in ["www", "api", "admin"]:
        return None
    
    # Fetch business
    business = await Business.find_by_subdomain(subdomain)
    request.state.business = business
    return business
```

### Frontend Subdomain Detection

```javascript
// src/utils/subdomain.js
export function getSubdomain() {
  const hostname = window.location.hostname;
  const parts = hostname.split('.');
  
  // localhost or IP
  if (parts.length < 3) return null;
  
  const subdomain = parts[0];
  
  // System subdomains
  if (['www', 'admin', 'api'].includes(subdomain)) {
    return null;
  }
  
  return subdomain;
}

export function isBusinessSubdomain() {
  const subdomain = getSubdomain();
  return subdomain !== null;
}
```

### Route Handling

```jsx
// src/App.jsx
import { useEffect, useState } from 'react';
import { getSubdomain, isBusinessSubdomain } from './utils/subdomain';
import BusinessSite from './pages/BusinessSite';
import MainSite from './pages/MainSite';
import AdminDashboard from './pages/AdminDashboard';

function App() {
  const [subdomain, setSubdomain] = useState(getSubdomain());
  
  useEffect(() => {
    setSubdomain(getSubdomain());
  }, []);
  
  // Customer-facing business site
  if (isBusinessSubdomain()) {
    return <BusinessSite subdomain={subdomain} />;
  }
  
  // Admin dashboard
  if (window.location.pathname.startsWith('/admin')) {
    return <AdminDashboard />;
  }
  
  // Main marketing site
  return <MainSite />;
}
```

---

## Step 7: Testing Deployment

### Test Checklist

**Main Site**:
- [ ] `https://agmbar.com` loads
- [ ] `https://www.agmbar.com` redirects to apex
- [ ] SSL certificate is valid

**Admin Dashboard**:
- [ ] `https://admin.agmbar.com` loads
- [ ] Login works
- [ ] Registration creates subdomain

**Business Subdomain**:
- [ ] New business gets unique subdomain
- [ ] `https://{subdomain}.agmbar.com` loads
- [ ] AI personality loads correctly
- [ ] Menu displays
- [ ] Orders work
- [ ] QR codes point to correct subdomain

**API**:
- [ ] `https://api.agmbar.com/docs` loads Swagger
- [ ] Health check: `https://api.agmbar.com/health`
- [ ] CORS works from all domains

### Load Testing

```bash
# Install Apache Bench
brew install ab

# Test API endpoint
ab -n 1000 -c 10 https://api.agmbar.com/api/v1/health

# Test subdomain
ab -n 1000 -c 10 https://demo.agmbar.com/
```

---

## Step 8: Monitoring & Analytics

### Backend Monitoring (Sentry)

```python
# app/main.py
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()],
    traces_sample_rate=1.0,
    environment="production"
)
```

### Frontend Monitoring

```javascript
// src/main.jsx
import * as Sentry from '@sentry/react';

Sentry.init({
  dsn: 'your-sentry-dsn',
  environment: 'production',
  integrations: [new Sentry.BrowserTracing()],
  tracesSampleRate: 1.0,
});
```

### Database Monitoring

- Use PlanetScale Insights
- Set up slow query alerts
- Monitor connection pool usage

### Uptime Monitoring

Use services like:
- UptimeRobot
- Pingdom
- Better Uptime

---

## Step 9: Backup Strategy

### Database Backups

**PlanetScale**:
- Automatic daily backups
- Point-in-time recovery
- Branch-based backups

**Manual Backup**:
```bash
mysqldump -h host -u user -p agmbar_db > backup_$(date +%Y%m%d).sql
```

### Automated Backup Script

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="agmbar_db"

# Backup database
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Upload to S3
aws s3 cp $BACKUP_DIR/backup_$DATE.sql s3://agmbar-backups/

# Keep only last 30 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete
```

### Backup Schedule

Add to crontab:
```bash
0 2 * * * /path/to/backup.sh
```

---

## Step 10: Performance Optimization

### CDN Configuration

**Cloudflare Settings**:
- Enable Brotli compression
- Enable Auto Minify (HTML, CSS, JS)
- Enable Rocket Loader
- Set cache TTL appropriately

### Database Optimization

```sql
-- Add composite indexes for common queries
CREATE INDEX idx_business_subdomain_active ON businesses(subdomain, is_active, deleted_at);
CREATE INDEX idx_orders_business_status_date ON orders(business_id, status, created_at);
CREATE INDEX idx_reservations_business_date ON reservations(business_id, reservation_date);

-- Analyze tables
ANALYZE TABLE businesses, orders, reservations, menu_items;
```

### Redis Caching Strategy

```python
# Cache menu for 5 minutes
@cache(ttl=300, key="menu:{business_id}")
async def get_menu(business_id: str):
    # Database query
    pass

# Cache business profile for 1 hour
@cache(ttl=3600, key="business:{subdomain}")
async def get_business(subdomain: str):
    # Database query
    pass
```

### Frontend Optimization

- Enable code splitting
- Lazy load routes
- Optimize images (WebP format)
- Use CDN for static assets

---

## Step 11: Security Hardening

### API Rate Limiting

```python
# app/main.py
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.get("/api/v1/endpoint")
@limiter.limit("60/minute")
async def endpoint():
    pass
```

### CORS Configuration

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://agmbar.com",
        "https://*.agmbar.com"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Environment Secrets

- Use Railway/Vercel secret management
- Never commit `.env` files
- Rotate API keys regularly
- Use different keys for dev/staging/production

---

## Troubleshooting

### Common Issues

**Subdomain not resolving**:
- Check Cloudflare DNS propagation
- Verify wildcard CNAME record
- Clear browser DNS cache

**Database connection fails**:
- Check connection string format
- Verify SSL settings
- Test with MySQL client

**CORS errors**:
- Verify CORS_ORIGINS includes subdomain pattern
- Check wildcard configuration
- Inspect browser console

**Slow performance**:
- Check database query performance
- Review Redis hit rate
- Monitor CDN cache status

---

## Production Checklist

- [ ] All environment variables configured
- [ ] Database schema imported
- [ ] Sample data removed
- [ ] SSL certificates valid
- [ ] Wildcard DNS configured
- [ ] CORS properly set
- [ ] Rate limiting enabled
- [ ] Monitoring configured
- [ ] Backups automated
- [ ] Error tracking active
- [ ] Load testing completed
- [ ] Security audit done
- [ ] Documentation updated

---

## Scaling Strategy

### Horizontal Scaling

**Backend**:
- Add more Railway instances
- Use load balancer
- Session affinity for WebSockets

**Database**:
- PlanetScale auto-scales
- Add read replicas if needed
- Implement connection pooling

**Redis**:
- Upstash auto-scales
- Consider Redis Cluster for high traffic

### Vertical Scaling

Upgrade instance sizes as needed:
- Railway: Upgrade to Pro plan
- PlanetScale: Upgrade to Scaler plan
- Upstash: Increase connection limit

---

This deployment setup provides a production-ready, scalable infrastructure for AGM BAR's multi-tenant architecture!
