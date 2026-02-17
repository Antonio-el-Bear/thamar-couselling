# Thamar Counselling - Backend API

Professional backend API for Thamar Counselling booking system with authentication, payments, and availability management.

## 📁 Project Structure

```
backend/
├── models/                 # Database schemas
│   ├── User.js            # User model (customers, therapists)
│   ├── Booking.js         # Booking model
│   └── Contact.js         # Contact form submissions
├── routes/                # API routes
│   ├── auth.js            # Authentication endpoints
│   ├── bookings.js        # Booking management
│   ├── availability.js    # Time slot availability
│   ├── users.js           # User profile management
│   ├── contact.js         # Contact form
│   └── payments.js        # Payment processing
├── middleware/            # Custom middleware
│   ├── auth.js            # JWT authentication
│   ├── errorHandler.js    # Error handling
│   └── requestLogger.js   # Request logging
├── server.js              # Express app setup
├── package.json           # Dependencies
├── .env.example           # Environment template
├── API_DOCUMENTATION.md   # Full API docs
└── DEPLOYMENT_GUIDE.md    # Deployment instructions
```

## 🚀 Quick Start

### 1. Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 2. Configure Environment

**Essential variables:**
```env
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/thamar_counselling
JWT_SECRET=your_very_secure_secret_key_min_32_chars
PORT=5000
NODE_ENV=development
```

### 3. Start Development Server

```bash
# Development with auto-reload
npm run dev

# Production
npm start
```

Server runs on `http://localhost:5000`

## 🔗 API Quick Links

- **Auth**: `POST /api/auth/register` - Create account
- **Auth**: `POST /api/auth/login` - Login
- **Bookings**: `POST /api/bookings` - Create booking
- **Bookings**: `GET /api/bookings` - List your bookings
- **Availability**: `GET /api/availability/dates/:service` - Get available dates
- **Contact**: `POST /api/contact` - Submit contact form

See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for complete API reference.

## 💡 Key Features

✅ **User Management**
- Authentication with JWT
- User registration & login
- Profile management
- Password change

✅ **Booking System**
- Create, read, update, cancel bookings
- Smart time slot allocation
- Paid vs. free customer priority
- Recurring sessions support

✅ **Availability**
- Real-time slot availability
- Service-based durations
- Operating hours management
- Lunch break handling

✅ **Payment Processing**
- Stripe integration ready
- Payment confirmation
- Transaction tracking
- Subscription management

✅ **Security**
- JWT authentication
- Rate limiting
- CORS protection
- Input validation
- Error handling

## 🗄️ Database

### Setup MongoDB

**Cloud (Recommended):**
1. Create MongoDB Atlas account
2. Create free cluster
3. Get connection string
4. Add to `.env`

**Local:**
```bash
# Install MongoDB
# macOS
brew install mongodb-community

# Start MongoDB
mongod
```

## 📦 Dependencies

- **express** - Web framework
- **mongoose** - MongoDB ODM
- **jsonwebtoken** - JWT auth
- **bcryptjs** - Password hashing
- **cors** - Cross-origin support
- **helmet** - Security headers
- **dotenv** - Environment management
- **stripe** - Payment processing
- **nodemailer** - Email sending
- **twilio** - SMS/WhatsApp

## 🧪 Testing

```bash
# Run tests (when implemented)
npm test

# Test specific endpoint
curl http://localhost:5000/health
```

## 🚢 Deployment

### Heroku (Recommended for beginners)

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create thamar-counselling-api

# Set variables
heroku config:set MONGODB_URI=...
heroku config:set JWT_SECRET=...

# Deploy
git push heroku main
```

### Other Options
- Railway.app (easiest)
- DigitalOcean
- AWS EC2
- Google Cloud
- Azure

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed instructions.

## 🔐 Environment Variables

See `.env.example` for all available configurations:
- Database connection
- JWT settings
- Email configuration
- Payment keys
- SMS/WhatsApp
- CORS settings
- Rate limiting

## 📚 API Documentation

For complete API reference, see [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

Includes:
- All endpoints
- Request/response examples
- Authentication
- Error codes
- Database schema

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Cannot connect to MongoDB | Check MONGODB_URI and network access |
| JWT token error | Verify JWT_SECRET is set |
| CORS blocked | Update CORS_ORIGIN in .env |
| Port already in use | Change PORT or kill process on 5000 |
| Email not sending | Verify EMAIL credentials |

## 📧 Support

For issues or questions:
- Email: info@thamarcounselling.com
- GitHub Issues: [thamar-couselling](https://github.com/Antonio-el-Bear/thamar-couselling/issues)

## 📄 License

© 2025 Thamar Counselling. All rights reserved.

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Last Updated:** February 17, 2026
