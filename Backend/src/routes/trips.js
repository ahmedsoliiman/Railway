const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');

// @route   GET /api/tours
// @desc    Get available tours (public)
// @access  Public
router.get('/', tripController.getAllTrips);

// @route   GET /api/tours/:id
// @desc    Get tour details
// @access  Public
router.get('/:id', tripController.getTripById);

module.exports = router;
