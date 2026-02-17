const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  // Customer Information
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Customer ID is required']
  },
  
  // Session Information
  service: {
    type: String,
    enum: ['family', 'individual', 'student', 'child', 'addiction', 'coaching'],
    required: [true, 'Service type is required']
  },
  serviceName: String,
  sessionDuration: {
    type: Number,
    required: true,
    default: 50
  },
  
  // Booking Details
  bookingDate: {
    type: Date,
    required: [true, 'Booking date is required'],
    index: true
  },
  startTime: {
    type: String,
    required: [true, 'Start time is required'],
    match: [/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format']
  },
  endTime: String,
  
  // Session Type
  sessionType: {
    type: String,
    enum: ['in-person', 'virtual', 'phone'],
    default: 'in-person'
  },
  
  // Customer Type
  customerType: {
    type: String,
    enum: ['new', 'existing', 'paid'],
    default: 'new'
  },
  
  // Status
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'completed', 'cancelled', 'rescheduled', 'no-show'],
    default: 'pending',
    index: true
  },
  
  // Payment
  isPaid: {
    type: Boolean,
    default: false
  },
  paymentMethod: {
    type: String,
    enum: ['credit_card', 'bank_transfer', 'subscription']
  },
  price: Number,
  currency: {
    type: String,
    default: 'USD'
  },
  transactionId: String,
  
  // Contact Information
  email: {
    type: String,
    required: true
  },
  phone: {
    type: String,
    required: true
  },
  
  // Notes & Requests
  customerNotes: String,
  therapistNotes: String,
  specialRequests: String,
  
  // Session Content
  sessionOutcome: String,
  nextSessionDate: Date,
  followUpRequired: Boolean,
  
  // Reminders
  reminderEmailSent: {
    type: Boolean,
    default: false
  },
  reminderSmsSent: {
    type: Boolean,
    default: false
  },
  reminderSentAt: Date,
  
  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  cancelledAt: Date,
  completedAt: Date,
  
  // Additional
  cancellationReason: String,
  feedbackScore: {
    type: Number,
    min: 1,
    max: 5
  },
  feedbackComments: String,
  
  // Recurring Sessions
  isRecurring: {
    type: Boolean,
    default: false
  },
  recurringPattern: {
    type: String,
    enum: ['weekly', 'biweekly', 'monthly']
  },
  recurringEndDate: Date,
  parentBookingId: mongoose.Schema.Types.ObjectId
}, {
  timestamps: true
});

// Indexes
bookingSchema.index({ customerId: 1, bookingDate: -1 });
bookingSchema.index({ bookingDate: 1, startTime: 1 });
bookingSchema.index({ status: 1, bookingDate: 1 });
bookingSchema.index({ createdAt: -1 });

// Virtuals
bookingSchema.virtual('bookingTime').get(function() {
  return `${this.bookingDate.toDateString()} at ${this.startTime}`;
});

// Methods
bookingSchema.methods.canBeCancelled = function() {
  return ['pending', 'confirmed'].includes(this.status);
};

bookingSchema.methods.canBeRescheduled = function() {
  return ['pending', 'confirmed'].includes(this.status) && 
         this.bookingDate > new Date();
};

bookingSchema.methods.isDueForReminder = function() {
  const now = new Date();
  const bookingDateTime = new Date(`${this.bookingDate.toDateString()} ${this.startTime}`);
  const hoursBefore = 24;
  const reminderTime = new Date(bookingDateTime.getTime() - hoursBefore * 60 * 60 * 1000);
  
  return !this.reminderEmailSent && now >= reminderTime && now < bookingDateTime;
};

module.exports = mongoose.model('Booking', bookingSchema);
