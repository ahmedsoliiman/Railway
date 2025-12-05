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
  seat_class: {
    type: DataTypes.STRING(20),
    allowNull: false,
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
    type: DataTypes.STRING(20),
    defaultValue: 'pending',
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
