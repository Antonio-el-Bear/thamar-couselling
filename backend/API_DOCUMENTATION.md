# Thamar Counselling - Backend Documentation

## 🚀 Backend API for Thamar Counselling Booking System

Complete production-ready backend for the Thamar Counselling website with booking management, user authentication, and payment processing.

---

## 📋 Table of Contents

1. [Setup & Installation](#setup--installation)
2. [Environment Configuration](#environment-configuration)
3. [API Endpoints](#api-endpoints)
4. [Database Schema](#database-schema)
5. [Authentication](#authentication)
6. [Deployment](#deployment)
7. [Payment Integration](#payment-integration)
8. [Email Notifications](#email-notifications)

---

## 🔧 Setup & Installation

### Prerequisites
- Node.js >= 16.x
- MongoDB (local or Atlas)
- Stripe Account (for payments)
- SendGrid/Gmail (for emails)
- Twilio Account (for SMS/WhatsApp)

### Installation Steps

1. **Clone and navigate to backend directory:**
```bash
cd backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Create `.env` file:**
```bash
cp .env.example .env
```

4. **Fill in environment variables** (see Configuration section)

5. **Start development server:**
```bash
npm run dev
```

The server will start on `http://localhost:5000`

---

## ⚙️ Environment Configuration

### MongoDB Setup

**Option 1: MongoDB Atlas (Cloud)**
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/thamar_counselling?retryWrites=true&w=majority
```

**Option 2: Local MongoDB**
```bash
# Install MongoDB Community Edition
# Start MongoDB service
mongod

# In .env:
MONGODB_URI=mongodb://localhost:27017/thamar_counselling
```

### JWT Configuration
```env
JWT_SECRET=your_very_secure_random_secret_key_min_32_chars
JWT_EXPIRE=7d
```

### Email Configuration (Gmail)
```env
EMAIL_SERVICE=gmail
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=app_password_not_regular_password
EMAIL_FROM=noreply@thamarcounselling.com
```

### Twilio (WhatsApp/SMS)
```env
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890
TWILIO_WHATSAPP_NUMBER=+1234567890
```

### Stripe
```env
STRIPE_PUBLIC_KEY=pk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

---

## 📡 API Endpoints

### Authentication

#### Register
```http
POST /api/auth/register
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "password": "securepassword123",
  "confirmPassword": "securepassword123",
  "service": "individual"
}

Response (201):
{
  "success": true,
  "message": "Registration successful",
  "user": {...},
  "token": "eyJhbGc..."
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword123"
}

Response (200):
{
  "success": true,
  "message": "Login successful",
  "user": {...},
  "token": "eyJhbGc..."
}
```

#### Get Current User
```http
GET /api/auth/me
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "user": {...}
}
```

### Bookings

#### Create Booking
```http
POST /api/bookings
Authorization: Bearer {token}
Content-Type: application/json

{
  "service": "individual",
  "bookingDate": "2026-02-20",
  "startTime": "10:00",
  "sessionType": "in-person",
  "customerType": "new"
}

Response (201):
{
  "success": true,
  "message": "Booking created successfully",
  "booking": {...}
}
```

#### Get User's Bookings
```http
GET /api/bookings?status=confirmed&sort=desc
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "count": 3,
  "bookings": [...]
}
```

#### Get Booking Details
```http
GET /api/bookings/:bookingId
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "booking": {...}
}
```

#### Reschedule Booking
```http
PUT /api/bookings/:bookingId
Authorization: Bearer {token}
Content-Type: application/json

{
  "bookingDate": "2026-02-25",
  "startTime": "14:00"
}

Response (200):
{
  "success": true,
  "message": "Booking rescheduled successfully",
  "booking": {...}
}
```

#### Cancel Booking
```http
DELETE /api/bookings/:bookingId
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "Schedule conflict"
}

Response (200):
{
  "success": true,
  "message": "Booking cancelled successfully",
  "booking": {...}
}
```

### Availability

#### Get Available Slots for Date
```http
GET /api/availability/slots/2026-02-20/individual?customerType=new

Response (200):
{
  "success": true,
  "date": "2026-02-20",
  "service": "individual",
  "duration": 50,
  "availableSlots": ["09:00", "10:00", "14:00", "15:00"],
  "bookedSlots": ["11:00", "13:00"],
  "totalSlots": 8,
  "freeSlots": 4
}
```

#### Get Available Dates
```http
GET /api/availability/dates/individual

Response (200):
{
  "success": true,
  "service": "individual",
  "availableDates": [
    {
      "date": "2026-02-18",
      "dayOfWeek": "Wednesday",
      "availableSlots": 5
    }
  ],
  "totalDaysWithAvailability": 20
}
```

### Users

#### Get Profile
```http
GET /api/users/profile
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "user": {...}
}
```

#### Update Profile
```http
PUT /api/users/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "firstName": "newFirstName",
  "phone": "+1234567890",
  "preferredCommunication": "email"
}

Response (200):
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {...}
}
```

#### Change Password
```http
POST /api/users/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "currentPassword": "oldpassword",
  "newPassword": "newpassword123",
  "confirmPassword": "newpassword123"
}

Response (200):
{
  "success": true,
  "message": "Password changed successfully"
}
```

### Contact Form

#### Submit Contact
```http
POST /api/contact
Content-Type: application/json

{
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "jane@example.com",
  "phone": "+1234567890",
  "service": "family",
  "message": "I would like to inquire about family counselling services..."
}

Response (201):
{
  "success": true,
  "message": "Thank you for reaching out! We will get back to you soon.",
  "contactId": "..."
}
```

### Payments

#### Create Payment Intent
```http
POST /api/payments/create-intent
Authorization: Bearer {token}
Content-Type: application/json

{
  "bookingId": "...",
  "amount": 50,
  "service": "individual"
}

Response (200):
{
  "success": true,
  "message": "Payment intent created",
  "clientSecret": "..."
}
```

#### Confirm Payment
```http
POST /api/payments/confirm
Authorization: Bearer {token}
Content-Type: application/json

{
  "bookingId": "...",
  "paymentIntentId": "pi_..."
}

Response (200):
{
  "success": true,
  "message": "Payment confirmed successfully",
  "booking": {...}
}
```

---

## 🗄️ Database Schema

### Users Collection
```javascript
{
  firstName: String,
  lastName: String,
  email: String (unique),
  phone: String,
  password: String (hashed),
  userType: 'customer' | 'therapist' | 'admin',
  isSubscriptionActive: Boolean,
  subscriptionTier: 'free' | 'basic' | 'premium',
  subscriptionStartDate: Date,
  subscriptionEndDate: Date,
  isVerified: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Bookings Collection
```javascript
{
  customerId: ObjectId,
  service: 'family' | 'individual' | 'student' | 'child' | 'addiction' | 'coaching',
  serviceName: String,
  sessionDuration: Number,
  bookingDate: Date,
  startTime: String (HH:mm),
  sessionType: 'in-person' | 'virtual' | 'phone',
  customerType: 'new' | 'existing' | 'paid',
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled',
  isPaid: Boolean,
  price: Number,
  transactionId: String,
  email: String,
  phone: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Contacts Collection
```javascript
{
  firstName: String,
  lastName: String,
  email: String,
  phone: String,
  service: String,
  message: String,
  status: 'new' | 'read' | 'responded' | 'spam',
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication.

### How It Works

1. **Register/Login** → Receive JWT token
2. **Include token** in Authorization header: `Authorization: Bearer {token}`
3. **Token expires** after 7 days (configurable)
4. **Refresh token** via `/api/auth/refresh`

### Example Usage

```javascript
// JavaScript fetch
const headers = {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${token}`
};

fetch('/api/bookings', { method: 'GET', headers })
  .then(res => res.json())
  .then(data => console.log(data));
```

---

## 🚀 Deployment

### Heroku

1. **Create Procfile:**
```
web: node server.js
```

2. **Deploy:**
```bash
heroku login
heroku create thamar-counselling-api
git push heroku main
```

3. **Set environment variables:**
```bash
heroku config:set MONGODB_URI=...
heroku config:set JWT_SECRET=...
```

### Railway/Render

1. Connect GitHub repository
2. Set environment variables in dashboard
3. Deploy automatically on push

### DigitalOcean / AWS / Azure

See detailed deployment guides in `/backend/docs/deployment/`

---

## 💳 Payment Integration

### Stripe Setup

1. **Create Stripe account** and get API keys
2. **Add to .env:**
```env
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

3. **Process payment:**
```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const paymentIntent = await stripe.paymentIntents.create({
  amount: 5000, // $50 in cents
  currency: 'usd',
  payment_method_types: ['card']
});
```

---

## 📧 Email Notifications

### Setup SendGrid (Recommended)

```env
EMAIL_SERVICE=sendgrid
SENDGRID_API_KEY=SG....
```

### Email Events

- ✅ Welcome email on registration
- ✅ Booking confirmation
- ✅ 24-hour reminder before session
- ✅ Session completion follow-up
- ✅ Payment receipts

---

## 📝 Creating Backups

```bash
# MongoDB backup
mongodump --uri="mongodb+srv://..." --out=./backup

# Restore
mongorestore ./backup
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| MongoDB connection failed | Check MONGODB_URI in .env |
| JWT token expired | Use /api/auth/refresh endpoint |
| Payment not processing | Verify Stripe keys and webhook |
| Emails not sending | Check EMAIL credentials |
| CORS errors | Update CORS_ORIGIN in .env |

---

## 📚 Additional Resources

- [MongoDB Manual](https://docs.mongodb.com/)
- [Stripe Documentation](https://stripe.com/docs)
- [Express.js Guide](https://expressjs.com/)
- [JWT.io](https://jwt.io/)

---

**Version:** 1.0.0  
**Last Updated:** February 17, 2026
