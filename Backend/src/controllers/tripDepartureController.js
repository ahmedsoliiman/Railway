const { TripDeparture, Trip, Train, Station } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all trip departures
// @route   GET /api/admin/trip-departures
// @access  Private/Admin
exports.getAllTripDepartures = async (req, res) => {
  try {
    const departures = await TripDeparture.findAll({
      include: [
        {
          model: Trip,
          as: 'trip',
          include: [
            { model: Train, as: 'train' },
            { model: Station, as: 'departureStation' },
            { model: Station, as: 'arrivalStation' },
          ],
        },
      ],
      order: [['departure_time', 'ASC']],
    });

    res.json({
      success: true,
      data: departures.map(dep => ({
        id: dep.trip_departure_id,
        tripId: dep.trip_id,
        departureTime: dep.departure_time,
        arrivalTime: dep.arrival_time,
        availableSeats: dep.available_seats,
        trip: dep.trip ? {
          id: dep.trip.id,
          trainNumber: dep.trip.train?.train_number,
          originName: dep.trip.departureStation?.name,
          originCity: dep.trip.departureStation?.city,
          destinationName: dep.trip.arrivalStation?.name,
          destinationCity: dep.trip.arrivalStation?.city,
          quantities: dep.trip.quantities,
        } : null,
        createdAt: dep.created_at,
      })),
    });
  } catch (error) {
    console.error('Get trip departures error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trip departures',
    });
  }
};

// @desc    Get trip departures for a specific trip
// @route   GET /api/admin/trips/:tripId/departures
// @access  Private/Admin
exports.getTripDepartures = async (req, res) => {
  try {
    const { tripId } = req.params;

    const departures = await TripDeparture.findAll({
      where: { trip_id: tripId },
      order: [['departure_time', 'ASC']],
    });

    res.json({
      success: true,
      data: departures.map(dep => ({
        id: dep.trip_departure_id,
        tripId: dep.trip_id,
        departureTime: dep.departure_time,
        arrivalTime: dep.arrival_time,
        availableSeats: dep.available_seats,
        createdAt: dep.created_at,
      })),
    });
  } catch (error) {
    console.error('Get trip departures error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trip departures',
    });
  }
};

// @desc    Create trip departure
// @route   POST /api/admin/trip-departures
// @access  Private/Admin
exports.createTripDeparture = async (req, res) => {
  try {
    const { trip_id, tripId, departure_time, departureTime, arrival_time, arrivalTime, available_seats, availableSeats } = req.body;

    // Verify trip exists if trip_id is provided
    const finalTripId = trip_id || tripId;
    if (finalTripId) {
      const trip = await Trip.findByPk(finalTripId);
      if (!trip) {
        return res.status(404).json({
          success: false,
          message: 'Trip not found',
        });
      }
    }

    const departure = await TripDeparture.create({
      trip_id: finalTripId,
      departure_time: departure_time || departureTime,
      arrival_time: arrival_time || arrivalTime,
      available_seats: available_seats || availableSeats || 0,
    });

    res.status(201).json({
      success: true,
      message: 'Trip departure created successfully',
      data: {
        id: departure.trip_departure_id,
        tripId: departure.trip_id,
        departureTime: departure.departure_time,
        arrivalTime: departure.arrival_time,
        availableSeats: departure.available_seats,
      },
    });
  } catch (error) {
    console.error('Create trip departure error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create trip departure',
    });
  }
};

// @desc    Update trip departure
// @route   PUT /api/admin/trip-departures/:id
// @access  Private/Admin
exports.updateTripDeparture = async (req, res) => {
  try {
    const { id } = req.params;
    const { departure_time, departureTime, arrival_time, arrivalTime, available_seats, availableSeats } = req.body;

    const departure = await TripDeparture.findByPk(id);
    if (!departure) {
      return res.status(404).json({
        success: false,
        message: 'Trip departure not found',
      });
    }

    await departure.update({
      departure_time: departure_time || departureTime || departure.departure_time,
      arrival_time: arrival_time || arrivalTime || departure.arrival_time,
      available_seats: available_seats !== undefined ? available_seats : (availableSeats !== undefined ? availableSeats : departure.available_seats),
    });

    res.json({
      success: true,
      message: 'Trip departure updated successfully',
      data: {
        id: departure.trip_departure_id,
        tripId: departure.trip_id,
        departureTime: departure.departure_time,
        arrivalTime: departure.arrival_time,
        availableSeats: departure.available_seats,
      },
    });
  } catch (error) {
    console.error('Update trip departure error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update trip departure',
    });
  }
};

// @desc    Delete trip departure
// @route   DELETE /api/admin/trip-departures/:id
// @access  Private/Admin
exports.deleteTripDeparture = async (req, res) => {
  try {
    const { id } = req.params;

    const departure = await TripDeparture.findByPk(id);
    if (!departure) {
      return res.status(404).json({
        success: false,
        message: 'Trip departure not found',
      });
    }

    await departure.destroy();

    res.json({
      success: true,
      message: 'Trip departure deleted successfully',
    });
  } catch (error) {
    console.error('Delete trip departure error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete trip departure',
    });
  }
};
