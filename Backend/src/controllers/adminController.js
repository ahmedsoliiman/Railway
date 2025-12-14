const { User, Station, Train, Trip, TripDeparture, Booking, CarriageType, sequelize } = require('../models');

// @desc    Get dashboard statistics
// @route   GET /api/admin/stats
// @access  Private/Admin
exports.getDashboardStats = async (req, res) => {
  try {
    const [
      totalUsers,
      totalStations,
      totalTrains,
      totalTrips,
      totalReservations,
      activeTrips,
      pendingReservations,
    ] = await Promise.all([
      User.count(),
      Station.count(),
      Train.count(),
      Trip.count(),
      Booking.count(),
      Trip.count({ where: { status: 'scheduled' } }),
      Booking.count({ where: { status: 'pending' } }),
    ]);

    // Get recent reservations count (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentReservations = await Booking.count({
      where: {
        created_at: {
          [sequelize.Sequelize.Op.gte]: sevenDaysAgo,
        },
      },
    });

    res.json({
      success: true,
      data: {
        stats: {
          total_users: totalUsers,
          total_stations: totalStations,
          total_trains: totalTrains,
          total_trips: totalTrips,
          total_reservations: totalReservations,
          active_trips: activeTrips,
          pending_reservations: pendingReservations,
          recent_reservations: recentReservations,
          total_revenue: 0,
        },
      },
    });
  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard statistics',
    });
  }
};

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Private/Admin
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'full_name', 'email', 'role', 'is_verified', 'created_at'],
      order: [['created_at', 'DESC']],
    });

    res.json({
      success: true,
      data: users.map(user => ({
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        role: user.role,
        isVerified: user.is_verified,
        createdAt: user.created_at,
      })),
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
    });
  }
};

// @desc    Get all bookings (admin)
// @route   GET /api/admin/reservations
// @access  Private/Admin
exports.getAllReservations = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'full_name', 'email'],
        },
        {
          model: TripDeparture,
          as: 'tripDeparture',
          include: [
            {
              model: Trip,
              as: 'trip',
              include: [
                { model: Train, as: 'train', attributes: ['train_number', 'type'] },
                { model: Station, as: 'departureStation', attributes: ['name', 'city'] },
                { model: Station, as: 'arrivalStation', attributes: ['name', 'city'] },
              ],
            },
          ],
        },
        {
          model: CarriageType,
          as: 'carriageType',
          attributes: ['type', 'price'],
        },
      ],
      order: [['created_at', 'DESC']],
    });

    res.json({
      success: true,
      data: bookings.map(b => ({
        id: b.id,
        bookingReference: b.booking_reference,
        passengerName: b.passenger_name,
        passengerNationalId: b.passenger_national_id,
        seatNumber: b.seat_number,
        price: parseFloat(b.price),
        status: b.status,
        user: b.user ? {
          id: b.user.id,
          fullName: b.user.full_name,
          email: b.user.email,
        } : null,
        tripDeparture: b.tripDeparture ? {
          id: b.tripDeparture.id,
          departureTime: b.tripDeparture.departure_time,
          arrivalTime: b.tripDeparture.arrival_time,
          trip: b.tripDeparture.trip ? {
            id: b.tripDeparture.trip.id,
            train: b.tripDeparture.trip.train ? {
              trainNumber: b.tripDeparture.trip.train.train_number,
              type: b.tripDeparture.trip.train.type,
            } : null,
            departureStation: b.tripDeparture.trip.departureStation ? {
              name: b.tripDeparture.trip.departureStation.name,
              city: b.tripDeparture.trip.departureStation.city,
            } : null,
            arrivalStation: b.tripDeparture.trip.arrivalStation ? {
              name: b.tripDeparture.trip.arrivalStation.name,
              city: b.tripDeparture.trip.arrivalStation.city,
            } : null,
          } : null,
        } : null,
        carriageType: b.carriageType ? {
          type: b.carriageType.type,
          price: parseFloat(b.carriageType.price),
        } : null,
        createdAt: b.created_at,
      })),
    });
  } catch (error) {
    console.error('Get reservations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reservations',
    });
  }
};
