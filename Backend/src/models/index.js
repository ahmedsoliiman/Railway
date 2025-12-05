const sequelize = require('../config/sequelize');
const User = require('./User');
const Station = require('./Station');
const Carriage = require('./Carriage');
const Train = require('./Train');
const TrainCarriage = require('./TrainCarriage');
const Trip = require('./Trip');
const Reservation = require('./Reservation');

// ============ ASSOCIATIONS ============

// Train <-> Carriage (Many-to-Many through TrainCarriage)
Train.belongsToMany(Carriage, {
  through: TrainCarriage,
  foreignKey: 'train_id',
  otherKey: 'carriage_id',
  as: 'carriages',
});

Carriage.belongsToMany(Train, {
  through: TrainCarriage,
  foreignKey: 'carriage_id',
  otherKey: 'train_id',
  as: 'trains',
});

// Direct associations for eager loading
Train.hasMany(TrainCarriage, { foreignKey: 'train_id', as: 'trainCarriages' });
TrainCarriage.belongsTo(Train, { foreignKey: 'train_id' });
TrainCarriage.belongsTo(Carriage, { foreignKey: 'carriage_id', as: 'carriage' });

// Trip <-> Train (Many-to-One)
Trip.belongsTo(Train, { foreignKey: 'train_id', as: 'train' });
Train.hasMany(Trip, { foreignKey: 'train_id', as: 'trips' });

// Trip <-> Station (Many-to-One for departure and arrival)
Trip.belongsTo(Station, { foreignKey: 'from_station_id', as: 'departureStation' });
Trip.belongsTo(Station, { foreignKey: 'to_station_id', as: 'arrivalStation' });
Station.hasMany(Trip, { foreignKey: 'from_station_id', as: 'departingTrips' });
Station.hasMany(Trip, { foreignKey: 'to_station_id', as: 'arrivingTrips' });

// Reservation <-> User (Many-to-One)
Reservation.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
User.hasMany(Reservation, { foreignKey: 'user_id', as: 'reservations' });

// Reservation <-> Trip (Many-to-One)
Reservation.belongsTo(Trip, { foreignKey: 'trip_id', as: 'trip' });
Trip.hasMany(Reservation, { foreignKey: 'trip_id', as: 'reservations' });

// ============ EXPORTS ============

module.exports = {
  sequelize,
  User,
  Station,
  Carriage,
  Train,
  TrainCarriage,
  Trip,
  Reservation,
};
