const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { User } = require('../models');
const emailService = require('../utils/emailService');

// Generate JWT token
const generateToken = (userId, role) => {
  return jwt.sign({ id: userId, role }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
};

// Generate 6-digit verification code
const generateVerificationToken = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// @desc    Register new user
// @route   POST /api/auth/signup
// @access  Public
exports.signup = async (req, res) => {
  try {
    // Accept both camelCase and snake_case
    const fullName = req.body.fullName || req.body.full_name;
    const { email, password } = req.body;

    // Validation
    if (!fullName || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields (fullName, email, password)',
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered',
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Generate verification token
    const verificationToken = generateVerificationToken();
    const verificationTokenExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    // Create user
    const user = await User.create({
      full_name: fullName,
      email,
      password: passwordHash,
      phone: null,
      role: 'user',
      is_verified: false,
      verification_token: verificationToken,
      verification_token_expires: verificationTokenExpires,
    });

    // Send verification email
    try {
      await emailService.sendVerificationEmail(email, fullName, verificationToken);
    } catch (emailError) {
      console.error('Failed to send verification email:', emailError);
    }

    // Generate token
    const token = generateToken(user.id, user.role);

    res.status(201).json({
      success: true,
      message: 'Registration successful! Please check your email to verify your account.',
      data: {
        token,
        user: {
          id: user.id,
          fullName: user.full_name,
          email: user.email,
          role: user.role,
          isVerified: user.is_verified,
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
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password',
      });
    }

    // Check if user exists
    const user = await User.findOne({ where: { email } });
    if (!user) {
      console.log('❌ User not found for email:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    console.log('✅ User found:', { email: user.email, id: user.id, hasPassword: !!user.password });
    console.log('🔑 Provided password:', password);
    console.log('🔒 Stored hash:', user.password);

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    console.log('🔐 Password match result:', isMatch);
    
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Generate token
    const token = generateToken(user.id, user.role);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user.id,
          fullName: user.full_name,
          email: user.email,
          role: user.role,
          isVerified: user.is_verified,
          dateOfBirth: user.date_of_birth,
          nationalId: user.national_id,
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
};

// @desc    Verify email
// @route   GET /api/auth/verify/:token
// @access  Public
exports.verifyEmail = async (req, res) => {
  try {
    const { token } = req.params;

    const user = await User.findOne({
      where: {
        verification_token: token,
      },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired verification token',
      });
    }

    // Check if token expired
    if (user.verification_token_expires < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Verification token has expired',
      });
    }

    // Update user
    await user.update({
      is_verified: true,
      verification_token: null,
      verification_token_expires: null,
    });

    res.json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during verification',
    });
  }
};

// @desc    Verify email with code (POST method)
// @route   POST /api/auth/verify-email
// @access  Public
exports.verifyEmailWithCode = async (req, res) => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: 'Email and verification code are required',
      });
    }

    const user = await User.findOne({
      where: {
        email: email,
        verification_token: code,
      },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid verification code',
      });
    }

    // Check if token expired
    if (user.verification_token_expires < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Verification code has expired',
      });
    }

    // Update user
    await user.update({
      is_verified: true,
      verification_token: null,
      verification_token_expires: null,
    });

    res.json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during verification',
    });
  }
};

// @desc    Resend verification code
// @route   POST /api/auth/resend-code
// @access  Public
exports.resendCode = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required',
      });
    }

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.is_verified) {
      return res.status(400).json({
        success: false,
        message: 'Email already verified',
      });
    }

    // Generate new verification code
    const verificationToken = generateVerificationToken();
    const verificationTokenExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    // Update user with new token
    await user.update({
      verification_token: verificationToken,
      verification_token_expires: verificationTokenExpires,
    });

    // Send verification email
    try {
      await emailService.sendVerificationEmail(email, user.full_name, verificationToken);
      
      res.json({
        success: true,
        message: 'Verification code sent successfully',
      });
    } catch (emailError) {
      console.error('Failed to send verification email:', emailError);
      res.status(500).json({
        success: false,
        message: 'Failed to send verification code',
      });
    }
  } catch (error) {
    console.error('Resend code error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// @desc    Forgot password - send reset code
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email',
      });
    }

    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'No account found with this email',
      });
    }

    // Generate 6-digit reset code
    const resetCode = generateVerificationToken();
    const resetCodeExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Save reset code to user
    await user.update({
      verification_token: resetCode,
      verification_token_expires: resetCodeExpires,
    });

    // Send reset code email
    try {
      await emailService.sendPasswordResetEmail(email, user.full_name, resetCode);
      
      res.json({
        success: true,
        message: 'Password reset code sent to your email',
      });
    } catch (emailError) {
      console.error('Failed to send reset email:', emailError);
      res.status(500).json({
        success: false,
        message: 'Failed to send reset code',
      });
    }
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// @desc    Verify reset code
// @route   POST /api/auth/verify-reset-code
// @access  Public
exports.verifyResetCode = async (req, res) => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and code',
      });
    }

    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.verification_token !== code) {
      return res.status(400).json({
        success: false,
        message: 'Invalid reset code',
      });
    }

    if (new Date() > user.verification_token_expires) {
      return res.status(400).json({
        success: false,
        message: 'Reset code has expired',
      });
    }

    res.json({
      success: true,
      message: 'Code verified successfully',
    });
  } catch (error) {
    console.error('Verify reset code error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// @desc    Reset password
// @route   POST /api/auth/reset-password
// @access  Public
exports.resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email, code, and new password',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters',
      });
    }

    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.verification_token !== code) {
      return res.status(400).json({
        success: false,
        message: 'Invalid reset code',
      });
    }

    if (new Date() > user.verification_token_expires) {
      return res.status(400).json({
        success: false,
        message: 'Reset code has expired',
      });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(newPassword, salt);

    // Update password and clear reset token
    await user.update({
      password: passwordHash,
      verification_token: null,
      verification_token_expires: null,
    });

    res.json({
      success: true,
      message: 'Password reset successful',
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: ['id', 'full_name', 'email', 'phone', 'role', 'is_verified', 'created_at'],
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      data: {
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isVerified: user.is_verified,
        createdAt: user.created_at,
      },
    });
  } catch (error) {
    console.error('Get me error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
