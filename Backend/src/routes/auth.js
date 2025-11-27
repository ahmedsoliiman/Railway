const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body } = require('express-validator');
const db = require('../config/database');
const validate = require('../middleware/validator');
const { authMiddleware } = require('../middleware/auth');
const { sendVerificationEmail } = require('../utils/emailService');

// Generate random 6-digit code
const generateVerificationCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// @route   POST /api/auth/signup
// @desc    Register new user
// @access  Public
router.post(
  '/signup',
  [
    body('full_name').trim().notEmpty().withMessage('Full name is required'),
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .withMessage('Password must contain uppercase, lowercase, and number'),
    body('phone').optional().isMobilePhone().withMessage('Invalid phone number'),
  ],
  validate,
  async (req, res) => {
    try {
      const { full_name, email, password, phone } = req.body;

      // Check if user already exists
      const existingUser = await db.query(
        'SELECT id FROM users WHERE email = $1',
        [email.toLowerCase()]
      );

      if (existingUser.rows.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Email already registered',
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert user
      const result = await db.query(
        `INSERT INTO users (full_name, email, password, phone) 
         VALUES ($1, $2, $3, $4) 
         RETURNING id, full_name, email, phone, role, is_verified`,
        [full_name, email.toLowerCase(), hashedPassword, phone]
      );

      const user = result.rows[0];

      // Generate verification code
      const verificationCode = generateVerificationCode();
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

      // Store verification code
      await db.query(
        'INSERT INTO email_verifications (user_id, verification_code, expires_at) VALUES ($1, $2, $3)',
        [user.id, verificationCode, expiresAt]
      );

      // Send verification email
      try {
        await sendVerificationEmail(email, full_name, verificationCode);
      } catch (emailError) {
        console.error('Email sending failed:', emailError);
        // Continue even if email fails
      }

      res.status(201).json({
        success: true,
        message: 'Registration successful! Please check your email for verification code.',
        data: {
          user: {
            id: user.id,
            full_name: user.full_name,
            email: user.email,
            phone: user.phone,
            is_verified: user.is_verified,
          },
        },
      });
    } catch (error) {
      console.error('Signup error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during registration',
      });
    }
  }
);

// @route   POST /api/auth/verify-email
// @desc    Verify email with code
// @access  Public
router.post(
  '/verify-email',
  [
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('code').isLength({ min: 6, max: 6 }).withMessage('Invalid verification code'),
  ],
  validate,
  async (req, res) => {
    try {
      const { email, code } = req.body;

      // Get user
      const userResult = await db.query(
        'SELECT id, is_verified FROM users WHERE email = $1',
        [email.toLowerCase()]
      );

      if (userResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      const user = userResult.rows[0];

      if (user.is_verified) {
        return res.status(400).json({
          success: false,
          message: 'Email already verified',
        });
      }

      // Check verification code
      const verificationResult = await db.query(
        `SELECT id, expires_at FROM email_verifications 
         WHERE user_id = $1 AND verification_code = $2 
         ORDER BY created_at DESC LIMIT 1`,
        [user.id, code]
      );

      if (verificationResult.rows.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Invalid verification code',
        });
      }

      const verification = verificationResult.rows[0];

      // Check if expired
      if (new Date() > new Date(verification.expires_at)) {
        return res.status(400).json({
          success: false,
          message: 'Verification code expired. Please request a new one.',
        });
      }

      // Update user as verified
      await db.query('UPDATE users SET is_verified = true WHERE id = $1', [user.id]);

      // Delete used verification code
      await db.query('DELETE FROM email_verifications WHERE id = $1', [verification.id]);

      res.json({
        success: true,
        message: 'Email verified successfully! You can now login.',
      });
    } catch (error) {
      console.error('Verification error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during verification',
      });
    }
  }
);

// @route   POST /api/auth/resend-code
// @desc    Resend verification code
// @access  Public
router.post(
  '/resend-code',
  [body('email').isEmail().withMessage('Please provide a valid email')],
  validate,
  async (req, res) => {
    try {
      const { email } = req.body;

      const userResult = await db.query(
        'SELECT id, full_name, is_verified FROM users WHERE email = $1',
        [email.toLowerCase()]
      );

      if (userResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      const user = userResult.rows[0];

      if (user.is_verified) {
        return res.status(400).json({
          success: false,
          message: 'Email already verified',
        });
      }

      // Generate new code
      const verificationCode = generateVerificationCode();
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

      // Delete old codes
      await db.query('DELETE FROM email_verifications WHERE user_id = $1', [user.id]);

      // Insert new code
      await db.query(
        'INSERT INTO email_verifications (user_id, verification_code, expires_at) VALUES ($1, $2, $3)',
        [user.id, verificationCode, expiresAt]
      );

      // Send email
      await sendVerificationEmail(email, user.full_name, verificationCode);

      res.json({
        success: true,
        message: 'Verification code sent successfully',
      });
    } catch (error) {
      console.error('Resend code error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
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
  async (req, res) => {
    try {
      const { email, password } = req.body;

      // Get user
      const result = await db.query(
        'SELECT * FROM users WHERE email = $1',
        [email.toLowerCase()]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password',
        });
      }

      const user = result.rows[0];

      // Check password
      const isMatch = await bcrypt.compare(password, user.password);

      if (!isMatch) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password',
        });
      }

      // Check if verified
      if (!user.is_verified) {
        return res.status(403).json({
          success: false,
          message: 'Please verify your email before logging in',
          needsVerification: true,
        });
      }

      // Generate JWT
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRE }
      );

      res.json({
        success: true,
        message: 'Login successful',
        data: {
          token,
          user: {
            id: user.id,
            full_name: user.full_name,
            email: user.email,
            phone: user.phone,
            role: user.role,
          },
        },
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during login',
      });
    }
  }
);

// @route   GET /api/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, full_name, email, phone, role, is_verified, created_at FROM users WHERE id = $1',
      [req.user.id]
    );

    res.json({
      success: true,
      data: {
        user: result.rows[0],
      },
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/auth/logout
// @desc    Logout user
// @access  Private
router.post('/logout', authMiddleware, (req, res) => {
  res.json({
    success: true,
    message: 'Logged out successfully',
  });
});

module.exports = router;
