# 🎨 Thamar Counselling - Complete System Documentation

**Production-Ready Therapy Booking Platform**

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Getting Started](#getting-started)
3. [Project Structure](#project-structure)
4. [Features](#features)
5. [Deployment](#deployment)
6. [Testing](#testing)
7. [Support](#support)

---

## 🏗️ System Overview

### Architecture

```
FRONTEND (Client)
├── HTML/CSS/JavaScript (thamar-counselling.html)
├── Responsive design (mobile, tablet, desktop)
└── Booking modal with 5-step flow

    ↓ (API Calls via Fetch)

BACKEND (Node.js/Express)
├── REST API endpoints
├── Authentication (JWT)
├── Booking management
├── Availability engine
├── Payment processing (Stripe)
└── Email notifications (SendGrid)

    ↓ (Database queries)

DATABASE (MongoDB)
├── Users (registration, profiles)
├── Bookings (sessions, status)
├── Contacts (inquiry forms)
└── Availability (time slots)
```

### Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | HTML5, CSS3, Vanilla JavaScript | ES6+ |
| Backend | Node.js, Express.js | 16.x LTS, 4.18+ |
| Database | MongoDB, Mongoose ORM | 5.x+, 7.0+ |
| Authentication | JSON Web Tokens (JWT) | jsonwebtoken 9.0+ |
| Security | bcryptjs, Helmet, CORS | Latest |
| Payments | Stripe API | REST v1 |
| Email | SendGrid API | v3 |
| SMS/Chat | Twilio API | v9+ |
| Hosting | Heroku, Railway, AWS, DigitalOcean | Various |

---

## 🚀 Getting Started

### For Development (Local Setup)

#### Prerequisites
- Node.js 16+ installed
- MongoDB running locally or Atlas account
- Git for version control

#### Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/Antonio-el-Bear/thamar-counselling.git
   cd thamar-counselling
   ```

2. **Backend Setup**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Edit .env with your MongoDB URI
   npm start
   # Server runs on http://localhost:5000
   ```

3. **Frontend Setup**
   ```bash
   # Open thamar-counselling.html in your browser
   # Update API_BASE_URL to: http://localhost:5000/api
   ```

4. **Test Booking Flow**
   - Click "✦ Book" button
   - Select service, date, time
   - Confirm booking
   - Check backend logs for confirmation

### For Production (Heroku Deployment)

See `QUICK_START.md` for 5-minute setup or `SETUP_GUIDES.md` for detailed instructions.

---

## 📁 Project Structure

```
thamar-counselling/
├── thamar-counselling.html         # Main frontend (857 lines)
│   ├── Hero section (responsive design)
│   ├── Services showcase
│   ├── How it works
│   ├── Testimonials
│   ├── Booking modal (5-step process)
│   ├── Contact form
│   └── Footer
│
├── img/
│   └── thamar.jpeg                 # Therapist profile image
│
├── backend/                        # Node.js/Express backend
│   ├── server.js                   # App initialization
│   ├── package.json                # Dependencies (18 prod)
│   ├── .env.example                # Configuration template
│   ├── .gitignore                  # Standard Node ignores
│   │
│   ├── models/                     # MongoDB schemas
│   │   ├── User.js                 # User registration, auth
│   │   ├── Booking.js              # Session bookings
│   │   └── Contact.js              # Contact form submissions
│   │
│   ├── routes/                     # API endpoints
│   │   ├── auth.js                 # Register, login, refresh
│   │   ├── bookings.js             # CRUD operations
│   │   ├── availability.js         # Slot generation
│   │   ├── users.js                # Profile management
│   │   ├── contact.js              # Contact form
│   │   └── payments.js             # Stripe integration
│   │
│   ├── middleware/                 # Custom middleware
│   │   ├── auth.js                 # JWT verification
│   │   ├── errorHandler.js         # Error handling
│   │   └── requestLogger.js        # Request logging
│   │
│   ├── API_DOCUMENTATION.md        # Full API reference
│   ├── DEPLOYMENT_GUIDE.md         # Deploy to 5 platforms
│   └── README.md                   # Backend setup
│
├── QUICK_START.md                  # 5-minute setup guide
├── SETUP_GUIDES.md                 # Complete setup (8 steps)
├── PRODUCTION_CHECKLIST.md         # Pre-launch checklist
├── SERVICE_CONFIGURATION.md        # Service setup guides
├── deploy-heroku.ps1               # PowerShell deployment
├── deploy-heroku.sh                # Bash deployment
├── test-api.ps1                    # API testing suite
├── README.md                        # This file
└── CONTRIBUTING.md                 # Contribution guidelines
```

---

## ✨ Features

### Core Functionality
✅ **Professional Website**
- Responsive design (mobile, tablet, desktop)
- Beautiful hero section with call-to-action
- Services showcased with icons
- How-it-works process explanation
- Client testimonials
- Contact information

✅ **Booking System**
- 5-step booking modal flow
- Service selection (6 types)
- Date picker with calendar
- Time slot selection
- Real-time availability (from backend)
- Booking confirmation email
- WhatsApp notification integration

✅ **Authentication**
- User registration with email validation
- Secure login with JWT tokens
- Token refresh mechanism
- Password hashing with bcryptjs
- Role-based access control

✅ **Availability Management**
- Smart slot generation
- Opening hours: 9 AM - 6 PM
- Lunch break: 12 PM - 1 PM
- Service duration consideration
- Buffer time between sessions
- Paid customer priority booking

✅ **Payment Processing**
- Stripe payment integration hooks
- Payment intent creation
- Webhook handling
- Payment history tracking
- Refund support (ready)

✅ **Notifications**
- Email confirmations (SendGrid)
- SMS/WhatsApp messages (Twilio)
- Appointment reminders
- Admin notifications

### Advanced Features
🔒 **Security**
- JWT authentication
- CORS protection
- Rate limiting
- Input validation
- SQL/NoSQL injection protection
- Helmet security headers
- SSL/HTTPS support

📊 **Scalability**
- MongoDB indexing for performance
- Stateless API design
- Horizontal scaling ready
- Load balancer compatible
- CDN support

🔍 **Monitoring**
- Request logging with timestamps
- Error tracking
- Performance metrics
- Database query monitoring
- Health check endpoint

---

## 📦 Deployment

### Quick Deploy (Heroku)
```bash
# 1. Create Heroku app
heroku create thamar-counselling-api

# 2. Set environment variables
heroku config:set MONGODB_URI="your_mongodb_uri"
heroku config:set JWT_SECRET="your_jwt_secret"
# ... set other variables

# 3. Deploy
git push heroku main

# 4. Check it's working
heroku logs --tail
```

### Supported Platforms
- ✅ **Heroku** (easiest, recommended for beginners)
- ✅ **Railway.app** (modern alternative)
- ✅ **DigitalOcean** (more control, self-managed)
- ✅ **AWS Elastic Beanstalk** (enterprise scale)
- ✅ **Docker** (any cloud provider)

See `SETUP_GUIDES.md` for platform-specific instructions.

---

## 🧪 Testing

### Automated Test Suite
```bash
# Test all API endpoints
.\test-api.ps1

# Enter backend URL when prompted
# Tests:
# ✓ Health endpoint
# ✓ User registration
# ✓ User login
# ✓ Get profile
# ✓ Available slots
# ✓ Create booking
# ✓ Get bookings
# ✓ Contact form
```

### Manual Testing

**Test 1: Health Check**
```bash
curl https://api.yourdomain.com/health
# Expected: {"status":"ok"}
```

**Test 2: Create Booking**
1. Open `thamar-counselling.html`
2. Click "✦ Book" button
3. Select service → Select date → Select time
4. Enter email and name
5. Confirm booking
6. Check email for confirmation

**Test 3: Payment (Stripe)**
Use test card: `4242 4242 4242 4242`
Any future expiry and CVC

---

## 📊 API Reference

### Base URL
- Development: `http://localhost:5000/api`
- Production: `https://thamar-counselling-api.herokuapp.com/api`

### Authentication
All endpoints except `/auth/register` and `/auth/login` require JWT token:
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
```

### Main Endpoints

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | `/auth/register` | ❌ | Create account |
| POST | `/auth/login` | ❌ | Login user |
| GET | `/auth/me` | ✅ | Get current user |
| POST | `/auth/refresh` | ✅ | Refresh token |
| POST | `/bookings` | ✅ | Create booking |
| GET | `/bookings` | ✅ | Get user bookings |
| GET | `/availability/slots/:date/:service` | ✅ | Get available times |
| GET | `/users/profile` | ✅ | Get user profile |
| PUT | `/users/profile` | ✅ | Update profile |
| POST | `/contact` | ❌ | Submit contact form |
| POST | `/payments/create-intent` | ✅ | Create payment |

Full API documentation: See `backend/API_DOCUMENTATION.md` in GitHub repository.

---

## 🔐 Security Considerations

### Implemented
✅ JWT token authentication
✅ Password hashing with bcryptjs
✅ CORS protection
✅ Rate limiting (100 requests/15 minutes)
✅ Input validation with Joi
✅ Helmet security headers
✅ SQL/NoSQL injection protection
✅ HTTPS/SSL support

### Before Production
- [ ] Set strong JWT_SECRET (32+ characters)
- [ ] Enable MongoDB authentication
- [ ] Configure CORS for specific domains
- [ ] Setup SSL certificate
- [ ] Enable database backups
- [ ] Monitor error logs
- [ ] Test security with tools like OWASP ZAP

---

## 📈 Performance Optimization

### Frontend
- Lazy loading for images
- CSS minification
- JavaScript optimization
- Responsive design (reduces bandwidth)
- Service worker ready

### Backend
- Database indexing on frequently queried fields
- Response caching
- Gzip compression
- Request batching
- Connection pooling

### Infrastructure
- CDN for static assets
- Load balancing
- Auto-scaling configuration
- Database replication

---

## 🆘 Troubleshooting

### Common Issues

**"Cannot connect to API"**
```bash
# Check backend is running
heroku ps -a thamar-counselling-api

# Check logs
heroku logs --tail -a thamar-counselling-api

# Verify MongoDB connection
# Check MONGODB_URI in environment variables
```

**"Booking fails with 401 Unauthorized"**
```bash
# JWT token likely expired or invalid
# Solution: Call /auth/refresh endpoint to get new token
```

**"Email not sending"**
```bash
# Verify SendGrid API key is set
heroku config | grep SENDGRID

# Check SendGrid dashboard for failures
# Verify sender email is authenticated
```

**"Stripe payment failed"**
```bash
# Use test card: 4242 4242 4242 4242
# Check Stripe webhook configuration
# Verify webhook secret in environment
```

---

## 📚 Documentation Files

| File | Purpose | Read When |
|------|---------|-----------|
| `QUICK_START.md` | 5-minute setup | Just getting started |
| `SETUP_GUIDES.md` | Detailed 8-step setup | Doing full deployment |
| `PRODUCTION_CHECKLIST.md` | Pre-launch verification | Before going live |
| `SERVICE_CONFIGURATION.md` | Service setup (Stripe, SendGrid, etc.) | Setting up services |
| `backend/API_DOCUMENTATION.md` | Complete API reference | Integrating with API |
| `backend/DEPLOYMENT_GUIDE.md` | Platform-specific deploy | Choosing deployment method |

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📞 Support

### Getting Help
1. Check documentation files provided
2. Review `SETUP_GUIDES.md` troubleshooting section
3. Check backend logs: `heroku logs --tail`
4. Review GitHub Issues
5. Check API documentation: `backend/API_DOCUMENTATION.md`

### Issues
- **Email not working?** → Check `SERVICE_CONFIGURATION.md` SendGrid section
- **Payment not processing?** → Check `SERVICE_CONFIGURATION.md` Stripe section
- **Booking not saving?** → Check MongoDB connection in logs
- **API endpoint returning 500?** → Check `heroku logs --tail`

---

## 📄 License

This project is © 2025 Thamar Counselling. All rights reserved.

---

## 🎉 Success Checklist

Before launching, ensure:
- [ ] Backend deployed and responding
- [ ] Frontend API URL updated
- [ ] Booking modal working end-to-end
- [ ] Email notifications sending
- [ ] Payment processing ready (or placeholder working)
- [ ] SMS/WhatsApp ready (or placeholder working)
- [ ] Security checklist completed
- [ ] Error logging working
- [ ] Monitoring setup
- [ ] Backup strategy in place

---

## 📊 Project Stats

- **Frontend**: 857 lines HTML/CSS/JavaScript
- **Backend**: 19 files, 3000+ lines of code
- **API Endpoints**: 15+ RESTful endpoints
- **Database Schemas**: 3 models (User, Booking, Contact)
- **Middleware**: 3 custom middleware functions
- **Services**: Stripe, SendGrid, Twilio ready
- **Deployment**: 5 platforms supported
- **Documentation**: 5 comprehensive guides
- **Tests**: Complete test suite included

---

## 🚀 Ready to Launch?

Your Thamar Counselling booking platform is **production-ready**!

Follow `QUICK_START.md` to deploy in 60 minutes and start accepting bookings.

**Questions?** See the relevant documentation file or check logs with `heroku logs --tail`

**Everything is in place. Let's go live!** 🎉

---

**Last Updated**: February 17, 2026  
**Repository**: https://github.com/Antonio-el-Bear/thamar-couselling  
**Status**: ✅ Production Ready
