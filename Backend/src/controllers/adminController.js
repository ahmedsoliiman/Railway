const { User, Station, Train, Trip, Reservation, sequelize } = require('../models');

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
      Reservation.count(),
      Trip.count({ where: { status: 'scheduled' } }),
      Reservation.count({ where: { status: 'pending' } }),
    ]);

    // Get recent reservations count (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentReservations = await Reservation.count({
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

// @desc    Get all reservations (admin)
// @route   GET /api/admin/reservations
// @access  Private/Admin
exports.getAllReservations = async (req, res) => {
  try {
    const reservations = await Reservation.findAll({
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'full_name', 'email'],
        },
        {
          model: Trip,
          as: 'trip',
          include: [
            { model: Train, as: 'train', attributes: ['train_number', 'name'] },
            { model: Station, as: 'departureStation', attributes: ['name', 'city'] },
            { model: Station, as: 'arrivalStation', attributes: ['name', 'city'] },
          ],
        },
      ],
      order: [['created_at', 'DESC']],
    });

    res.json({
      success: true,
      data: reservations.map(r => ({
        id: r.id,
        bookingReference: r.booking_reference,
        passengerName: r.passenger_name,
        passengerNationalId: r.passenger_national_id,
        seatClass: r.seat_class,
        seatNumber: r.seat_number,
        price: parseFloat(r.price),
        paymentStatus: r.payment_status,
        status: r.status,
        user: {
          id: r.user.id,
          fullName: r.user.full_name,
          email: r.user.email,
        },
        trip: {
          id: r.trip.id,
          departureTime: r.trip.departure_time,
          arrivalTime: r.trip.arrival_time,
          train: {
            trainNumber: r.trip.train.train_number,
            name: r.trip.train.name,
          },
          departureStation: {
            name: r.trip.departureStation.name,
            city: r.trip.departureStation.city,
          },
          arrivalStation: {
            name: r.trip.arrivalStation.name,
            city: r.trip.arrivalStation.city,
          },
        },
        createdAt: r.created_at,
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
