const express = require('express');
const Booking = require('../models/Booking');

const router = express.Router();

const OPERATING_HOURS = {
  start: process.env.OPERATING_HOURS_START || '08:00',
  end: process.env.OPERATING_HOURS_END || '18:00',
  lunchStart: process.env.LUNCH_BREAK_START || '12:00',
  lunchEnd: process.env.LUNCH_BREAK_END || '13:00'
};

const SERVICE_DURATIONS = {
  family: 60,
  individual: 50,
  student: 50,
  child: 40,
  addiction: 60,
  coaching: 50
};

const BUFFER_MINUTES = parseInt(process.env.SESSION_BUFFER_MINUTES || 10);

// Get Available Slots for a Date
router.get('/slots/:date/:service', async (req, res) => {
  try {
    const { date, service } = req.params;
    const { customerType } = req.query;

    // Validate service
    if (!SERVICE_DURATIONS[service]) {
      return res.status(400).json({
        success: false,
        error: { message: 'Invalid service type' }
      });
    }

    // Parse date
    const slotDate = new Date(date);
    if (isNaN(slotDate)) {
      return res.status(400).json({
        success: false,
        error: { message: 'Invalid date format' }
      });
    }

    // Check if date is in the past
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (slotDate < today) {
      return res.status(400).json({
        success: false,
        error: { message: 'Cannot book in the past' }
      });
    }

    // Check if date is a business day (Mon-Sat)
    const dayOfWeek = slotDate.getDay();
    if (dayOfWeek === 0) { // Sunday
      return res.json({
        success: true,
        availableSlots: [],
        message: 'No sessions available on Sunday'
      });
    }

    // Generate available slots
    const availableSlots = generateAvailableSlots(slotDate, service, customerType);

    // Get booked slots for this date
    const bookedSlots = await getBookedSlots(slotDate);

    // Filter out booked slots
    const freeSlots = availableSlots.filter(slot => 
      !bookedSlots.includes(slot)
    );

    res.json({
      success: true,
      date: slotDate.toISOString().split('T')[0],
      service,
      duration: SERVICE_DURATIONS[service],
      availableSlots: freeSlots,
      bookedSlots: bookedSlots,
      totalSlots: availableSlots.length,
      freeSlots: freeSlots.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Get Available Dates (next 30 days)
router.get('/dates/:service', async (req, res) => {
  try {
    const { service } = req.params;

    if (!SERVICE_DURATIONS[service]) {
      return res.status(400).json({
        success: false,
        error: { message: 'Invalid service type' }
      });
    }

    const availableDates = [];
    const today = new Date();

    // Check next 30 days
    for (let i = 0; i < 30; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() + i);

      // Skip Sundays
      if (date.getDay() !== 0) {
        const dateStr = date.toISOString().split('T')[0];
        const slots = await getAvailableSlotsCount(date, service);

        if (slots > 0) {
          availableDates.push({
            date: dateStr,
            dayOfWeek: getDayName(date.getDay()),
            availableSlots: slots
          });
        }
      }
    }

    res.json({
      success: true,
      service,
      availableDates,
      totalDaysWithAvailability: availableDates.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Helper Functions

function generateAvailableSlots(date, service, customerType) {
  const slots = [];
  const duration = SERVICE_DURATIONS[service];
  const [startHour, startMin] = OPERATING_HOURS.start.split(':').map(Number);
  const [endHour, endMin] = OPERATING_HOURS.end.split(':').map(Number);
  const [lunchStartHour, lunchStartMin] = OPERATING_HOURS.lunchStart.split(':').map(Number);
  const [lunchEndHour, lunchEndMin] = OPERATING_HOURS.lunchEnd.split(':').map(Number);

  let currentTime = new Date(date);
  currentTime.setHours(startHour, startMin, 0, 0);

  const endTime = new Date(date);
  endTime.setHours(endHour, endMin, 0, 0);

  const lunchStart = new Date(date);
  lunchStart.setHours(lunchStartHour, lunchStartMin, 0, 0);

  const lunchEnd = new Date(date);
  lunchEnd.setHours(lunchEndHour, lunchEndMin, 0, 0);

  while (currentTime < endTime) {
    // Skip lunch break
    if (currentTime >= lunchStart && currentTime < lunchEnd) {
      currentTime.setMinutes(currentTime.getMinutes() + duration + BUFFER_MINUTES);
      continue;
    }

    // Check if slot fits before end time
    const slotEnd = new Date(currentTime);
    slotEnd.setMinutes(slotEnd.getMinutes() + duration);

    if (slotEnd <= endTime && slotEnd <= lunchStart || currentTime >= lunchEnd) {
      const timeStr = formatTime(currentTime);
      slots.push(timeStr);
    }

    currentTime.setMinutes(currentTime.getMinutes() + duration + BUFFER_MINUTES);
  }

  return slots;
}

async function getBookedSlots(date) {
  const startOfDay = new Date(date);
  startOfDay.setHours(0, 0, 0, 0);

  const endOfDay = new Date(date);
  endOfDay.setHours(23, 59, 59, 999);

  const bookings = await Booking.find({
    bookingDate: {
      $gte: startOfDay,
      $lte: endOfDay
    },
    status: { $in: ['pending', 'confirmed'] }
  }).select('startTime').lean();

  return bookings.map(b => b.startTime);
}

async function getAvailableSlotsCount(date, service) {
  const availableSlots = generateAvailableSlots(date, service);
  const bookedSlots = await getBookedSlots(date);
  const freeSlots = availableSlots.filter(slot => !bookedSlots.includes(slot));
  return freeSlots.length;
}

function formatTime(date) {
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  return `${hours}:${minutes}`;
}

function getDayName(dayIndex) {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return days[dayIndex];
}

module.exports = router;
