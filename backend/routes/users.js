const express = require('express');
const User = require('../models/User');
const { authenticateUser, authorizeRole } = require('../middleware/auth');

const router = express.Router();

// Get User Profile
router.get('/profile', authenticateUser, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: { message: 'User not found' }
      });
    }

    res.json({
      success: true,
      user: user.getPublicProfile()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Update User Profile
router.put('/profile', authenticateUser, async (req, res) => {
  try {
    const { firstName, lastName, phone, serviceInterest, preferredCommunication } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        firstName: firstName || undefined,
        lastName: lastName || undefined,
        phone: phone || undefined,
        serviceInterest: serviceInterest || undefined,
        preferredCommunication: preferredCommunication || undefined,
        updatedAt: new Date()
      },
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: user.getPublicProfile()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Change Password
router.post('/change-password', authenticateUser, async (req, res) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;

    if (!currentPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({
        success: false,
        error: { message: 'All password fields are required' }
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        error: { message: 'New passwords do not match' }
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        error: { message: 'Password must be at least 6 characters' }
      });
    }

    const user = await User.findById(req.user.id).select('+password');

    // Verify current password
    const isPasswordValid = await user.comparePassword(currentPassword);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: { message: 'Current password is incorrect' }
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Get Subscription Status
router.get('/subscription', authenticateUser, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    res.json({
      success: true,
      subscription: {
        isActive: user.isSubscriptionActive,
        tier: user.subscriptionTier,
        startDate: user.subscriptionStartDate,
        endDate: user.subscriptionEndDate
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

// Update Notification Preferences
router.put('/preferences', authenticateUser, async (req, res) => {
  try {
    const { receiveNotifications, preferredCommunication } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        receiveNotifications: receiveNotifications !== undefined ? receiveNotifications : undefined,
        preferredCommunication: preferredCommunication || undefined
      },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Preferences updated successfully',
      user: user.getPublicProfile()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: error.message }
    });
  }
});

module.exports = router;
