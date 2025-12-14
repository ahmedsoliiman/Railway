const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Booking = sequelize.define('Booking', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'booking_id', // Map to booking_id in database
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id',
    },
    onDelete: 'CASCADE',
  },
  trip_departure_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'trip_departures',
      key: 'trip_departure_id',
    },
    onDelete: 'CASCADE',
  },
  carriage_type_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'carriage_types',
      key: 'carriage_type_id',
    },
    onDelete: 'RESTRICT',
  },
  seat_number: {
    type: DataTypes.STRING(10),
    allowNull: true,
  },
  number_of_seats: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  total_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  booking_reference: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'cancelled'),
    defaultValue: 'pending',
    allowNull: false,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'bookings',
  timestamps: false,
  underscored: true,
});

module.exports = Booking;
