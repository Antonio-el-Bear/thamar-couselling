const express = require('express');
const Booking = require('../models/Booking');
const User = require('../models/User');
const { authenticateUser } = require('../middleware/auth');

const router = express.Router();

const SERVICE_INFO = {
  family: { name: 'Family Counselling', duration: 60 },
  individual: { name: 'Individual Therapy', duration: 50 },
  student: { name: 'Student Support', duration: 50 },
  child: { name: 'Child & Youth Therapy', duration: 40 },
  addiction: { name: 'Addiction Recovery', duration: 60 },
  coaching: { name: 'Life Stabilization & Coaching', duration: 50 }
};

// Create Booking
router.post('/', authenticateUser, async (req, res) => {
  try {
    const { service, bookingDate, startTime, sessionType, customerType } = req.body;

    // Validation
    if (!service || !bookingDate || !startTime) {
      return res.status(400).json({
        success: false,
        error: { message: 'Service, date, and time are required' }
      });
    }

    // Get user details
    const user = await User.findById(req.user.id);

    // Check if slot is available
    const existingBooking = await Booking.findOne({
      bookingDate: new Date(bookingDate),
      startTime,
      status: { $in: ['confirmed', 'pending'] }
    });

    if (existingBooking) {
      return res.status(409).json({
        success: false,
        error: { message: 'This time slot is already booked' }
      });
    }

    // Create booking
    const booking = new Booking({
      customerId: req.user.id,
      service,
      serviceName: SERVICE_INFO[service].name,
      sessionDuration: SERVICE_INFO[service].duration,
      bookingDate: new Date(bookingDate),
      startTime,
      endTime: calculateEndTime(startTime, SERVICE_INFO[service].duration),
      sessionType: sessionType || 'in-person',
      customerType: customerType || 'new',
      email: user.email,
      phone: user.phone,
      status: 'pending'
    });

    const savedBooking = await booking.save();

    // Send confirmation notification (implement email/SMS)
    // sendBookingConfirmation(user, savedBooking);

    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      booking: savedBooking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Get User's Bookings
router.get('/', authenticateUser, async (req, res) => {
  try {
    const { status, sort } = req.query;

    let query = { customerId: req.user.id };

    if (status) {
      query.status = status;
    }

    const bookings = await Booking.find(query)
      .sort({ bookingDate: sort === 'asc' ? 1 : -1 })
      .lean();

    res.json({
      success: true,
      count: bookings.length,
      bookings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Get Booking Details
router.get('/:id', authenticateUser, async (req, res) => {
  try {
    const booking = await Booking.findOne({
      _id: req.params.id,
      customerId: req.user.id
    });

    if (!booking) {
      return res.status(404).json({
        success: false,
        error: { message: 'Booking not found' }
      });
    }

    res.json({
      success: true,
      booking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Update Booking
router.put('/:id', authenticateUser, async (req, res) => {
  try {
    const booking = await Booking.findOne({
      _id: req.params.id,
      customerId: req.user.id
    });

    if (!booking) {
      return res.status(404).json({
        success: false,
        error: { message: 'Booking not found' }
      });
    }

    if (!booking.canBeRescheduled()) {
      return res.status(400).json({
        success: false,
        error: { message: 'This booking cannot be rescheduled' }
      });
    }

    const { bookingDate, startTime } = req.body;

    // Check if new slot is available
    const conflict = await Booking.findOne({
      _id: { $ne: req.params.id },
      bookingDate: new Date(bookingDate),
      startTime,
      status: { $in: ['confirmed', 'pending'] }
    });

    if (conflict) {
      return res.status(409).json({
        success: false,
        error: { message: 'New time slot is not available' }
      });
    }

    booking.bookingDate = new Date(bookingDate);
    booking.startTime = startTime;
    booking.endTime = calculateEndTime(startTime, booking.sessionDuration);
    booking.status = 'pending';

    await booking.save();

    res.json({
      success: true,
      message: 'Booking rescheduled successfully',
      booking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Cancel Booking
router.delete('/:id', authenticateUser, async (req, res) => {
  try {
    const booking = await Booking.findOne({
      _id: req.params.id,
      customerId: req.user.id
    });

    if (!booking) {
      return res.status(404).json({
        success: false,
        error: { message: 'Booking not found' }
      });
    }

    if (!booking.canBeCancelled()) {
      return res.status(400).json({
        success: false,
        error: { message: 'This booking cannot be cancelled' }
      });
    }

    booking.status = 'cancelled';
    booking.cancelledAt = new Date();
    booking.cancellationReason = req.body.reason || 'Customer requested cancellation';

    await booking.save();

    res.json({
      success: true,
      message: 'Booking cancelled successfully',
      booking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Helper function to calculate end time
function calculateEndTime(startTime, durationMinutes) {
  const [hours, minutes] = startTime.split(':').map(Number);
  const totalMinutes = hours * 60 + minutes + durationMinutes;
  const endHours = Math.floor(totalMinutes / 60);
  const endMinutes = totalMinutes % 60;
  
  return `${String(endHours).padStart(2, '0')}:${String(endMinutes).padStart(2, '0')}`;
}

module.exports = router;
