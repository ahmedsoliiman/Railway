const { sequelize } = require('./src/config/sequelize');
const { User, Station, Carriage, CarriageType, Train, TrainCarriage, Trip, TripDeparture, Booking, Payment } = require('./src/models');
const bcrypt = require('bcryptjs');

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...\n');

    // Clear existing data
    await Payment.destroy({ where: {}, force: true });
    await Booking.destroy({ where: {}, force: true });
    await TripDeparture.destroy({ where: {}, force: true });
    await Trip.destroy({ where: {}, force: true });
    await TrainCarriage.destroy({ where: {}, force: true });
    await Train.destroy({ where: {}, force: true });
    await Carriage.destroy({ where: {}, force: true });
    await CarriageType.destroy({ where: {}, force: true });
    await Station.destroy({ where: {}, force: true });
    await User.destroy({ where: {}, force: true });

    // ============ USERS ============
    console.log('Creating users...');
    const hashedPassword = await bcrypt.hash('password123', 10);
    const users = await User.bulkCreate([
      {
        full_name: 'Admin User',
        email: 'admin@trainsystem.com',
        password: hashedPassword,
        phone: '+201234567890',
        role: 'admin',
      },
      {
        full_name: 'John Smith',
        email: 'john.smith@email.com',
        password: hashedPassword,
        phone: '+201234567891',
        role: 'user',
      },
      {
        full_name: 'Sarah Johnson',
        email: 'sarah.johnson@email.com',
        password: hashedPassword,
        phone: '+201234567892',
        role: 'user',
      },
      {
        full_name: 'Ahmed Hassan',
        email: 'ahmed.hassan@email.com',
        password: hashedPassword,
        phone: '+201234567893',
        role: 'user',
      },
      {
        full_name: 'Maria Garcia',
        email: 'maria.garcia@email.com',
        password: hashedPassword,
        phone: '+201234567894',
        role: 'user',
      },
      {
        full_name: 'Mohamed Ali',
        email: 'mohamed.ali@email.com',
        password: hashedPassword,
        phone: '+201234567895',
        role: 'user',
      },
    ]);
    console.log(`✅ Created ${users.length} users\n`);

    // ============ STATIONS ============
    console.log('Creating stations...');
    const stations = await Station.bulkCreate([
      {
        name: 'Cairo Central',
        code: 'CAI',
        city: 'Cairo',
        address: 'Ramses Square, Cairo',
      },
      {
        name: 'Alexandria Main',
        code: 'ALX',
        city: 'Alexandria',
        address: 'Misr Station, Alexandria',
      },
      {
        name: 'Aswan Station',
        code: 'ASW',
        city: 'Aswan',
        address: 'Corniche El Nile, Aswan',
      },
      {
        name: 'Luxor Station',
        code: 'LXR',
        city: 'Luxor',
        address: 'Al Mahatta Square, Luxor',
      },
      {
        name: 'Giza Station',
        code: 'GIZ',
        city: 'Giza',
        address: 'Giza Square, Giza',
      },
      {
        name: 'Port Said Station',
        code: 'PSD',
        city: 'Port Said',
        address: 'Al Manakh District, Port Said',
      },
      {
        name: 'Suez Station',
        code: 'SUZ',
        city: 'Suez',
        address: 'Al Arbaeen District, Suez',
      },
      {
        name: 'Ismailia Station',
        code: 'ISM',
        city: 'Ismailia',
        address: 'Mohamed Ali Street, Ismailia',
      },
    ]);
    console.log(`✅ Created ${stations.length} stations\n`);

    // ============ CARRIAGE TYPES ============
    console.log('Creating carriage types...');
    const carriageTypes = await CarriageType.bulkCreate([
      {
        type: 'first class',
        capacity: 40,
        price: 200.00,
      },
      {
        type: 'second class',
        capacity: 60,
        price: 150.00,
      },
      {
        type: 'third class',
        capacity: 80,
        price: 100.00,
      },
      {
        type: 'sleeper',
        capacity: 30,
        price: 300.00,
      },
    ]);
    console.log(`✅ Created ${carriageTypes.length} carriage types\n`);

    // ============ CARRIAGES ============
    console.log('Creating carriages...');
    const carriages = await Carriage.bulkCreate([
      { carriage_number: 'C001', carriage_type_id: carriageTypes[0].carriage_type_id },
      { carriage_number: 'C002', carriage_type_id: carriageTypes[0].carriage_type_id },
      { carriage_number: 'C003', carriage_type_id: carriageTypes[1].carriage_type_id },
      { carriage_number: 'C004', carriage_type_id: carriageTypes[1].carriage_type_id },
      { carriage_number: 'C005', carriage_type_id: carriageTypes[2].carriage_type_id },
      { carriage_number: 'C006', carriage_type_id: carriageTypes[2].carriage_type_id },
      { carriage_number: 'C007', carriage_type_id: carriageTypes[2].carriage_type_id },
      { carriage_number: 'C008', carriage_type_id: carriageTypes[3].carriage_type_id },
      { carriage_number: 'C009', carriage_type_id: carriageTypes[3].carriage_type_id },
      { carriage_number: 'C010', carriage_type_id: carriageTypes[1].carriage_type_id },
    ]);
    console.log(`✅ Created ${carriages.length} carriages\n`);

    // ============ TRAINS ============
    console.log('Creating trains...');
    const trains = await Train.bulkCreate([
      { train_number: 'T001', type: 'express', status: 'active' },
      { train_number: 'T002', type: 'VIP', status: 'active' },
      { train_number: 'T003', type: 'ordinary', status: 'active' },
      { train_number: 'T004', type: 'sleeper', status: 'active' },
      { train_number: 'T005', type: 'express', status: 'active' },
      { train_number: 'T006', type: 'tahya masr', status: 'active' },
    ]);
    console.log(`✅ Created ${trains.length} trains\n`);

    // ============ TRAIN CARRIAGES ============
    console.log('Linking trains with carriages...');
    const trainCarriages = await TrainCarriage.bulkCreate([
      { train_id: trains[0].id, carriage_id: carriages[0].id },
      { train_id: trains[0].id, carriage_id: carriages[2].id },
      { train_id: trains[0].id, carriage_id: carriages[4].id },
      { train_id: trains[1].id, carriage_id: carriages[1].id },
      { train_id: trains[1].id, carriage_id: carriages[7].id },
      { train_id: trains[2].id, carriage_id: carriages[3].id },
      { train_id: trains[2].id, carriage_id: carriages[5].id },
      { train_id: trains[2].id, carriage_id: carriages[6].id },
      { train_id: trains[3].id, carriage_id: carriages[0].id },
      { train_id: trains[3].id, carriage_id: carriages[3].id },
      { train_id: trains[3].id, carriage_id: carriages[5].id },
      { train_id: trains[3].id, carriage_id: carriages[8].id },
      { train_id: trains[4].id, carriage_id: carriages[1].id },
      { train_id: trains[4].id, carriage_id: carriages[9].id },
      { train_id: trains[5].id, carriage_id: carriages[2].id },
      { train_id: trains[5].id, carriage_id: carriages[4].id },
      { train_id: trains[5].id, carriage_id: carriages[6].id },
    ]);
    console.log(`✅ Created ${trainCarriages.length} train-carriage associations\n`);

    // ============ TRIPS ============
    console.log('Creating trips...');
    const trips = await Trip.bulkCreate([
      {
        train_id: trains[0].id,
        origin_station_id: stations[0].id,
        destination_station_id: stations[1].id,
        quantities: 120,
      },
      {
        train_id: trains[1].id,
        origin_station_id: stations[0].id,
        destination_station_id: stations[2].id,
        quantities: 70,
      },
      {
        train_id: trains[2].id,
        origin_station_id: stations[0].id,
        destination_station_id: stations[3].id,
        quantities: 200,
      },
      {
        train_id: trains[3].id,
        origin_station_id: stations[1].id,
        destination_station_id: stations[5].id,
        quantities: 180,
      },
      {
        train_id: trains[4].id,
        origin_station_id: stations[0].id,
        destination_station_id: stations[6].id,
        quantities: 100,
      },
      {
        train_id: trains[5].id,
        origin_station_id: stations[4].id,
        destination_station_id: stations[7].id,
        quantities: 180,
      },
      {
        train_id: trains[0].id,
        origin_station_id: stations[1].id,
        destination_station_id: stations[0].id,
        quantities: 120,
      },
      {
        train_id: trains[1].id,
        origin_station_id: stations[2].id,
        destination_station_id: stations[3].id,
        quantities: 70,
      },
      {
        train_id: trains[2].id,
        origin_station_id: stations[3].id,
        destination_station_id: stations[0].id,
        quantities: 200,
      },
      {
        train_id: trains[3].id,
        origin_station_id: stations[5].id,
        destination_station_id: stations[1].id,
        quantities: 180,
      },
    ]);
    console.log(`✅ Created ${trips.length} trips\n`);

    // ============ TRIP DEPARTURES ============
    console.log('Creating trip departures...');
    const now = new Date();
    const tripDepartures = await TripDeparture.bulkCreate([
      {
        trip_id: trips[0].id,
        departure_time: new Date(now.getTime() + 2 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 5 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[0].id,
        departure_time: new Date(now.getTime() + 8 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 11 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[1].id,
        departure_time: new Date(now.getTime() + 4 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 17 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[2].id,
        departure_time: new Date(now.getTime() + 6 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 16 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[3].id,
        departure_time: new Date(now.getTime() + 3 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 7 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[4].id,
        departure_time: new Date(now.getTime() + 5 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 7.5 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[5].id,
        departure_time: new Date(now.getTime() + 7 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 10 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[6].id,
        departure_time: new Date(now.getTime() + 24 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 27 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[7].id,
        departure_time: new Date(now.getTime() + 12 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 16 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[8].id,
        departure_time: new Date(now.getTime() + 18 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 28 * 60 * 60 * 1000),
      },
      {
        trip_id: trips[9].id,
        departure_time: new Date(now.getTime() + 36 * 60 * 60 * 1000),
        arrival_time: new Date(now.getTime() + 40 * 60 * 60 * 1000),
      },
    ]);
    console.log(`✅ Created ${tripDepartures.length} trip departures\n`);

    // ============ BOOKINGS ============
    console.log('Creating bookings...');
    const bookings = await Booking.bulkCreate([
      {
        user_id: users[1].id,
        trip_departure_id: tripDepartures[0].trip_departure_id,
        carriage_type_id: carriageTypes[0].carriage_type_id,
        seat_number: 'A12',
        number_of_seats: 2,
        total_price: 400.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[2].id,
        trip_departure_id: tripDepartures[2].trip_departure_id,
        carriage_type_id: carriageTypes[2].carriage_type_id,
        seat_number: 'B15',
        number_of_seats: 1,
        total_price: 325.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[3].id,
        trip_departure_id: tripDepartures[4].trip_departure_id,
        carriage_type_id: carriageTypes[2].carriage_type_id,
        seat_number: 'C22',
        number_of_seats: 3,
        total_price: 285.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[4].id,
        trip_departure_id: tripDepartures[5].trip_departure_id,
        carriage_type_id: carriageTypes[3].carriage_type_id,
        seat_number: 'A05',
        number_of_seats: 2,
        total_price: 600.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'pending',
      },
      {
        user_id: users[5].id,
        trip_departure_id: tripDepartures[6].trip_departure_id,
        carriage_type_id: carriageTypes[2].carriage_type_id,
        seat_number: 'B08',
        number_of_seats: 1,
        total_price: 100.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[1].id,
        trip_departure_id: tripDepartures[8].trip_departure_id,
        carriage_type_id: carriageTypes[0].carriage_type_id,
        seat_number: 'A20',
        number_of_seats: 1,
        total_price: 200.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[3].id,
        trip_departure_id: tripDepartures[9].trip_departure_id,
        carriage_type_id: carriageTypes[2].carriage_type_id,
        seat_number: 'C10',
        number_of_seats: 4,
        total_price: 400.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'pending',
      },
    ]);
    console.log(`✅ Created ${bookings.length} bookings\n`);

    // ============ PAYMENTS ============
    console.log('Creating payments...');
    const payments = await Payment.bulkCreate([
      {
        booking_id: bookings[0].booking_id,
        amount: bookings[0].total_price,
        date: new Date(),
        method: 'credit_card',
        status: 'completed',
      },
      {
        booking_id: bookings[1].booking_id,
        amount: bookings[1].total_price,
        date: new Date(),
        method: 'credit_card',
        status: 'completed',
      },
      {
        booking_id: bookings[2].booking_id,
        amount: bookings[2].total_price,
        date: new Date(),
        method: 'debit_card',
        status: 'completed',
      },
      {
        booking_id: bookings[3].booking_id,
        amount: bookings[3].total_price,
        date: new Date(),
        method: 'cash',
        status: 'pending',
      },
      {
        booking_id: bookings[4].booking_id,
        amount: bookings[4].total_price,
        date: new Date(),
        method: 'credit_card',
        status: 'completed',
      },
      {
        booking_id: bookings[5].booking_id,
        amount: bookings[5].total_price,
        date: new Date(),
        method: 'debit_card',
        status: 'completed',
      },
      {
        booking_id: bookings[6].booking_id,
        amount: bookings[6].total_price,
        date: new Date(),
        method: 'cash',
        status: 'pending',
      },
    ]);
    console.log(`✅ Created ${payments.length} payments\n`);

    console.log('🎉 Database seeding completed successfully!\n');
    console.log('📊 Summary:');
    console.log(`  - ${users.length} Users`);
    console.log(`  - ${stations.length} Stations`);
    console.log(`  - ${carriageTypes.length} Carriage Types`);
    console.log(`  - ${carriages.length} Carriages`);
    console.log(`  - ${trains.length} Trains`);
    console.log(`  - ${trainCarriages.length} Train-Carriage Links`);
    console.log(`  - ${trips.length} Trips`);
    console.log(`  - ${tripDepartures.length} Trip Departures`);
    console.log(`  - ${bookings.length} Bookings`);
    console.log(`  - ${payments.length} Payments`);

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  }
}

seedDatabase()
  .then(() => {
    console.log('\n✅ Seeding completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Seeding failed:', error);
    process.exit(1);
  });
