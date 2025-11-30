const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const db = require('../config/database');
const validate = require('../middleware/validator');
const { authMiddleware, verifiedUserMiddleware } = require('../middleware/auth');
const { sendBookingConfirmation } = require('../utils/emailService');

// Apply auth middleware to all routes
router.use(authMiddleware, verifiedUserMiddleware);

// @route   GET /api/profile
// @desc    Get user profile
// @access  Private
router.get('/profile', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, full_name, email, phone, role, is_verified, created_at FROM users WHERE id = $1',
      [req.user.id]
    );

    res.json({
      success: true,
      data: { user: result.rows[0] },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/profile
// @desc    Update user profile
// @access  Private
router.put(
  '/profile',
  [
    body('full_name').optional().trim().notEmpty(),
    body('phone').optional().isMobilePhone(),
  ],
  validate,
  async (req, res) => {
    try {
      const { full_name, phone } = req.body;

      const result = await db.query(
        `UPDATE users 
         SET full_name = COALESCE($1, full_name),
             phone = COALESCE($2, phone),
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $3 
         RETURNING id, full_name, email, phone, role, is_verified`,
        [full_name, phone, req.user.id]
      );

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: { user: result.rows[0] },
      });
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// @route   GET /api/tours
// @desc    Browse available tours
// @access  Private
router.get('/tours', async (req, res) => {
  try {
    const { origin, destination, date, seat_class, train_type } = req.query;

    let query = `
      SELECT t.*, 
             tr.name as train_name, tr.train_number, tr.type as train_type, tr.facilities as train_facilities,
             os.name as origin_name, os.city as origin_city,
             ds.name as destination_name, ds.city as destination_city
      FROM tours t
      JOIN trains tr ON t.train_id = tr.id
      JOIN stations os ON t.origin_station_id = os.id
      JOIN stations ds ON t.destination_station_id = ds.id
      WHERE t.status = 'scheduled' 
        AND t.available_seats > 0
        AND t.departure_time > NOW()
    `;

    const params = [];
    let paramCount = 0;

    if (origin) {
      paramCount++;
      query += ` AND t.origin_station_id = $${paramCount}`;
      params.push(origin);
    }

    if (destination) {
      paramCount++;
      query += ` AND t.destination_station_id = $${paramCount}`;
      params.push(destination);
    }

    if (date) {
      paramCount++;
      query += ` AND DATE(t.departure_time) = $${paramCount}`;
      params.push(date);
    }

    if (train_type) {
      paramCount++;
      query += ` AND LOWER(tr.type) = LOWER($${paramCount})`;
      params.push(train_type);
    }

    query += ' ORDER BY t.departure_time ASC';

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: { 
        tours: result.rows,
        count: result.rows.length 
      },
    });
  } catch (error) {
    console.error('Get tours error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/tours/:id
// @desc    Get tour details
// @access  Private
router.get('/tours/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT t.*, 
              tr.name as train_name, tr.train_number, tr.type as train_type, 
              tr.total_seats, tr.first_class_seats, tr.second_class_seats,
              tr.facilities as train_facilities,
              os.name as origin_name, os.city as origin_city, os.address as origin_address,
              ds.name as destination_name, ds.city as destination_city, ds.address as destination_address
       FROM tours t
       JOIN trains tr ON t.train_id = tr.id
       JOIN stations os ON t.origin_station_id = os.id
       JOIN stations ds ON t.destination_station_id = ds.id
       WHERE t.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Tour not found',
      });
    }

    res.json({
      success: true,
      data: { tour: result.rows[0] },
    });
  } catch (error) {
    console.error('Get tour error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/stations
// @desc    Get all stations
// @access  Private
router.get('/stations', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, name, city, address FROM stations ORDER BY city, name'
    );

    res.json({
      success: true,
      data: { stations: result.rows },
    });
  } catch (error) {
    console.error('Get stations error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/reservations
// @desc    Book a tour
// @access  Private
router.post(
  '/reservations',
  [
    body('tour_id').isInt().withMessage('Tour ID is required'),
    body('seat_class').isIn(['first', 'second']).withMessage('Invalid seat class'),
    body('number_of_seats').isInt({ min: 1, max: 10 }).withMessage('Number of seats must be between 1 and 10'),
  ],
  validate,
  async (req, res) => {
    const client = await db.pool.connect();

    try {
      await client.query('BEGIN');

      const { tour_id, seat_class, number_of_seats } = req.body;

      // Get tour details with lock
      const tourResult = await client.query(
        `SELECT t.*, 
                tr.name as train_name,
                os.name as origin_name,
                ds.name as destination_name
         FROM tours t
         JOIN trains tr ON t.train_id = tr.id
         JOIN stations os ON t.origin_station_id = os.id
         JOIN stations ds ON t.destination_station_id = ds.id
         WHERE t.id = $1 FOR UPDATE`,
        [tour_id]
      );

      if (tourResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({
          success: false,
          message: 'Tour not found',
        });
      }

      const tour = tourResult.rows[0];

      // Check availability
      if (tour.available_seats < number_of_seats) {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          message: `Only ${tour.available_seats} seats available`,
        });
      }

      // Check if tour is in the future
      if (new Date(tour.departure_time) < new Date()) {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          message: 'Cannot book past tours',
        });
      }

      // Calculate price
      const pricePerSeat = seat_class === 'first' ? tour.first_class_price : tour.second_class_price;
      const totalPrice = pricePerSeat * number_of_seats;

      // Generate booking reference
      const bookingReference = 'BK' + Date.now().toString().slice(-8) + Math.floor(Math.random() * 1000);

      // Create reservation
      const reservationResult = await client.query(
        `INSERT INTO reservations (user_id, tour_id, seat_class, number_of_seats, total_price, booking_reference, status) 
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [req.user.id, tour_id, seat_class, number_of_seats, totalPrice, bookingReference, 'confirmed']
      );

      // Update available seats
      await client.query(
        'UPDATE tours SET available_seats = available_seats - $1 WHERE id = $2',
        [number_of_seats, tour_id]
      );

      await client.query('COMMIT');

      const reservation = reservationResult.rows[0];

      // Send confirmation email
      try {
        const userResult = await db.query('SELECT full_name, email FROM users WHERE id = $1', [req.user.id]);
        const user = userResult.rows[0];

        await sendBookingConfirmation(user.email, user.full_name, {
          reference: bookingReference,
          trainName: tour.train_name,
          origin: tour.origin_name,
          destination: tour.destination_name,
          departure: new Date(tour.departure_time).toLocaleString(),
          seatClass: seat_class === 'first' ? 'First Class' : 'Second Class',
          seats: number_of_seats,
          price: totalPrice.toFixed(2),
        });
      } catch (emailError) {
        console.error('Email sending failed:', emailError);
      }

      res.status(201).json({
        success: true,
        message: 'Booking confirmed successfully',
        data: { 
          reservation,
          tour_details: {
            train_name: tour.train_name,
            origin: tour.origin_name,
            destination: tour.destination_name,
            departure_time: tour.departure_time,
            arrival_time: tour.arrival_time,
          }
        },
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Create reservation error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during booking',
      });
    } finally {
      client.release();
    }
  }
);

// @route   GET /api/reservations
// @desc    Get user's reservations
// @access  Private
router.get('/reservations', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT r.*, 
              t.departure_time, t.arrival_time, t.status as tour_status,
              tr.name as train_name, tr.train_number,
              os.name as origin_name, os.city as origin_city,
              ds.name as destination_name, ds.city as destination_city
       FROM reservations r
       JOIN tours t ON r.tour_id = t.id
       JOIN trains tr ON t.train_id = tr.id
       JOIN stations os ON t.origin_station_id = os.id
       JOIN stations ds ON t.destination_station_id = ds.id
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC`,
      [req.user.id]
    );

    res.json({
      success: true,
      data: { 
        reservations: result.rows,
        count: result.rows.length 
      },
    });
  } catch (error) {
    console.error('Get reservations error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/reservations/:id
// @desc    Get reservation details
// @access  Private
router.get('/reservations/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT r.*, 
              t.departure_time, t.arrival_time, t.status as tour_status,
              tr.name as train_name, tr.train_number, tr.facilities as train_facilities,
              os.name as origin_name, os.city as origin_city, os.address as origin_address,
              ds.name as destination_name, ds.city as destination_city, ds.address as destination_address
       FROM reservations r
       JOIN tours t ON r.tour_id = t.id
       JOIN trains tr ON t.train_id = tr.id
       JOIN stations os ON t.origin_station_id = os.id
       JOIN stations ds ON t.destination_station_id = ds.id
       WHERE r.id = $1 AND r.user_id = $2`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Reservation not found',
      });
    }

    res.json({
      success: true,
      data: { reservation: result.rows[0] },
    });
  } catch (error) {
    console.error('Get reservation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/reservations/:id
// @desc    Cancel reservation
// @access  Private
router.delete('/reservations/:id', async (req, res) => {
  const client = await db.pool.connect();

  try {
    await client.query('BEGIN');

    const { id } = req.params;

    // Get reservation
    const reservationResult = await client.query(
      'SELECT * FROM reservations WHERE id = $1 AND user_id = $2 FOR UPDATE',
      [id, req.user.id]
    );

    if (reservationResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Reservation not found',
      });
    }

    const reservation = reservationResult.rows[0];

    if (reservation.status === 'cancelled') {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: 'Reservation already cancelled',
      });
    }

    // Check if tour is in the future (at least 2 hours before departure)
    const tourResult = await client.query('SELECT departure_time FROM tours WHERE id = $1', [
      reservation.tour_id,
    ]);
    const departureTime = new Date(tourResult.rows[0].departure_time);
    const twoHoursBeforeDeparture = new Date(departureTime.getTime() - 2 * 60 * 60 * 1000);

    if (new Date() > twoHoursBeforeDeparture) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: 'Cannot cancel reservation less than 2 hours before departure',
      });
    }

    // Update reservation status
    await client.query('UPDATE reservations SET status = $1 WHERE id = $2', ['cancelled', id]);

    // Return seats to tour
    await client.query(
      'UPDATE tours SET available_seats = available_seats + $1 WHERE id = $2',
      [reservation.number_of_seats, reservation.tour_id]
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      message: 'Reservation cancelled successfully',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Cancel reservation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  } finally {
    client.release();
  }
});

module.exports = router;
