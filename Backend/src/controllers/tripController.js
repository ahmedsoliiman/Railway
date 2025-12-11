const { Trip, Train, Station, sequelize } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all trips (with filters)
// @route   GET /api/user/trips
// @access  Public
exports.getAllTrips = async (req, res) => {
  try {
    const { from_station, to_station, date, seat_class, originId, destinationId } = req.query;

    const where = {};

    // Filter by stations - accept both naming conventions
    const fromStation = from_station || originId;
    const toStation = to_station || destinationId;
    
    if (fromStation) {
      where.origin_station_id = parseInt(fromStation);
      console.log('🔍 Filtering by origin station:', fromStation);
    }
    if (toStation) {
      where.destination_station_id = parseInt(toStation);
      console.log('🔍 Filtering by destination station:', toStation);
    }

    // Filter by date and future departure
    if (date) {
      const startDate = new Date(date);
      startDate.setHours(0, 0, 0, 0);
      const endDate = new Date(date);
      endDate.setHours(23, 59, 59, 999);

      where.departure_time = {
        [Op.and]: [
          { [Op.gte]: startDate },
          { [Op.lte]: endDate },
          { [Op.gt]: new Date() }
        ]
      };
      console.log('🔍 Filtering by date:', date);
    } else {
      // No specific date, just show future trips
      where.departure_time = {
        [Op.gt]: new Date(),
      };
    }

    const trips = await Trip.findAll({
      where,
      include: [
        {
          model: Train,
          as: 'train',
          attributes: ['id', 'train_number', 'name', 'type', 'facilities'],
        },
        {
          model: Station,
          as: 'departureStation',
          attributes: ['id', 'name', 'code', 'city'],
        },
        {
          model: Station,
          as: 'arrivalStation',
          attributes: ['id', 'name', 'code', 'city'],
        },
      ],
      order: [['departure_time', 'ASC']],
    });

    // Filter by seat availability if seat_class specified
    let filteredTrips = trips;
    if (seat_class === 'first') {
      filteredTrips = trips.filter(t => t.first_class_price && t.quantities > 0);
    } else if (seat_class === 'second') {
      filteredTrips = trips.filter(t => t.second_class_price && t.quantities > 0);
    }

    res.json({
      success: true,
      data: filteredTrips.map(trip => ({
        id: trip.id,
        departureTime: trip.departure_time,
        arrivalTime: trip.arrival_time,
        firstClassPrice: parseFloat(trip.first_class_price),
        secondClassPrice: parseFloat(trip.second_class_price),
        quantities: trip.quantities,
        train: {
          id: trip.train.id,
          trainNumber: trip.train.train_number,
          name: trip.train.name,
          type: trip.train.type,
          facilities: trip.train.facilities,
        },
        departureStation: {
          id: trip.departureStation.id,
          name: trip.departureStation.name,
          code: trip.departureStation.code,
          city: trip.departureStation.city,
        },
        arrivalStation: {
          id: trip.arrivalStation.id,
          name: trip.arrivalStation.name,
          code: trip.arrivalStation.code,
          city: trip.arrivalStation.city,
        },
      })),
    });
  } catch (error) {
    console.error('Get trips error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trips',
    });
  }
};

// @desc    Get single trip
// @route   GET /api/user/trips/:id
// @access  Public
exports.getTripById = async (req, res) => {
  try {
    const { id } = req.params;

    const trip = await Trip.findByPk(id, {
      include: [
        {
          model: Train,
          as: 'train',
        },
        {
          model: Station,
          as: 'departureStation',
        },
        {
          model: Station,
          as: 'arrivalStation',
        },
      ],
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: 'Trip not found',
      });
    }

    res.json({
      success: true,
      data: {
        id: trip.id,
        departureTime: trip.departure_time,
        arrivalTime: trip.arrival_time,
        firstClassPrice: parseFloat(trip.first_class_price || 0),
        secondClassPrice: parseFloat(trip.second_class_price || 0),
        quantities: trip.quantities, // Available seats
        availableSeats: trip.quantities, // For compatibility
        train: {
          id: trip.train.id,
          trainNumber: trip.train.train_number,
          name: trip.train.name,
          type: trip.train.type,
          facilities: trip.train.facilities,
        },
        departureStation: {
          id: trip.departureStation.id,
          name: trip.departureStation.name,
          code: trip.departureStation.code,
          city: trip.departureStation.city,
          address: trip.departureStation.address,
        },
        arrivalStation: {
          id: trip.arrivalStation.id,
          name: trip.arrivalStation.name,
          code: trip.arrivalStation.code,
          city: trip.arrivalStation.city,
          address: trip.arrivalStation.address,
        },
      },
    });
  } catch (error) {
    console.error('Get trip error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trip',
    });
  }
};

