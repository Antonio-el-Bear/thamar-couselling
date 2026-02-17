const express = require('express');
const Contact = require('../models/Contact');

const router = express.Router();

// Submit Contact Form
router.post('/', async (req, res) => {
  try {
    const { firstName, lastName, email, phone, service, message } = req.body;

    // Validation
    if (!firstName || !lastName || !email || !phone || !message) {
      return res.status(400).json({
        success: false,
        error: { message: 'Please provide all required fields' }
      });
    }

    if (message.length < 10) {
      return res.status(400).json({
        success: false,
        error: { message: 'Message must be at least 10 characters long' }
      });
    }

    // Create contact submission
    const contact = new Contact({
      firstName,
      lastName,
      email,
      phone,
      service: service || 'other',
      message,
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.headers['user-agent'],
      status: 'new'
    });

    await contact.save();

    // Send confirmation email (implement email service)
    // await sendContactConfirmationEmail(email, firstName);

    // Notify admin (implement email service)
    // await sendAdminNotification(contact);

    res.status(201).json({
      success: true,
      message: 'Thank you for reaching out! We will get back to you soon.',
      contactId: contact._id
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Get Contact Submission (for confirmation)
router.get('/:id', async (req, res) => {
  try {
    const contact = await Contact.findById(req.params.id);

    if (!contact) {
      return res.status(404).json({
        success: false,
        error: { message: 'Contact submission not found' }
      });
    }

    res.json({
      success: true,
      contact
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

module.exports = router;
