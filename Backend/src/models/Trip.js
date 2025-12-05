const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Trip = sequelize.define('Trip', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  train_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'trains',
      key: 'id',
    },
  },
  origin_station_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'stations',
      key: 'id',
    },
  },
  destination_station_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'stations',
      key: 'id',
    },
  },
  departure_time: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  arrival_time: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  first_class_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
  },
  second_class_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
  },
  available_seats: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
  },
  status: {
    type: DataTypes.STRING(20),
    defaultValue: 'scheduled',
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
  tableName: 'trips',
  timestamps: false,
  underscored: true,
});

module.exports = Trip;