// ============ ADMIN ROUTES ============

// @desc    Get all trips (admin)
// @route   GET /api/admin/trips
// @access  Private/Admin
exports.getAllTripsAdmin = async (req, res) => {
  try {
    const trips = await Trip.findAll({
      include: [
        { model: Train, as: 'train' },
        { model: Station, as: 'departureStation' },
        { model: Station, as: 'arrivalStation' },
      ],
      order: [['departure_time', 'DESC']],
    });

    res.json({
      success: true,
      data: trips.map(trip => ({
        id: trip.id,
        trainId: trip.train_id,
        originStationId: trip.origin_station_id,
        destinationStationId: trip.destination_station_id,
        departure: trip.departure,
        departureTime: trip.departure_time,
        arrivalTime: trip.arrival_time,
        firstClassPrice: parseFloat(trip.first_class_price),
        secondClassPrice: parseFloat(trip.second_class_price),
        economicPrice: trip.economic_price ? parseFloat(trip.economic_price) : null,
        quantities: trip.quantities,
        train: {
          trainNumber: trip.train.train_number,
          name: trip.train.name,
          type: trip.train.type,
        },
        departureStation: {
          name: trip.departureStation.name,
          city: trip.departureStation.city,
        },
        arrivalStation: {
          name: trip.arrivalStation.name,
          city: trip.arrivalStation.city,
        },
        createdAt: trip.created_at,
      })),
    });
  } catch (error) {
    console.error('Get trips admin error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trips',
    });
  }
};

// @desc    Create trip
// @route   POST /api/admin/trips
// @access  Private/Admin
exports.createTrip = async (req, res) => {
  try {
    // Accept both camelCase (frontend) and snake_case (API)
    const train_id = req.body.train_id || req.body.trainId;
    const origin_station_id = req.body.origin_station_id || req.body.originStationId;
    const destination_station_id = req.body.destination_station_id || req.body.destinationStationId;
    const departure = req.body.departure;
    const departure_time = req.body.departure_time || req.body.departureTime;
    const arrival_time = req.body.arrival_time || req.body.arrivalTime;
    const first_class_price = req.body.first_class_price || req.body.firstClassPrice;
    const second_class_price = req.body.second_class_price || req.body.secondClassPrice;
    const economic_price = req.body.economic_price || req.body.economicPrice;
    const quantities = req.body.quantities;

    // Validation
    if (!train_id || !origin_station_id || !destination_station_id || !departure || !departure_time || !arrival_time || !first_class_price || !second_class_price || !economic_price || !quantities) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields',
      });
    }

    if (origin_station_id === destination_station_id) {
      return res.status(400).json({
        success: false,
        message: 'Departure and arrival stations must be different',
      });
    }

    // Verify train exists
    const train = await Train.findByPk(train_id);
    if (!train) {
      return res.status(404).json({
        success: false,
        message: 'Train not found',
      });
    }

    // Verify stations exist
    const fromStation = await Station.findByPk(origin_station_id);
    const toStation = await Station.findByPk(destination_station_id);
    if (!fromStation || !toStation) {
      return res.status(404).json({
        success: false,
        message: 'One or both stations not found',
      });
    }

    // Create trip
    const trip = await Trip.create({
      train_id,
      origin_station_id,
      destination_station_id,
      departure,
      departure_time,
      arrival_time,
      first_class_price,
      second_class_price,
      economic_price,
      quantities,
    });

    res.status(201).json({
      success: true,
      message: 'Trip created successfully',
      data: {
        trip: {
          id: trip.id,
          trainId: trip.train_id,
          originStationId: trip.origin_station_id,
          destinationStationId: trip.destination_station_id,
          departure: trip.departure,
          departureTime: trip.departure_time,
          arrivalTime: trip.arrival_time,
          firstClassPrice: parseFloat(trip.first_class_price),
          secondClassPrice: parseFloat(trip.second_class_price),
          economicPrice: parseFloat(trip.economic_price),
          quantities: trip.quantities,
        },
      },
    });
  } catch (error) {
    console.error('Create trip error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create trip',
    });
  }
};

