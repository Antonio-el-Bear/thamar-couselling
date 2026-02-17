# Thamar Counselling Backend Deployment Guide

## 🚀 Pre-Deployment Checklist

- [ ] All environment variables configured
- [ ] MongoDB database created and tested
- [ ] Stripe account with keys
- [ ] Email service configured (SendGrid/Gmail)
- [ ] Twilio account for SMS/WhatsApp
- [ ] Node.js version compatible (>=16.0.0)
- [ ] All dependencies installed
- [ ] Local tests passing
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Rate limiting enabled

---

## 🌐 Deployment Options

### 1. Heroku (Easiest)

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create thamar-counselling-api

# Add MongoDB Atlas URI
heroku config:set MONGODB_URI=your_mongodb_uri

# Add other env vars
heroku config:set JWT_SECRET=your_secret
heroku config:set STRIPE_SECRET_KEY=your_key
# ... add all env variables

# Deploy
git push heroku main

# View logs
heroku logs --tail
```

### 2. Railway.app (Simple & Fast)

1. Connect GitHub repository
2. Create new project
3. Connect MongoDB plugin
4. Add environment variables:
   - MONGODB_URI (auto-added by plugin)
   - JWT_SECRET
   - STRIPE_SECRET_KEY
   - All other variables from .env
5. Deploy on push

### 3. DigitalOcean App Platform

1. Create new app
2. Connect GitHub
3. Select backend folder as source
4. Add env variables
5. Add managed database for MongoDB
6. Deploy

### 4. AWS EC2 + MongoDB Atlas

```bash
# SSH into EC2
ssh -i key.pem ubuntu@your-instance-ip

# Install Node.js
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install nodejs

# Clone repository
git clone https://github.com/your-repo.git
cd thamar-counselling/backend

# Install dependencies
npm install

# Create .env file
nano .env
# Add all environment variables

# Install PM2 (process manager)
npm install -g pm2

# Start application
pm2 start server.js --name "thamar-api"
pm2 startup
pm2 save

# Install Nginx as reverse proxy
sudo apt-get install nginx
# Configure nginx to proxy_pass to localhost:5000

# Setup SSL with Let's Encrypt
sudo apt-get install certbot python3-certbot-nginx
sudo certbot certonly --nginx -d your-domain.com
```

### 5. Docker Deployment

Create `Dockerfile`:
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 5000

CMD ["node", "server.js"]
```

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "5000:5000"
    environment:
      - MONGODB_URI=${MONGODB_URI}
      - JWT_SECRET=${JWT_SECRET}
      - NODE_ENV=production
    depends_on:
      - mongodb

  mongodb:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}

volumes:
  mongo_data:
```

Deploy:
```bash
docker-compose up -d
```

---

## 🔒 Production Security Checklist

### Environment Variables
```env
NODE_ENV=production
JWT_SECRET=very_long_secure_random_string_at_least_32_chars
CORS_ORIGIN=https://thamarcounselling.com
```

### Database Security
- [ ] Enable MongoDB Atlas IP whitelist
- [ ] Use strong password for MongoDB
- [ ] Enable MongoDB encryption
- [ ] Regular backups enabled
- [ ] Use MongoDB Atlas backups

### API Security
- [ ] HTTPS/SSL enabled
- [ ] Rate limiting configured
- [ ] CORS properly restricted
- [ ] Helmet security headers enabled
- [ ] Input validation on all endpoints
- [ ] SQL/NoSQL injection prevention

### Payment Security
- [ ] Stripe webhook signatures verified
- [ ] PCI-DSS compliant
- [ ] No credit card data stored locally
- [ ] Encrypted payment tokens

---

## 📊 Monitoring & Logging

### Setup PM2 Monitoring
```bash
npm install -g pm2
pm2 install pm2-logrotate
pm2 monit
```

### Sentry Error Tracking
```bash
npm install @sentry/node

# In server.js:
const Sentry = require("@sentry/node");
Sentry.init({ dsn: process.env.SENTRY_DSN });
```

### Datadog Monitoring
```bash
npm install node-dogstatsd

# Monitor API performance, errors, database queries
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd backend && npm install
      - run: npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Heroku
        uses: AkhileshNS/heroku-deploy@v3.12.13
        with:
          heroku_api_key: ${{ secrets.HEROKU_API_KEY }}
          heroku_app_name: "thamar-counselling-api"
          heroku_email: ${{ secrets.HEROKU_EMAIL }}
          appdir: "backend"
```

---

## 📈 Performance Optimization

### Database Indexing
```javascript
// Already included in models for:
userSchema.index({ email: 1 });
bookingSchema.index({ bookingDate: 1, startTime: 1 });
```

### Caching Strategy
```bash
npm install redis
```

### CDN Setup
- Use CloudFlare for static assets
- Cache API responses appropriately
- Use gzip compression

---

## 🆘 Troubleshooting Production Issues

### High Memory Usage
```bash
# Check process memory
pm2 monit

# Increase Node memory limit
pm2 start server.js --max-memory-restart 500M
```

### Database Connection Issues
```bash
# Check MongoDB Atlas connectivity
mongostat --uri="mongodb+srv://..."
```

### API Timeout Issues
- Increase request timeout
- Optimize database queries
- Check for memory leaks

### SSL Certificate Issues
```bash
# Check certificate expiry (Let's Encrypt auto-renews)
openssl x509 -in /etc/letsencrypt/live/domain/cert.pem -text -noout
```

---

## 📞 Support Email & Setup

For production deployment support:
- Email: info@thamarcounselling.com
- GitHub: https://github.com/Antonio-el-Bear/thamar-couselling

---

**Last Updated:** February 17, 2026
