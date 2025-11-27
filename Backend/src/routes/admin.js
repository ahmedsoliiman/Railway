const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const db = require('../config/database');
const validate = require('../middleware/validator');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

// Apply auth and admin middleware to all routes
router.use(authMiddleware, adminMiddleware);

// ============ STATIONS MANAGEMENT ============

// @route   GET /api/admin/stations
// @desc    Get all stations
// @access  Admin
router.get('/stations', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM stations ORDER BY created_at DESC'
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

// @route   POST /api/admin/stations
// @desc    Create station
// @access  Admin
router.post(
  '/stations',
  [
    body('name').trim().notEmpty().withMessage('Station name is required'),
    body('city').trim().notEmpty().withMessage('City is required'),
    body('address').optional().trim(),
    body('latitude').optional().isFloat(),
    body('longitude').optional().isFloat(),
    body('facilities').optional().trim(),
  ],
  validate,
  async (req, res) => {
    try {
      const { name, city, address, latitude, longitude, facilities } = req.body;

      const result = await db.query(
        `INSERT INTO stations (name, city, address, latitude, longitude, facilities) 
         VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [name, city, address, latitude, longitude, facilities]
      );

      res.status(201).json({
        success: true,
        message: 'Station created successfully',
        data: { station: result.rows[0] },
      });
    } catch (error) {
      console.error('Create station error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// @route   PUT /api/admin/stations/:id
// @desc    Update station
// @access  Admin
router.put('/stations/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, city, address, latitude, longitude, facilities } = req.body;

    const result = await db.query(
      `UPDATE stations 
       SET name = COALESCE($1, name), 
           city = COALESCE($2, city), 
           address = COALESCE($3, address),
           latitude = COALESCE($4, latitude),
           longitude = COALESCE($5, longitude),
           facilities = COALESCE($6, facilities),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $7 RETURNING *`,
      [name, city, address, latitude, longitude, facilities, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Station not found',
      });
    }

    res.json({
      success: true,
      message: 'Station updated successfully',
      data: { station: result.rows[0] },
    });
  } catch (error) {
    console.error('Update station error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/admin/stations/:id
// @desc    Delete station
// @access  Admin
router.delete('/stations/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('DELETE FROM stations WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Station not found',
      });
    }

    res.json({
      success: true,
      message: 'Station deleted successfully',
    });
  } catch (error) {
    console.error('Delete station error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// ============ TRAINS MANAGEMENT ============

// @route   GET /api/admin/trains
// @desc    Get all trains
// @access  Admin
router.get('/trains', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM trains ORDER BY created_at DESC'
    );

    res.json({
      success: true,
      data: { trains: result.rows },
    });
  } catch (error) {
    console.error('Get trains error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/admin/trains
// @desc    Create train
// @access  Admin
router.post(
  '/trains',
  [
    body('train_number').trim().notEmpty().withMessage('Train number is required'),
    body('name').trim().notEmpty().withMessage('Train name is required'),
    body('type').trim().notEmpty().withMessage('Train type is required'),
    body('total_seats').isInt({ min: 1 }).withMessage('Total seats must be a positive number'),
    body('first_class_seats').isInt({ min: 0 }),
    body('second_class_seats').isInt({ min: 0 }),
  ],
  validate,
  async (req, res) => {
    try {
      const {
        train_number,
        name,
        type,
        total_seats,
        first_class_seats,
        second_class_seats,
        facilities,
        status,
      } = req.body;

      const result = await db.query(
        `INSERT INTO trains (train_number, name, type, total_seats, first_class_seats, second_class_seats, facilities, status) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
        [
          train_number,
          name,
          type,
          total_seats,
          first_class_seats || 0,
          second_class_seats || 0,
          facilities,
          status || 'active',
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Train created successfully',
        data: { train: result.rows[0] },
      });
    } catch (error) {
      if (error.code === '23505') {
        return res.status(400).json({
          success: false,
          message: 'Train number already exists',
        });
      }
      console.error('Create train error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// @route   PUT /api/admin/trains/:id
// @desc    Update train
// @access  Admin
router.put('/trains/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      train_number,
      name,
      type,
      total_seats,
      first_class_seats,
      second_class_seats,
      facilities,
      status,
    } = req.body;

    const result = await db.query(
      `UPDATE trains 
       SET train_number = COALESCE($1, train_number),
           name = COALESCE($2, name),
           type = COALESCE($3, type),
           total_seats = COALESCE($4, total_seats),
           first_class_seats = COALESCE($5, first_class_seats),
           second_class_seats = COALESCE($6, second_class_seats),
           facilities = COALESCE($7, facilities),
           status = COALESCE($8, status),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $9 RETURNING *`,
      [train_number, name, type, total_seats, first_class_seats, second_class_seats, facilities, status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Train not found',
      });
    }

    res.json({
      success: true,
      message: 'Train updated successfully',
      data: { train: result.rows[0] },
    });
  } catch (error) {
    console.error('Update train error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/admin/trains/:id
// @desc    Delete train
// @access  Admin
router.delete('/trains/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('DELETE FROM trains WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Train not found',
      });
    }

    res.json({
      success: true,
      message: 'Train deleted successfully',
    });
  } catch (error) {
    console.error('Delete train error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// ============ TOURS MANAGEMENT ============

// @route   GET /api/admin/tours
// @desc    Get all tours
// @access  Admin
router.get('/tours', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT t.*, 
              tr.name as train_name, tr.train_number,
              os.name as origin_name, os.city as origin_city,
              ds.name as destination_name, ds.city as destination_city
       FROM tours t
       JOIN trains tr ON t.train_id = tr.id
       JOIN stations os ON t.origin_station_id = os.id
       JOIN stations ds ON t.destination_station_id = ds.id
       ORDER BY t.departure_time DESC`
    );

    res.json({
      success: true,
      data: { tours: result.rows },
    });
  } catch (error) {
    console.error('Get tours error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/admin/tours
// @desc    Create tour
// @access  Admin
router.post(
  '/tours',
  [
    body('train_id').isInt().withMessage('Train ID is required'),
    body('origin_station_id').isInt().withMessage('Origin station is required'),
    body('destination_station_id').isInt().withMessage('Destination station is required'),
    body('departure_time').isISO8601().withMessage('Valid departure time is required'),
    body('arrival_time').isISO8601().withMessage('Valid arrival time is required'),
    body('first_class_price').isFloat({ min: 0 }),
    body('second_class_price').isFloat({ min: 0 }),
    body('available_seats').isInt({ min: 0 }),
  ],
  validate,
  async (req, res) => {
    try {
      const {
        train_id,
        origin_station_id,
        destination_station_id,
        departure_time,
        arrival_time,
        first_class_price,
        second_class_price,
        available_seats,
        status,
      } = req.body;

      const result = await db.query(
        `INSERT INTO tours (train_id, origin_station_id, destination_station_id, departure_time, arrival_time, first_class_price, second_class_price, available_seats, status) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
        [
          train_id,
          origin_station_id,
          destination_station_id,
          departure_time,
          arrival_time,
          first_class_price,
          second_class_price,
          available_seats,
          status || 'scheduled',
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Tour created successfully',
        data: { tour: result.rows[0] },
      });
    } catch (error) {
      console.error('Create tour error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// @route   PUT /api/admin/tours/:id
// @desc    Update tour
// @access  Admin
router.put('/tours/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      train_id,
      origin_station_id,
      destination_station_id,
      departure_time,
      arrival_time,
      first_class_price,
      second_class_price,
      available_seats,
      status,
    } = req.body;

    const result = await db.query(
      `UPDATE tours 
       SET train_id = COALESCE($1, train_id),
           origin_station_id = COALESCE($2, origin_station_id),
           destination_station_id = COALESCE($3, destination_station_id),
           departure_time = COALESCE($4, departure_time),
           arrival_time = COALESCE($5, arrival_time),
           first_class_price = COALESCE($6, first_class_price),
           second_class_price = COALESCE($7, second_class_price),
           available_seats = COALESCE($8, available_seats),
           status = COALESCE($9, status),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $10 RETURNING *`,
      [
        train_id,
        origin_station_id,
        destination_station_id,
        departure_time,
        arrival_time,
        first_class_price,
        second_class_price,
        available_seats,
        status,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Tour not found',
      });
    }

    res.json({
      success: true,
      message: 'Tour updated successfully',
      data: { tour: result.rows[0] },
    });
  } catch (error) {
    console.error('Update tour error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/admin/tours/:id
// @desc    Delete tour
// @access  Admin
router.delete('/tours/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('DELETE FROM tours WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Tour not found',
      });
    }

    res.json({
      success: true,
      message: 'Tour deleted successfully',
    });
  } catch (error) {
    console.error('Delete tour error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/admin/reservations
// @desc    Get all reservations
// @access  Admin
router.get('/reservations', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT r.*, 
              u.full_name as user_name, u.email as user_email,
              t.departure_time, t.arrival_time,
              tr.name as train_name, tr.train_number,
              os.name as origin_name, ds.name as destination_name
       FROM reservations r
       JOIN users u ON r.user_id = u.id
       JOIN tours t ON r.tour_id = t.id
       JOIN trains tr ON t.train_id = tr.id
       JOIN stations os ON t.origin_station_id = os.id
       JOIN stations ds ON t.destination_station_id = ds.id
       ORDER BY r.created_at DESC`
    );

    res.json({
      success: true,
      data: { reservations: result.rows },
    });
  } catch (error) {
    console.error('Get reservations error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/admin/dashboard-stats
// @desc    Get dashboard statistics
// @access  Admin
router.get('/dashboard-stats', async (req, res) => {
  try {
    const stats = await db.query(`
      SELECT 
        (SELECT COUNT(*) FROM users WHERE role = 'user') as total_users,
        (SELECT COUNT(*) FROM stations) as total_stations,
        (SELECT COUNT(*) FROM trains) as total_trains,
        (SELECT COUNT(*) FROM tours WHERE status = 'scheduled') as active_tours,
        (SELECT COUNT(*) FROM reservations WHERE status = 'confirmed') as total_reservations,
        (SELECT COALESCE(SUM(total_price), 0) FROM reservations WHERE status = 'confirmed') as total_revenue
    `);

    res.json({
      success: true,
      data: { stats: stats.rows[0] },
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router;
