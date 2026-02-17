const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Basic Information
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
    minlength: 2
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
    minlength: 2
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email']
  },
  phone: {
    type: String,
    required: [true, 'Phone number is required'],
    trim: true
  },
  
  // Account Information
  password: {
    type: String,
    minlength: 6,
    select: false // Don't return password by default
  },
  userType: {
    type: String,
    enum: ['customer', 'therapist', 'admin'],
    default: 'customer'
  },
  
  // Customer Information
  serviceInterest: String,
  medicalHistory: String,
  emergencyContact: {
    name: String,
    phone: String,
    relationship: String
  },
  
  // Subscription/Payment
  isSubscriptionActive: {
    type: Boolean,
    default: false
  },
  subscriptionTier: {
    type: String,
    enum: ['free', 'basic', 'premium'],
    default: 'free'
  },
  subscriptionStartDate: Date,
  subscriptionEndDate: Date,
  stripeCustomerId: String,
  
  // Status
  isVerified: {
    type: Boolean,
    default: false
  },
  verificationToken: String,
  
  // Preferences
  preferredCommunication: {
    type: String,
    enum: ['email', 'sms', 'whatsapp'],
    default: 'email'
  },
  receiveNotifications: {
    type: Boolean,
    default: true
  },
  
  // Metadata
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  lastLogin: Date,
  
  // Administrative
  isActive: {
    type: Boolean,
    default: true
  },
  notes: String
}, {
  timestamps: true
});

// Indexes for faster queries
userSchema.index({ email: 1 });
userSchema.index({ phone: 1 });
userSchema.index({ createdAt: -1 });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare passwords
userSchema.methods.comparePassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Method to get public profile
userSchema.methods.getPublicProfile = function() {
  const userObject = this.toObject();
  delete userObject.password;
  delete userObject.verificationToken;
  delete userObject.stripeCustomerId;
  return userObject;
};

module.exports = mongoose.model('User', userSchema);
