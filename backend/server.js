require('dotenv').config();
require('express-async-errors');

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const mongoose = require('mongoose');

// Import routes
const authRoutes = require('./routes/auth');
const bookingRoutes = require('./routes/bookings');
const availabilityRoutes = require('./routes/availability');
const userRoutes = require('./routes/users');
const contactRoutes = require('./routes/contact');
const paymentRoutes = require('./routes/payments');

// Import middleware
const errorHandler = require('./middleware/errorHandler');
const requestLogger = require('./middleware/requestLogger');

const app = express();

// ─────────────────────────────────────
// MIDDLEWARE SETUP
// ─────────────────────────────────────

// Security Headers
app.use(helmet());

// CORS Configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || 900000),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || 100),
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Stricter rate limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts, please try again later.'
});

// Body Parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Logging
app.use(morgan('combined'));
app.use(requestLogger);

// ─────────────────────────────────────
// HEALTH CHECK ENDPOINT
// ─────────────────────────────────────
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});

// ─────────────────────────────────────
// API ROUTES
// ─────────────────────────────────────

// Authentication routes (with stricter rate limiting)
app.use('/api/auth', authLimiter, authRoutes);

// Booking routes
app.use('/api/bookings', bookingRoutes);

// Availability routes
app.use('/api/availability', availabilityRoutes);

// User routes
app.use('/api/users', userRoutes);

// Contact form routes
app.use('/api/contact', contactRoutes);

// Payment routes
app.use('/api/payments', paymentRoutes);

// ─────────────────────────────────────
// 404 HANDLER
// ─────────────────────────────────────
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
    error: {
      code: 'ROUTE_NOT_FOUND',
      path: req.originalUrl
    }
  });
});

// ─────────────────────────────────────
// ERROR HANDLER (Must be last)
// ─────────────────────────────────────
app.use(errorHandler);

// ─────────────────────────────────────
// DATABASE CONNECTION
// ─────────────────────────────────────
const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/thamar_counselling';
    
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ MongoDB connected successfully');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

// ─────────────────────────────────────
// START SERVER
// ─────────────────────────────────────
const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    // Connect to database
    await connectDB();

    // Start listening
    app.listen(PORT, () => {
      console.log(`
╔════════════════════════════════════════╗
║   Thamar Counselling Backend Server    ║
╠════════════════════════════════════════╣
║  🚀 Server running on port ${PORT}
║  🌍 Environment: ${process.env.NODE_ENV}
║  ✅ Database: Connected
║  📡 API: Ready for requests
╚════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  mongoose.connection.close();
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received. Shutting down gracefully...');
  mongoose.connection.close();
  process.exit(0);
});

// Start the server
startServer();

module.exports = app;
