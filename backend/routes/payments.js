const express = require('express');
const { authenticateUser } = require('../middleware/auth');
const User = require('../models/User');
const Booking = require('../models/Booking');

const router = express.Router();

// Note: This requires Stripe setup
// For now, this is a template for payment integration

// Create Payment Intent
router.post('/create-intent', authenticateUser, async (req, res) => {
  try {
    const { bookingId, amount, service } = req.body;

    if (!bookingId || !amount) {
      return res.status(400).json({
        success: false,
        error: { message: 'Booking ID and amount are required' }
      });
    }

    // Verify booking belongs to user
    const booking = await Booking.findOne({
      _id: bookingId,
      customerId: req.user.id
    });

    if (!booking) {
      return res.status(404).json({
        success: false,
        error: { message: 'Booking not found' }
      });
    }

    // In production, create Stripe PaymentIntent
    // const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    // const paymentIntent = await stripe.paymentIntents.create({...});

    res.json({
      success: true,
      message: 'Payment intent created',
      clientSecret: 'temp_secret' // Replace with actual Stripe secret
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Confirm Payment
router.post('/confirm', authenticateUser, async (req, res) => {
  try {
    const { bookingId, paymentIntentId } = req.body;

    if (!bookingId || !paymentIntentId) {
      return res.status(400).json({
        success: false,
        error: { message: 'Booking ID and payment intent ID are required' }
      });
    }

    // Verify payment with Stripe
    // In production: verify against Stripe API

    // Update booking
    const booking = await Booking.findOneAndUpdate(
      {
        _id: bookingId,
        customerId: req.user.id
      },
      {
        isPaid: true,
        transactionId: paymentIntentId,
        status: 'confirmed'
      },
      { new: true }
    );

    if (!booking) {
      return res.status(404).json({
        success: false,
        error: { message: 'Booking not found' }
      });
    }

    // Update user subscription if needed
    const user = await User.findById(req.user.id);
    if (!user.isSubscriptionActive) {
      user.isSubscriptionActive = true;
      user.subscriptionTier = 'basic';
      user.subscriptionStartDate = new Date();
      user.subscriptionEndDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days
      await user.save();
    }

    res.json({
      success: true,
      message: 'Payment confirmed successfully',
      booking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Get Payment History
router.get('/history', authenticateUser, async (req, res) => {
  try {
    const bookings = await Booking.find({
      customerId: req.user.id,
      isPaid: true
    }).select('service serviceName price currency transactionId bookingDate').lean();

    res.json({
      success: true,
      count: bookings.length,
      payments: bookings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

module.exports = router;
