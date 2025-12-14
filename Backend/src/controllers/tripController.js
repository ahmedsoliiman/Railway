const { Trip, Train, Station, TripDeparture, sequelize } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all trips (with filters)
// @route   GET /api/user/trips
// @access  Public
exports.getAllTrips = async (req, res) => {
  try {
    const { from_station, to_station, date, seat_class, originId, destinationId } = req.query;

    const tripWhere = {};

    // Filter by stations - accept both naming conventions
    const fromStation = from_station || originId;
    const toStation = to_station || destinationId;
    
    if (fromStation) {
      tripWhere.origin_station_id = parseInt(fromStation);
      console.log('🔍 Filtering by origin station:', fromStation);
    }
    if (toStation) {
      tripWhere.destination_station_id = parseInt(toStation);
      console.log('🔍 Filtering by destination station:', toStation);
    }

    // Build departure filter for TripDepartures
    const departureWhere = {};
    if (date) {
      const startDate = new Date(date);
      startDate.setHours(0, 0, 0, 0);
      const endDate = new Date(date);
      endDate.setHours(23, 59, 59, 999);

      departureWhere.departure_time = {
        [Op.between]: [startDate, endDate]
      };
      // Also ensure future departures
      departureWhere.departure_time[Op.gt] = new Date();
      console.log('🔍 Filtering by date:', date);
    } else {
      // No specific date, just show future departures
      departureWhere.departure_time = {
        [Op.gt]: new Date(),
      };
    }

    const trips = await Trip.findAll({
      where: tripWhere,
      include: [
        {
          model: Train,
          as: 'train',
          attributes: ['id', 'train_number', 'type'],
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
        {
          model: TripDeparture,
          as: 'departures',
          where: departureWhere,
          required: true, // Only include trips that have future departures
          attributes: ['trip_departure_id', 'departure_time', 'arrival_time', 'available_seats'],
        },
      ],
      order: [
        [{ model: TripDeparture, as: 'departures' }, 'departure_time', 'ASC']
      ],
    });

    // Filter by seat class availability if specified
    let filteredTrips = trips;
    if (seat_class === 'first') {
      filteredTrips = trips.filter(t => t.first_class_price && t.first_class_price > 0);
    } else if (seat_class === 'second') {
      filteredTrips = trips.filter(t => t.second_class_price && t.second_class_price > 0);
    }

    res.json({
      success: true,
      data: filteredTrips.map(trip => ({
        id: trip.id,
        trainId: trip.train_id,
        firstClassPrice: trip.first_class_price ? parseFloat(trip.first_class_price) : null,
        secondClassPrice: trip.second_class_price ? parseFloat(trip.second_class_price) : null,
        economicPrice: trip.economic_price ? parseFloat(trip.economic_price) : null,
        quantities: trip.quantities,
        train: {
          id: trip.train.id,
          trainNumber: trip.train.train_number,
          type: trip.train.type,
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
        departures: trip.departures.map(dep => ({
          id: dep.trip_departure_id,
          departureTime: dep.departure_time,
          arrivalTime: dep.arrival_time,
          availableSeats: dep.available_seats,
        })),
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
        {
          model: TripDeparture,
          as: 'departures',
          where: {
            departure_time: { [Op.gt]: new Date() }
          },
          required: false,
          attributes: ['trip_departure_id', 'departure_time', 'arrival_time', 'available_seats'],
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
        trainId: trip.train_id,
        firstClassPrice: trip.first_class_price ? parseFloat(trip.first_class_price) : null,
        secondClassPrice: trip.second_class_price ? parseFloat(trip.second_class_price) : null,
        economicPrice: trip.economic_price ? parseFloat(trip.economic_price) : null,
        quantities: trip.quantities,
        train: {
          id: trip.train.id,
          trainNumber: trip.train.train_number,
          type: trip.train.type,
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
        departures: trip.departures ? trip.departures.map(dep => ({
          id: dep.trip_departure_id,
          departureTime: dep.departure_time,
          arrivalTime: dep.arrival_time,
          availableSeats: dep.available_seats,
        })) : [],
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
        { 
          model: TripDeparture, 
          as: 'departures',
          required: false, // LEFT JOIN so trips without departures still show
        }
      ],
      order: [['id', 'DESC']],
    });

    res.json({
      success: true,
      data: trips.map(trip => ({
        id: trip.id,
        trainId: trip.train_id,
        originStationId: trip.origin_station_id,
        destinationStationId: trip.destination_station_id,
        firstClassPrice: parseFloat(trip.first_class_price || 0),
        secondClassPrice: parseFloat(trip.second_class_price || 0),
        economicPrice: parseFloat(trip.economic_price || 0),
        quantities: trip.quantities,
        train: {
          trainNumber: trip.train.train_number,
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
        departures: trip.departures.map(dep => ({
          id: dep.trip_departure_id,
          departureTime: dep.departure_time,
          arrivalTime: dep.arrival_time,
          availableSeats: dep.available_seats,
        })),
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
    const first_class_price = req.body.first_class_price || req.body.firstClassPrice || 0;
    const second_class_price = req.body.second_class_price || req.body.secondClassPrice || 0;
    const economic_price = req.body.economic_price || req.body.economicPrice || 0;
    const quantities = req.body.quantities;

    // Validation
    if (!train_id || !origin_station_id || !destination_station_id || !quantities) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields (trainId, originStationId, destinationStationId, quantities)',
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

    // Create trip with prices
    const trip = await Trip.create({
      train_id,
      origin_station_id,
      destination_station_id,
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
          firstClassPrice: parseFloat(trip.first_class_price || 0),
          secondClassPrice: parseFloat(trip.second_class_price || 0),
          economicPrice: parseFloat(trip.economic_price || 0),
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
