const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const validate = require('../middleware/validator');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');
const stationController = require('../controllers/stationController');
const carriageController = require('../controllers/carriageController');
const trainController = require('../controllers/trainController');
const tripController = require('../controllers/tripController');
const adminController = require('../controllers/adminController');

// Apply auth and admin middleware to all routes
router.use(authMiddleware, adminMiddleware);

// ============ DASHBOARD ============

// @route   GET /api/admin/dashboard-stats
// @desc    Get dashboard statistics
// @access  Admin
router.get('/dashboard-stats', adminController.getDashboardStats);

// @route   GET /api/admin/users
// @desc    Get all users
// @access  Admin
router.get('/users', adminController.getAllUsers);

// @route   GET /api/admin/reservations
// @desc    Get all reservations
// @access  Admin
router.get('/reservations', adminController.getAllReservations);

// ============ STATIONS MANAGEMENT ============

// @route   GET /api/admin/stations
// @desc    Get all stations
// @access  Admin
router.get('/stations', stationController.getAllStations);

// @route   POST /api/admin/stations
// @desc    Create station
// @access  Admin
router.post(
  '/stations',
  [
    body('name').trim().notEmpty().withMessage('Station name is required'),
    body('code').trim().notEmpty().withMessage('Station code is required'),
    body('city').trim().notEmpty().withMessage('City is required'),
    body('address').optional().trim(),
    body('facilities').optional().trim(),
  ],
  validate,
  stationController.createStation
);

// @route   PUT /api/admin/stations/:id
// @desc    Update station
// @access  Admin
router.put(
  '/stations/:id',
  [
    body('name').optional().trim().notEmpty(),
    body('code').optional().trim().notEmpty(),
    body('city').optional().trim().notEmpty(),
  ],
  validate,
  stationController.updateStation
);

// @route   DELETE /api/admin/stations/:id
// @desc    Delete station
// @access  Admin
router.delete('/stations/:id', stationController.deleteStation);

// ============ CARRIAGES MANAGEMENT ============

// @route   GET /api/admin/carriages
// @desc    Get all carriages
// @access  Admin
router.get('/carriages', carriageController.getAllCarriages);

// @route   POST /api/admin/carriages
// @desc    Create carriage
// @access  Admin
router.post(
  '/carriages',
  [
    body('name').trim().notEmpty().withMessage('Carriage name is required'),
    body('classType').optional().isIn(['first', 'second', 'economic'])
      .withMessage('Class type must be first, second, or economic'),
    body('class_type').optional().isIn(['first', 'second', 'economic'])
      .withMessage('Class type must be first, second, or economic'),
    body('seatsCount').optional().isInt({ min: 1 })
      .withMessage('Seats count must be at least 1'),
    body('seats_count').optional().isInt({ min: 1 })
      .withMessage('Seats count must be at least 1'),
    body('model').optional().trim(),
    body('description').optional().trim(),
  ],
  validate,
  carriageController.createCarriage
);

// @route   PUT /api/admin/carriages/:id
// @desc    Update carriage
// @access  Admin
router.put('/carriages/:id', carriageController.updateCarriage);

// @route   DELETE /api/admin/carriages/:id
// @desc    Delete carriage
// @access  Admin
router.delete('/carriages/:id', carriageController.deleteCarriage);

// ============ TRAINS MANAGEMENT ============

// @route   GET /api/admin/trains
// @desc    Get all trains
// @access  Admin
router.get('/trains', trainController.getAllTrains);