// @desc    Update trip
// @route   PUT /api/admin/trips/:id
// @access  Private/Admin
exports.updateTrip = async (req, res) => {
  try {
    const { id } = req.params;
    // Accept both camelCase (frontend) and snake_case (API)
    const train_id = req.body.train_id || req.body.trainId;
    const origin_station_id = req.body.origin_station_id || req.body.originStationId;
    const destination_station_id = req.body.destination_station_id || req.body.destinationStationId;
    const departure = req.body.departure;
    const departure_time = req.body.departure_time || req.body.departureTime;
    const arrival_time = req.body.arrival_time || req.body.arrivalTime;
    const first_class_price = req.body.first_class_price || req.body.firstClassPrice;
    const second_class_price = req.body.second_class_price || req.body.secondClassPrice;
    const economic_price = req.body.economic_price || req.body.economicPrice;
    const quantities = req.body.quantities;

    const trip = await Trip.findByPk(id);
    if (!trip) {
      return res.status(404).json({
        success: false,
        message: 'Trip not found',
      });
    }

    // Validate stations if provided
    if (origin_station_id && destination_station_id && origin_station_id === destination_station_id) {
      return res.status(400).json({
        success: false,
        message: 'Departure and arrival stations must be different',
      });
    }

    await trip.update({
      train_id: train_id || trip.train_id,
      origin_station_id: origin_station_id || trip.origin_station_id,
      destination_station_id: destination_station_id || trip.destination_station_id,
      departure: departure || trip.departure,
      departure_time: departure_time || trip.departure_time,
      arrival_time: arrival_time || trip.arrival_time,
      first_class_price: first_class_price !== undefined ? first_class_price : trip.first_class_price,
      second_class_price: second_class_price !== undefined ? second_class_price : trip.second_class_price,
      economic_price: economic_price !== undefined ? economic_price : trip.economic_price,
      quantities: quantities !== undefined ? quantities : trip.quantities,
      updated_at: new Date(),
    });

    res.json({
      success: true,
      message: 'Trip updated successfully',
      data: {
        trip: {
          id: trip.id,
          trainId: trip.train_id,
          originStationId: trip.origin_station_id,
          destinationStationId: trip.destination_station_id,
          departure: trip.departure,
          departureTime: trip.departure_time,
          arrivalTime: trip.arrival_time,
          firstClassPrice: parseFloat(trip.first_class_price),
          secondClassPrice: parseFloat(trip.second_class_price),
          economicPrice: parseFloat(trip.economic_price),
          quantities: trip.quantities,
        },
      },
    });
  } catch (error) {
    console.error('Update trip error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update trip',
    });
  }
};

// @desc    Delete trip
// @route   DELETE /api/admin/trips/:id
// @access  Private/Admin
exports.deleteTrip = async (req, res) => {
  try {
    const { id } = req.params;

    const trip = await Trip.findByPk(id);
    if (!trip) {
      return res.status(404).json({
        success: false,
        message: 'Trip not found',
      });
    }

    await trip.destroy();

    res.json({
      success: true,
      message: 'Trip deleted successfully',
    });
  } catch (error) {
    console.error('Delete trip error:', error);
    if (error.name === 'SequelizeForeignKeyConstraintError') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete trip that has reservations',
      });
    }
    res.status(500).json({
      success: false,
      message: 'Failed to delete trip',
    });
  }
};
