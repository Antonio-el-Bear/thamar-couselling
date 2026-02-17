const mongoose = require('mongoose');

const contactSchema = new mongoose.Schema({
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    lowercase: true,
    match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email']
  },
  phone: {
    type: String,
    required: [true, 'Phone number is required']
  },
  service: {
    type: String,
    enum: ['family', 'individual', 'student', 'child', 'addiction', 'coaching', 'other'],
    default: 'other'
  },
  message: {
    type: String,
    required: [true, 'Message is required'],
    minlength: [10, 'Message must be at least 10 characters long'],
    maxlength: [5000, 'Message cannot exceed 5000 characters']
  },
  
  // Processing
  status: {
    type: String,
    enum: ['new', 'read', 'responded', 'spam'],
    default: 'new',
    index: true
  },
  respondedAt: Date,
  respondedBy: mongoose.Schema.Types.ObjectId,
  response: String,
  
  // Metadata
  ipAddress: String,
  userAgent: String,
  
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for admin queries
contactSchema.index({ status: 1, createdAt: -1 });
contactSchema.index({ email: 1 });

module.exports = mongoose.model('Contact', contactSchema);
