const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Reservation = sequelize.define('Reservation', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
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
  trip_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'trips',
      key: 'id',
    },
    onDelete: 'CASCADE',
  },
  passenger_name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  passenger_national_id: {
    type: DataTypes.STRING(50),
    allowNull: false,
  },
  seat_class: {
    type: DataTypes.ENUM('first', 'second'),
    allowNull: false,
  },
  seat_number: {
    type: DataTypes.STRING(10),
    allowNull: true,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  booking_reference: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'completed', 'refunded'),
    defaultValue: 'completed',
  },
  status: {
    type: DataTypes.ENUM('confirmed', 'cancelled'),
    defaultValue: 'confirmed',
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
  tableName: 'reservations',
  timestamps: false,
  underscored: true,
});

module.exports = Reservation;
