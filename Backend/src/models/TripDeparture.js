const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const TripDeparture = sequelize.define('TripDeparture', {
  trip_departure_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  trip_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'trips',
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
    validate: {
      isAfterDeparture(value) {
        if (value <= this.departure_time) {
          throw new Error('Arrival time must be after departure time');
        }
      }
    }
  },
  available_seats: {
    type: DataTypes.INTEGER,
    allowNull: true,
    defaultValue: 0,
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
  tableName: 'trip_departures',
  timestamps: false,
  underscored: true,
});

module.exports = TripDeparture;
