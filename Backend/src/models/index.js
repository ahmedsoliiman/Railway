const sequelize = require('../config/sequelize');
const User = require('./User');
const Station = require('./Station');
const Carriage = require('./Carriage');
const CarriageType = require('./CarriageType');
const Train = require('./Train');
const TrainCarriage = require('./TrainCarriage');
const Trip = require('./Trip');
const TripDeparture = require('./TripDeparture');
const Booking = require('./Booking');
const Payment = require('./Payment');

// ============ ASSOCIATIONS ============

// CarriageType <-> Carriage (One-to-Many)
CarriageType.hasMany(Carriage, { foreignKey: 'carriage_type_id', as: 'carriages' });
Carriage.belongsTo(CarriageType, { foreignKey: 'carriage_type_id', as: 'carriageType' });

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
Trip.belongsTo(Station, { foreignKey: 'origin_station_id', as: 'departureStation' });
Trip.belongsTo(Station, { foreignKey: 'destination_station_id', as: 'arrivalStation' });
Station.hasMany(Trip, { foreignKey: 'origin_station_id', as: 'departingTrips' });
Station.hasMany(Trip, { foreignKey: 'destination_station_id', as: 'arrivingTrips' });

// Trip <-> TripDeparture (One-to-Many)
Trip.hasMany(TripDeparture, { foreignKey: 'trip_id', as: 'departures' });
TripDeparture.belongsTo(Trip, { foreignKey: 'trip_id', as: 'trip' });

// Booking <-> User (Many-to-One)
Booking.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
User.hasMany(Booking, { foreignKey: 'user_id', as: 'bookings' });

// Booking <-> TripDeparture (Many-to-One)
Booking.belongsTo(TripDeparture, { foreignKey: 'trip_departure_id', as: 'tripDeparture' });
TripDeparture.hasMany(Booking, { foreignKey: 'trip_departure_id', as: 'bookings' });

// Booking <-> CarriageType (Many-to-One)
Booking.belongsTo(CarriageType, { foreignKey: 'carriage_type_id', as: 'carriageType' });
CarriageType.hasMany(Booking, { foreignKey: 'carriage_type_id', as: 'bookings' });

// Payment <-> Booking (One-to-One)
Payment.belongsTo(Booking, { foreignKey: 'booking_id', as: 'booking' });
Booking.hasOne(Payment, { foreignKey: 'booking_id', as: 'payment' });

// ============ EXPORTS ============

module.exports = {
  sequelize,
  User,
  Station,
  Carriage,
  CarriageType,
  Train,
  TrainCarriage,
  Trip,
  TripDeparture,
  Booking,
  Payment,
};
