const bcrypt = require('bcryptjs');
const { User, Station, Carriage, CarriageType, Train, TrainCarriage, Trip, TripDeparture, Booking, Payment } = require('./src/models');

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...\n');

    // Clear existing data (optional - comment out if you want to keep existing data)
    console.log('Clearing existing data...');
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
    console.log('✅ Existing data cleared\n');

    // ============ USERS ============
    console.log('Creating users...');
    const passwordHash = await bcrypt.hash('password123', 10);
    
    const users = await User.bulkCreate([
      {
        full_name: 'Admin User',
        email: 'admin@trainbooking.com',
        password: passwordHash,
        role: 'admin',
        is_verified: true,
        phone: '+201234567890',
      },
      {
        full_name: 'John Smith',
        email: 'john.smith@example.com',
        password: passwordHash,
        role: 'user',
        is_verified: true,
        phone: '+201234567891',
      },
      {
        full_name: 'Sarah Johnson',
        email: 'sarah.j@example.com',
        password: passwordHash,
        role: 'user',
        is_verified: true,
        phone: '+201234567892',
      },
      {
        full_name: 'Ahmed Hassan',
        email: 'ahmed.hassan@example.com',
        password: passwordHash,
        role: 'user',
        is_verified: true,
        phone: '+201234567893',
      },
      {
        full_name: 'Maria Garcia',
        email: 'maria.g@example.com',
        password: passwordHash,
        role: 'user',
        is_verified: true,
        phone: '+201234567894',
      },
      {
        full_name: 'Mohamed Ali',
        email: 'mohamed.ali@example.com',
        password: passwordHash,
        role: 'user',
        is_verified: true,
        phone: '+201234567895',
      },
    ]);
    console.log(`✅ Created ${users.length} users\n`);

    // ============ STATIONS ============
    console.log('Creating stations...');
    const stations = await Station.bulkCreate([
      {
        name: 'Cairo Central Station',
        code: 'CAI',
        city: 'Cairo',
        address: 'Ramses Square, Cairo',
      },
      {
        name: 'Alexandria Station',
        code: 'ALX',
        city: 'Alexandria',
        address: 'Mahattet Misr, Alexandria',
      },
      {
        name: 'Aswan Station',
        code: 'ASW',
        city: 'Aswan',
        address: 'Aswan City Center',
      },
      {
        name: 'Luxor Station',
        code: 'LXR',
        city: 'Luxor',
        address: 'Luxor City Center',
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
        address: 'Port Said Downtown',
      },
      {
        name: 'Suez Station',
        code: 'SUZ',
        city: 'Suez',
        address: 'Suez City Center',
      },
      {
        name: 'Tanta Station',
        code: 'TNT',
        city: 'Tanta',
        address: 'Tanta Central, Gharbia',
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
        type: 'sleeper',
        capacity: 20,
        price: 300.00,
      },
      {
        type: 'second class',
        capacity: 60,
        price: 130.00,
      },
      {
        type: 'third class',
        capacity: 80,
        price: 100.00,
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
      { carriage_number: 'C010', carriage_type_id: carriageTypes[3].carriage_type_id },
    ]);
    console.log(`✅ Created ${carriages.length} carriages\n`);

    // ============ TRAINS ============
    console.log('Creating trains...');
    const trains = await Train.bulkCreate([
      {
        train_number: 'T001',
        type: 'express',
        status: 'active',
      },
      {
        train_number: 'T002',
        type: 'premium',
        status: 'active',
      },
      {
        train_number: 'T003',
        type: 'standard',
        status: 'active',
      },
      {
        train_number: 'T004',
        type: 'express',
        status: 'active',
      },
      {
        train_number: 'T005',
        type: 'express',
        status: 'active',
      },
      {
        train_number: 'T006',
        type: 'premium',
        status: 'active',
      },
    ]);
    console.log(`✅ Created ${trains.length} trains\n`);

    // ============ TRAIN CARRIAGES ============
    console.log('Assigning carriages to trains...');
    const trainCarriages = await TrainCarriage.bulkCreate([
      // T001 - Express Cairo-Alex
      { train_id: trains[0].id, carriage_id: carriages[0].id, quantity: 1 },
      { train_id: trains[0].id, carriage_id: carriages[3].id, quantity: 1 },
      { train_id: trains[0].id, carriage_id: carriages[5].id, quantity: 2 },
      
      // T002 - Premium Nile Train
      { train_id: trains[1].id, carriage_id: carriages[0].id, quantity: 2 },
      { train_id: trains[1].id, carriage_id: carriages[3].id, quantity: 1 },
      { train_id: trains[1].id, carriage_id: carriages[4].id, quantity: 1 },
      
      // T003 - Standard Local
      { train_id: trains[2].id, carriage_id: carriages[1].id, quantity: 1 },
      { train_id: trains[2].id, carriage_id: carriages[4].id, quantity: 2 },
      { train_id: trains[2].id, carriage_id: carriages[5].id, quantity: 1 },
      
      // T004 - Overnight Sleeper
      { train_id: trains[3].id, carriage_id: carriages[2].id, quantity: 3 },
      { train_id: trains[3].id, carriage_id: carriages[1].id, quantity: 1 },
      { train_id: trains[3].id, carriage_id: carriages[3].id, quantity: 1 },
      
      // T005 - Delta Express
      { train_id: trains[4].id, carriage_id: carriages[0].id, quantity: 1 },
      { train_id: trains[4].id, carriage_id: carriages[4].id, quantity: 2 },
      { train_id: trains[4].id, carriage_id: carriages[6].id, quantity: 2 },
      
      // T006 - Suez Canal Special
      { train_id: trains[5].id, carriage_id: carriages[1].id, quantity: 2 },
      { train_id: trains[5].id, carriage_id: carriages[3].id, quantity: 1 },
      { train_id: trains[5].id, carriage_id: carriages[4].id, quantity: 1 },
    ]);
    console.log(`✅ Created ${trainCarriages.length} train-carriage assignments\n`);

    // ============ TRIPS ============
    console.log('Creating trips...');
    
    // Helper function to create date
    const getDate = (daysFromNow, hours, minutes) => {
      const date = new Date();
      date.setDate(date.getDate() + daysFromNow);
      date.setHours(hours, minutes, 0, 0);
      return date;
    };

    const trips = await Trip.bulkCreate([
      // Today and tomorrow trips
      {
        train_id: trains[0].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[1].id, // Alexandria
        base_price: 100.00,
        status: 'scheduled',
      },
      {
        train_id: trains[1].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[2].id, // Aswan
        base_price: 250.00,
        status: 'scheduled',
      },
      {
        train_id: trains[2].id,
        origin_station_id: stations[1].id, // Alexandria
        destination_station_id: stations[0].id, // Cairo
        base_price: 95.00,
        status: 'scheduled',
      },
      {
        train_id: trains[3].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[3].id, // Luxor
        base_price: 300.00,
        status: 'scheduled',
      },
      {
        train_id: trains[4].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[7].id, // Tanta
        base_price: 70.00,
        status: 'scheduled',
      },
      {
        train_id: trains[5].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[5].id, // Port Said
        base_price: 150.00,
        status: 'scheduled',
      },
      // Next week trips
      {
        train_id: trains[0].id,
        origin_station_id: stations[1].id, // Alexandria
        destination_station_id: stations[4].id, // Giza
        base_price: 90.00,
        status: 'scheduled',
      },
      {
        train_id: trains[1].id,
        origin_station_id: stations[3].id, // Luxor
        destination_station_id: stations[2].id, // Aswan
        base_price: 120.00,
        status: 'scheduled',
      },
      {
        train_id: trains[2].id,
        origin_station_id: stations[6].id, // Suez
        destination_station_id: stations[0].id, // Cairo
        base_price: 85.00,
        status: 'scheduled',
      },
      {
        train_id: trains[4].id,
        origin_station_id: stations[7].id, // Tanta
        destination_station_id: stations[1].id, // Alexandria
        base_price: 75.00,
        status: 'scheduled',
      },
    ]);
    console.log(`✅ Created ${trips.length} trips\n`);

    // ============ TRIP DEPARTURES ============
    console.log('Creating trip departures...');
    const tripDepartures = await TripDeparture.bulkCreate([
      // Trip 1 departures
      { trip_id: trips[0].id, departure_date: getDate(0, 0, 0), departure_time: getDate(0, 8, 0), arrival_time: getDate(0, 11, 0), available_seats: 200 },
      { trip_id: trips[0].id, departure_date: getDate(1, 0, 0), departure_time: getDate(1, 8, 0), arrival_time: getDate(1, 11, 0), available_seats: 200 },
      
      // Trip 2 departures
      { trip_id: trips[1].id, departure_date: getDate(1, 0, 0), departure_time: getDate(1, 9, 0), arrival_time: getDate(1, 20, 0), available_seats: 180 },
      { trip_id: trips[1].id, departure_date: getDate(2, 0, 0), departure_time: getDate(2, 9, 0), arrival_time: getDate(2, 20, 0), available_seats: 180 },
      
      // Trip 3 departures
      { trip_id: trips[2].id, departure_date: getDate(1, 0, 0), departure_time: getDate(1, 14, 0), arrival_time: getDate(1, 17, 0), available_seats: 240 },
      { trip_id: trips[2].id, departure_date: getDate(3, 0, 0), departure_time: getDate(3, 14, 0), arrival_time: getDate(3, 17, 0), available_seats: 240 },
      
      // Trip 4 departures
      { trip_id: trips[3].id, departure_date: getDate(2, 0, 0), departure_time: getDate(2, 22, 0), arrival_time: getDate(3, 8, 0), available_seats: 100 },
      
      // Trip 5 departures
      { trip_id: trips[4].id, departure_date: getDate(2, 0, 0), departure_time: getDate(2, 10, 0), arrival_time: getDate(2, 12, 30), available_seats: 220 },
      
      // Trip 6 departures
      { trip_id: trips[5].id, departure_date: getDate(3, 0, 0), departure_time: getDate(3, 7, 0), arrival_time: getDate(3, 11, 0), available_seats: 160 },
      
      // Trip 7 departures
      { trip_id: trips[6].id, departure_date: getDate(7, 0, 0), departure_time: getDate(7, 9, 0), arrival_time: getDate(7, 12, 30), available_seats: 200 },
      
      // Trip 8 departures
      { trip_id: trips[7].id, departure_date: getDate(8, 0, 0), departure_time: getDate(8, 13, 0), arrival_time: getDate(8, 16, 30), available_seats: 180 },
      
      // Trip 9 departures
      { trip_id: trips[8].id, departure_date: getDate(9, 0, 0), departure_time: getDate(9, 15, 0), arrival_time: getDate(9, 18, 0), available_seats: 240 },
      
      // Trip 10 departures
      { trip_id: trips[9].id, departure_date: getDate(10, 0, 0), departure_time: getDate(10, 11, 0), arrival_time: getDate(10, 13, 30), available_seats: 220 },
    ]);
    console.log(`✅ Created ${tripDepartures.length} trip departures\n`);

    // ============ BOOKINGS ============
    console.log('Creating bookings...');
    const bookings = await Booking.bulkCreate([
      {
        user_id: users[1].id, // John Smith
        trip_departure_id: tripDepartures[0].trip_departure_id,
        carriage_type_id: carriageTypes[0].carriage_type_id, // First Class VIP
        seat_number: 'A12',
        number_of_seats: 2,
        total_price: 400.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[2].id, // Sarah Johnson
        trip_departure_id: tripDepartures[2].trip_departure_id,
        carriage_type_id: carriageTypes[2].carriage_type_id,
        seat_number: 'B15',
        number_of_seats: 1,
        total_price: 325.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[3].id, // Ahmed Hassan
        trip_departure_id: tripDepartures[4].trip_departure_id,
        carriage_type_id: carriageTypes[3].carriage_type_id,
        seat_number: 'C22',
        number_of_seats: 3,
        total_price: 285.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[4].id, // Maria Garcia
        trip_departure_id: tripDepartures[6].trip_departure_id,
        carriage_type_id: carriageTypes[1].carriage_type_id,
        seat_number: 'A05',
        number_of_seats: 2,
        total_price: 1800.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'pending',
      },
      {
        user_id: users[5].id, // Mohamed Ali
        trip_departure_id: tripDepartures[7].trip_departure_id,
        carriage_type_id: carriageTypes[3].carriage_type_id,
        seat_number: 'B08',
        number_of_seats: 1,
        total_price: 70.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[1].id,
        trip_departure_id: tripDepartures[8].trip_departure_id,
        carriage_type_id: carriageTypes[0].carriage_type_id,
        seat_number: 'A20',
        number_of_seats: 1,
        total_price: 300.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[2].id,
        trip_departure_id: tripDepartures[9].trip_departure_id,
        carriage_type_id: carriageTypes[3].carriage_type_id,
        seat_number: 'C10',
        number_of_seats: 4,
        total_price: 360.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'pending',
      },
    ]);
    console.log(`✅ Created ${bookings.length} bookings\n`);

    // ============ PAYMENTS ============
    console.log('Creating payments...');
    const payments = await Payment.bulkCreate([
      {
        booking_id: bookings[0].id,
        amount: 400.00,
        payment_method: 'credit_card',
        payment_status: 'completed',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
      {
        booking_id: bookings[1].id,
        amount: 325.00,
        payment_method: 'credit_card',
        payment_status: 'completed',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
      {
        booking_id: bookings[2].id,
        amount: 285.00,
        payment_method: 'debit_card',
        payment_status: 'completed',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
      {
        booking_id: bookings[3].id,
        amount: 1800.00,
        payment_method: 'credit_card',
        payment_status: 'pending',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
      {
        booking_id: bookings[4].id,
        amount: 70.00,
        payment_method: 'cash',
        payment_status: 'completed',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
      {
        booking_id: bookings[5].id,
        amount: 300.00,
        payment_method: 'credit_card',
        payment_status: 'completed',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
      {
        booking_id: bookings[6].id,
        amount: 360.00,
        payment_method: 'debit_card',
        payment_status: 'pending',
        transaction_id: 'TXN' + Math.random().toString(36).substr(2, 12).toUpperCase(),
      },
    ]);
    console.log(`✅ Created ${payments.length} payments\n`);

    console.log('═══════════════════════════════════════════');
    console.log('🎉 Database seeding completed successfully!');
    console.log('═══════════════════════════════════════════\n');
    
    console.log('📊 Summary:');
    console.log(`   Users: ${users.length}`);
    console.log(`   Stations: ${stations.length}`);
    console.log(`   Carriage Types: ${carriageTypes.length}`);
    console.log(`   Carriages: ${carriages.length}`);
    console.log(`   Trains: ${trains.length}`);
    console.log(`   Train-Carriage Links: ${trainCarriages.length}`);
    console.log(`   Trips: ${trips.length}`);
    console.log(`   Trip Departures: ${tripDepartures.length}`);
    console.log(`   Bookings: ${bookings.length}`);
    console.log(`   Payments: ${payments.length}\n`);
    
    console.log('🔐 Test Accounts:');
    console.log('   Admin: admin@trainbooking.com / password123');
    console.log('   User:  john.smith@example.com / password123');
    console.log('   User:  sarah.j@example.com / password123\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run the seeding
seedDatabase();
