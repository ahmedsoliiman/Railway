const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const validate = require('../middleware/validator');
const { authMiddleware } = require('../middleware/auth');
const authController = require('../controllers/authController');

// @route   POST /api/auth/signup
// @desc    Register new user
// @access  Public
router.post(
  '/signup',
  [
    body('fullName').optional().trim().notEmpty().withMessage('Full name is required'),
    body('full_name').optional().trim().notEmpty().withMessage('Full name is required'),
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
  ],
  validate,
  authController.signup
);

// @route   GET /api/auth/verify/:token
// @desc    Verify email with token (legacy)
// @access  Public
router.get('/verify/:token', authController.verifyEmail);

// @route   POST /api/auth/verify-email
// @desc    Verify email with code
// @access  Public
router.post(
  '/verify-email',
  [
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('code').notEmpty().withMessage('Verification code is required'),
  ],
  validate,
  authController.verifyEmailWithCode
);

// @route   POST /api/auth/resend-code
// @desc    Resend verification code
// @access  Public
router.post(
  '/resend-code',
  [
    body('email').isEmail().withMessage('Please provide a valid email'),
  ],
  validate,
  authController.resendCode
);

// @route   POST /api/auth/login
// @desc    Login user
// @access  Public
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  authController.login
);

// @route   GET /api/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', authMiddleware, authController.getMe);

// @route   POST /api/auth/logout
// @desc    Logout user (client-side token removal)
// @access  Private
router.post('/logout', authMiddleware, (req, res) => {
  res.json({
    success: true,
    message: 'Logged out successfully',
  });
});

module.exports = router;