// @route   POST /api/admin/trains
// @desc    Create train
// @access  Admin
router.post(
  '/trains',
  [
    body('trainNumber').trim().notEmpty().withMessage('Train number is required'),
    body('name').trim().notEmpty().withMessage('Train name is required'),
    body('type').optional().trim(),
    body('facilities').optional().trim(),
    body('status').optional().isIn(['active', 'maintenance', 'inactive']),
    body('carriages').isArray({ min: 1 }).withMessage('At least one carriage is required'),
    body('carriages.*.carriageId').isInt().withMessage('Valid carriage ID is required'),
    body('carriages.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  ],
  validate,
  trainController.createTrain
);

// @route   PUT /api/admin/trains/:id
// @desc    Update train
// @access  Admin
router.put(
  '/trains/:id',
  [
    body('carriages').optional().isArray(),
  ],
  validate,
  trainController.updateTrain
);

// @route   DELETE /api/admin/trains/:id
// @desc    Delete train
// @access  Admin
router.delete('/trains/:id', trainController.deleteTrain);

// ============ TRIPS MANAGEMENT ============

// @route   GET /api/admin/trips
// @desc    Get all trips (admin view)
// @access  Admin
router.get('/trips', tripController.getAllTripsAdmin);

// @route   POST /api/admin/trips
// @desc    Create trip
// @access  Admin
router.post(
  '/trips',
  [
    body('trainId').isInt().withMessage('Valid train ID is required'),
    body('fromStationId').isInt().withMessage('Valid from station ID is required'),
    body('toStationId').isInt().withMessage('Valid to station ID is required'),
    body('departureTime').isISO8601().withMessage('Valid departure time is required'),
    body('arrivalTime').isISO8601().withMessage('Valid arrival time is required'),
    body('firstClassPrice').isFloat({ min: 0 }).withMessage('Valid first class price is required'),
    body('secondClassPrice').isFloat({ min: 0 }).withMessage('Valid second class price is required'),
    body('status').optional().isIn(['scheduled', 'cancelled', 'completed']),
  ],
  validate,
  tripController.createTrip
);

// @route   PUT /api/admin/trips/:id
// @desc    Update trip
// @access  Admin
router.put('/trips/:id', tripController.updateTrip);

// @route   DELETE /api/admin/trips/:id
// @desc    Delete trip
// @access  Admin
router.delete('/trips/:id', tripController.deleteTrip);

module.exports = router;
// @desc    Create station
// @access  Admin
router.post(
  '/stations',
  [
    body('name').trim().notEmpty().withMessage('Station name is required'),
    body('city').trim().notEmpty().withMessage('City is required'),
    body('address').optional().trim(),
    body('latitude').optional({ values: 'falsy' }).isFloat(),
    body('longitude').optional({ values: 'falsy' }).isFloat(),
    body('facilities').optional().trim(),
  ],
  validate,
  async (req, res) => {
    try {
      let { name, city, address, latitude, longitude, facilities } = req.body;
      
      // Convert empty strings to null for coordinates
      latitude = latitude === '' ? null : latitude;
      longitude = longitude === '' ? null : longitude;

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

// ============ CARRIAGES MANAGEMENT ============

// @route   GET /api/admin/carriages
// @desc    Get all carriages
// @access  Admin
router.get('/carriages', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM carriages ORDER BY class_type, name'
    );

    res.json({
      success: true,
      data: { carriages: result.rows },
    });
  } catch (error) {
    console.error('Get carriages error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/admin/carriages
// @desc    Create carriage
// @access  Admin
router.post(
  '/carriages',
  [
    body('name').trim().notEmpty().withMessage('Carriage name is required'),
    body('class_type').isIn(['first', 'second', 'economic']).withMessage('Invalid class type'),
    body('seats_count').isInt({ min: 1 }).withMessage('Seats count must be a positive number'),
  ],
  validate,
  async (req, res) => {
    try {
      const { name, class_type, seats_count, model, description } = req.body;

      const result = await db.query(
        `INSERT INTO carriages (name, class_type, seats_count, model, description) 
         VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [name, class_type, seats_count, model, description]
      );

      res.status(201).json({
        success: true,
        message: 'Carriage created successfully',
        data: { carriage: result.rows[0] },
      });
    } catch (error) {
      console.error('Create carriage error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// @route   PUT /api/admin/carriages/:id
// @desc    Update carriage
// @access  Admin
router.put('/carriages/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, class_type, seats_count, model, description } = req.body;

    const result = await db.query(
      `UPDATE carriages 
       SET name = COALESCE($1, name), 
           class_type = COALESCE($2, class_type), 
           seats_count = COALESCE($3, seats_count),
           model = COALESCE($4, model),
           description = COALESCE($5, description),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $6 RETURNING *`,
      [name, class_type, seats_count, model, description, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Carriage not found',
      });
    }

    res.json({
      success: true,
      message: 'Carriage updated successfully',
      data: { carriage: result.rows[0] },
    });
  } catch (error) {
    console.error('Update carriage error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/admin/carriages/:id
// @desc    Delete carriage
// @access  Admin
router.delete('/carriages/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('DELETE FROM carriages WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Carriage not found',
      });
    }

    res.json({
      success: true,
      message: 'Carriage deleted successfully',
    });
  } catch (error) {
    console.error('Delete carriage error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// ============ TRAINS MANAGEMENT ============

// @route   GET /api/admin/trains
// @desc    Get all trains with their carriages
// @access  Admin
router.get('/trains', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT t.*, 
             COALESCE(
               json_agg(
                 CASE WHEN tc.carriage_id IS NOT NULL THEN
                   json_build_object(
                     'carriage_id', tc.carriage_id,
                     'quantity', tc.quantity,
                     'name', c.name,
                     'class_type', c.class_type,
                     'seats_count', c.seats_count,
                     'model', c.model
                   )
                 END
               ) FILTER (WHERE tc.carriage_id IS NOT NULL),
               '[]'
             ) as carriages
      FROM trains t
      LEFT JOIN train_carriages tc ON t.id = tc.train_id
      LEFT JOIN carriages c ON tc.carriage_id = c.id
      GROUP BY t.id
      ORDER BY t.created_at DESC
    `);

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
// @desc    Create train with carriages
// @access  Admin
router.post(
  '/trains',
  [
    body('train_number').trim().notEmpty().withMessage('Train number is required'),
    body('name').trim().notEmpty().withMessage('Train name is required'),
    body('type').trim().notEmpty().withMessage('Train type is required'),
    body('carriages').isArray().withMessage('Carriages must be an array'),
  ],
  validate,
  async (req, res) => {
    try {
      const {
        train_number,
        name,
        type,
        facilities,
        status,
        carriages,
      } = req.body;

      // Calculate total seats from carriages
      let total_seats = 0;
      let first_class_seats = 0;
      let second_class_seats = 0;

      // Validate carriages and calculate seats
      for (const carr of carriages) {
        const carriageResult = await db.query(
          'SELECT class_type, seats_count FROM carriages WHERE id = $1',
          [carr.carriage_id]
        );
        
        if (carriageResult.rows.length === 0) {
          return res.status(400).json({
            success: false,
            message: `Carriage with ID ${carr.carriage_id} not found`,
          });
        }

        const carriage = carriageResult.rows[0];
        const quantity = carr.quantity || 1;
        const seatsInCarriages = carriage.seats_count * quantity;

        total_seats += seatsInCarriages;

        if (carriage.class_type === 'first') {
          first_class_seats += seatsInCarriages;
        } else if (carriage.class_type === 'second' || carriage.class_type === 'economic') {
          second_class_seats += seatsInCarriages;
        }
      }

      // Insert train
      const result = await db.query(
        `INSERT INTO trains (train_number, name, type, total_seats, first_class_seats, second_class_seats, facilities, status) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
        [
          train_number,
          name,
          type,
          total_seats,
          first_class_seats,
          second_class_seats,
          facilities,
          status || 'active',
        ]
      );

      const train = result.rows[0];

      // Insert train-carriage relationships
      for (const carr of carriages) {
        await db.query(
          'INSERT INTO train_carriages (train_id, carriage_id, quantity) VALUES ($1, $2, $3)',
          [train.id, carr.carriage_id, carr.quantity || 1]
        );
      }

      // Get train with carriages
      const trainWithCarriages = await db.query(`
        SELECT t.*, 
               json_agg(json_build_object(
                 'carriage_id', tc.carriage_id,
                 'quantity', tc.quantity,
                 'name', c.name,
                 'class_type', c.class_type,
                 'seats_count', c.seats_count,
                 'model', c.model
               )) as carriages
        FROM trains t
        LEFT JOIN train_carriages tc ON t.id = tc.train_id
        LEFT JOIN carriages c ON tc.carriage_id = c.id
        WHERE t.id = $1
        GROUP BY t.id
      `, [train.id]);

      res.status(201).json({
        success: true,
        message: 'Train created successfully',
        data: { train: trainWithCarriages.rows[0] },
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
// @desc    Update train with carriages
// @access  Admin
router.put('/trains/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      train_number,
      name,
      type,
      facilities,
      status,
      carriages,
    } = req.body;

    let total_seats, first_class_seats, second_class_seats;

    // If carriages are provided, recalculate seats
    if (carriages && Array.isArray(carriages)) {
      total_seats = 0;
      first_class_seats = 0;
      second_class_seats = 0;

      for (const carr of carriages) {
        const carriageResult = await db.query(
          'SELECT class_type, seats_count FROM carriages WHERE id = $1',
          [carr.carriage_id]
        );
        
        if (carriageResult.rows.length > 0) {
          const carriage = carriageResult.rows[0];
          const quantity = carr.quantity || 1;
          const seatsInCarriages = carriage.seats_count * quantity;

          total_seats += seatsInCarriages;

          if (carriage.class_type === 'first') {
            first_class_seats += seatsInCarriages;
          } else if (carriage.class_type === 'second' || carriage.class_type === 'economic') {
            second_class_seats += seatsInCarriages;
          }
        }
      }

      // Delete existing carriage assignments
      await db.query('DELETE FROM train_carriages WHERE train_id = $1', [id]);

      // Insert new carriage assignments
      for (const carr of carriages) {
        await db.query(
          'INSERT INTO train_carriages (train_id, carriage_id, quantity) VALUES ($1, $2, $3)',
          [id, carr.carriage_id, carr.quantity || 1]
        );
      }
    }

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

    // Get updated train with carriages
    const trainWithCarriages = await db.query(`
      SELECT t.*, 
             COALESCE(
               json_agg(
                 CASE WHEN tc.carriage_id IS NOT NULL THEN
                   json_build_object(
                     'carriage_id', tc.carriage_id,
                     'quantity', tc.quantity,
                     'name', c.name,
                     'class_type', c.class_type,
                     'seats_count', c.seats_count,
                     'model', c.model
                   )
                 END
               ) FILTER (WHERE tc.carriage_id IS NOT NULL),
               '[]'
             ) as carriages
      FROM trains t
      LEFT JOIN train_carriages tc ON t.id = tc.train_id
      LEFT JOIN carriages c ON tc.carriage_id = c.id
      WHERE t.id = $1
      GROUP BY t.id
    `, [id]);

    res.json({
      success: true,
      message: 'Train updated successfully',
      data: { train: trainWithCarriages.rows[0] },
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

      // Fetch the complete tour with joined data
      const tourWithDetails = await db.query(
        `SELECT t.*, 
                tr.name as train_name, tr.train_number, tr.type as train_type, tr.facilities as train_facilities,
                os.name as origin_name, os.city as origin_city,
                ds.name as destination_name, ds.city as destination_city
         FROM tours t
         JOIN trains tr ON t.train_id = tr.id
         JOIN stations os ON t.origin_station_id = os.id
         JOIN stations ds ON t.destination_station_id = ds.id
         WHERE t.id = $1`,
        [result.rows[0].id]
      );

      res.status(201).json({
        success: true,
        message: 'Tour created successfully',
        data: { tour: tourWithDetails.rows[0] },
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

    // Fetch the complete tour with joined data
    const tourWithDetails = await db.query(
      `SELECT t.*, 
              tr.name as train_name, tr.train_number, tr.type as train_type, tr.facilities as train_facilities,
              os.name as origin_name, os.city as origin_city,
              ds.name as destination_name, ds.city as destination_city
       FROM tours t
       JOIN trains tr ON t.train_id = tr.id
       JOIN stations os ON t.origin_station_id = os.id
       JOIN stations ds ON t.destination_station_id = ds.id
       WHERE t.id = $1`,
      [id]
    );

    res.json({
      success: true,
      message: 'Tour updated successfully',
      data: { tour: tourWithDetails.rows[0] },
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

// @route   GET /api/admin/users
// @desc    Get all users
// @access  Admin
router.get('/users', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, full_name, email, phone, role, is_verified, created_at 
       FROM users 
       ORDER BY created_at DESC`
    );

    res.json({
      success: true,
      data: { users: result.rows },
    });
  } catch (error) {
    console.error('Get users error:', error);
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
              os.name as origin_name, os.city as origin_city,
              ds.name as destination_name, ds.city as destination_city
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
