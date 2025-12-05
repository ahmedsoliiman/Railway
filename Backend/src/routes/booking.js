const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const validate = require('../middleware/validator');
const { authMiddleware } = require('../middleware/auth');
const bookingController = require('../controllers/bookingController');

// @route   GET /api/user/reservations
// @desc    Get user's reservations
// @access  Private
router.get('/reservations', authMiddleware, bookingController.getUserReservations);

// @route   POST /api/user/reservations
// @desc    Create new reservation
// @access  Private
router.post(
  '/reservations',
  authMiddleware,
  [
    body('tourId').isInt().withMessage('Valid tour ID is required'),
    body('passengerName').trim().notEmpty().withMessage('Passenger name is required'),
    body('passengerNationalId').trim().notEmpty().withMessage('Passenger national ID is required'),
    body('seatClass')
      .isIn(['first', 'second'])
      .withMessage('Seat class must be either first or second'),
  ],
  validate,
  bookingController.createReservation
);

// @route   POST /api/user/reservations/:id/payment
// @desc    Process payment for reservation
// @access  Private
router.post(
  '/reservations/:id/payment',
  authMiddleware,
  [
    body('paymentMethod')
      .isIn(['credit_card', 'cash'])
      .withMessage('Payment method must be credit_card or cash'),
    body('cardNumber')
      .if(body('paymentMethod').equals('credit_card'))
      .trim()
      .notEmpty()
      .withMessage('Card number is required for credit card payment')
      .isLength({ min: 13, max: 19 })
      .withMessage('Invalid card number length'),
    body('cardHolder')
      .if(body('paymentMethod').equals('credit_card'))
      .trim()
      .notEmpty()
      .withMessage('Card holder name is required'),
    body('expiryDate')
      .if(body('paymentMethod').equals('credit_card'))
      .trim()
      .notEmpty()
      .withMessage('Expiry date is required')
      .matches(/^(0[1-9]|1[0-2])\/\d{2}$/)
      .withMessage('Expiry date must be in MM/YY format'),
    body('cvv')
      .if(body('paymentMethod').equals('credit_card'))
      .trim()
      .notEmpty()
      .withMessage('CVV is required')
      .isLength({ min: 3, max: 4 })
      .withMessage('CVV must be 3 or 4 digits'),
  ],
  validate,
  bookingController.processPayment
);

// @route   DELETE /api/user/reservations/:id
// @desc    Cancel reservation
// @access  Private
router.delete('/reservations/:id', authMiddleware, bookingController.cancelReservation);

module.exports = router;
