const bcrypt = require('bcryptjs');
const { User, Station, Carriage, Train, TrainCarriage, Trip, Reservation } = require('./src/models');

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...\n');

    // Clear existing data (optional - comment out if you want to keep existing data)
    console.log('Clearing existing data...');
    await Reservation.destroy({ where: {}, force: true });
    await Trip.destroy({ where: {}, force: true });
    await TrainCarriage.destroy({ where: {}, force: true });
    await Train.destroy({ where: {}, force: true });
    await Carriage.destroy({ where: {}, force: true });
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
        facilities: 'Waiting Lounge, Food Court, Wi-Fi, ATM, Restrooms',
      },
      {
        name: 'Alexandria Station',
        code: 'ALX',
        city: 'Alexandria',
        address: 'Mahattet Misr, Alexandria',
        facilities: 'Waiting Lounge, Cafeteria, Wi-Fi, Restrooms',
      },
      {
        name: 'Aswan Station',
        code: 'ASW',
        city: 'Aswan',
        address: 'Aswan City Center',
        facilities: 'Waiting Area, Snack Bar, Restrooms',
      },
      {
        name: 'Luxor Station',
        code: 'LXR',
        city: 'Luxor',
        address: 'Luxor City Center',
        facilities: 'Waiting Lounge, Restaurant, Wi-Fi, Restrooms',
      },
      {
        name: 'Giza Station',
        code: 'GIZ',
        city: 'Giza',
        address: 'Giza Square, Giza',
        facilities: 'Waiting Area, Food Kiosks, Restrooms',
      },
      {
        name: 'Port Said Station',
        code: 'PSD',
        city: 'Port Said',
        address: 'Port Said Downtown',
        facilities: 'Waiting Lounge, Café, Restrooms',
      },
      {
        name: 'Suez Station',
        code: 'SUZ',
        city: 'Suez',
        address: 'Suez City Center',
        facilities: 'Waiting Area, Snacks, Restrooms',
      },
      {
        name: 'Tanta Station',
        code: 'TNT',
        city: 'Tanta',
        address: 'Tanta Central, Gharbia',
        facilities: 'Waiting Lounge, Cafeteria, Restrooms',
      },
    ]);
    console.log(`✅ Created ${stations.length} stations\n`);

    // ============ CARRIAGES ============
    console.log('Creating carriages...');
    const carriages = await Carriage.bulkCreate([
      {
        name: 'First Class - VIP A',
        class_type: 'first',
        seats_count: 40,
        model: 'Luxury 2024',
        description: 'Premium seating with leather chairs, extra legroom, and power outlets',
      },
      {
        name: 'First Class - VIP B',
        class_type: 'first',
        seats_count: 40,
        model: 'Luxury 2024',
        description: 'Premium seating with leather chairs, extra legroom, and power outlets',
      },
      {
        name: 'First Class - Sleeper',
        class_type: 'first',
        seats_count: 20,
        model: 'Sleeper Deluxe 2024',
        description: 'Private cabins with beds for overnight journeys',
      },
      {
        name: 'Second Class - Standard A',
        class_type: 'second',
        seats_count: 60,
        model: 'Comfort 2023',
        description: 'Comfortable seating with adequate space',
      },
      {
        name: 'Second Class - Standard B',
        class_type: 'second',
        seats_count: 60,
        model: 'Comfort 2023',
        description: 'Comfortable seating with adequate space',
      },
      {
        name: 'Second Class - Economy A',
        class_type: 'second',
        seats_count: 80,
        model: 'Standard 2022',
        description: 'Basic seating for budget travelers',
      },
      {
        name: 'Second Class - Economy B',
        class_type: 'second',
        seats_count: 80,
        model: 'Standard 2022',
        description: 'Basic seating for budget travelers',
      },
    ]);
    console.log(`✅ Created ${carriages.length} carriages\n`);

    // ============ TRAINS ============
    console.log('Creating trains...');
    const trains = await Train.bulkCreate([
      {
        train_number: 'T001',
        name: 'Express Cairo-Alex',
        type: 'express',
        total_seats: 200,
        first_class_seats: 40,
        second_class_seats: 60,
        facilities: 'Wi-Fi, Air Conditioning, Dining Car',
        status: 'active',
      },
      {
        train_number: 'T002',
        name: 'Premium Nile Train',
        type: 'premium',
        total_seats: 180,
        first_class_seats: 80,
        second_class_seats: 60,
        facilities: 'Wi-Fi, Air Conditioning, Dining Car, Entertainment',
        status: 'active',
      },
      {
        train_number: 'T003',
        name: 'Standard Local',
        type: 'standard',
        total_seats: 240,
        first_class_seats: 40,
        second_class_seats: 120,
        facilities: 'Air Conditioning',
        status: 'active',
      },
      {
        train_number: 'T004',
        name: 'Overnight Express',
        type: 'express',
        total_seats: 100,
        first_class_seats: 60,
        second_class_seats: 40,
        facilities: 'Wi-Fi, Air Conditioning, Sleeping Cabins, Dining Car',
        status: 'active',
      },
      {
        train_number: 'T005',
        name: 'Delta Express',
        type: 'express',
        total_seats: 220,
        first_class_seats: 40,
        second_class_seats: 100,
        facilities: 'Wi-Fi, Air Conditioning',
        status: 'active',
      },
      {
        train_number: 'T006',
        name: 'Suez Canal Special',
        type: 'premium',
        total_seats: 160,
        first_class_seats: 80,
        second_class_seats: 60,
        facilities: 'Wi-Fi, Air Conditioning, Dining Car, VIP Lounge',
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
        departure: getDate(0, 0, 0),
        departure_time: getDate(0, 8, 0),
        arrival_time: getDate(0, 11, 0),
        first_class_price: 150.00,
        second_class_price: 80.00,
        quantities: 200,
      },
      {
        train_id: trains[1].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[2].id, // Aswan
        departure: getDate(1, 0, 0),
        departure_time: getDate(1, 9, 0),
        arrival_time: getDate(1, 20, 0),
        first_class_price: 350.00,
        second_class_price: 180.00,
        quantities: 180,
      },
      {
        train_id: trains[2].id,
        origin_station_id: stations[1].id, // Alexandria
        destination_station_id: stations[0].id, // Cairo
        departure: getDate(1, 0, 0),
        departure_time: getDate(1, 14, 0),
        arrival_time: getDate(1, 17, 0),
        first_class_price: 140.00,
        second_class_price: 75.00,
        quantities: 240,
      },
      {
        train_id: trains[3].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[3].id, // Luxor
        departure: getDate(2, 0, 0),
        departure_time: getDate(2, 22, 0),
        arrival_time: getDate(3, 8, 0),
        first_class_price: 450.00,
        second_class_price: 220.00,
        quantities: 100,
      },
      {
        train_id: trains[4].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[7].id, // Tanta
        departure: getDate(2, 0, 0),
        departure_time: getDate(2, 10, 0),
        arrival_time: getDate(2, 12, 30),
        first_class_price: 100.00,
        second_class_price: 55.00,
        quantities: 220,
      },
      {
        train_id: trains[5].id,
        origin_station_id: stations[0].id, // Cairo
        destination_station_id: stations[5].id, // Port Said
        departure: getDate(3, 0, 0),
        departure_time: getDate(3, 7, 0),
        arrival_time: getDate(3, 11, 0),
        first_class_price: 200.00,
        second_class_price: 110.00,
        quantities: 160,
      },
      // Next week trips
      {
        train_id: trains[0].id,
        origin_station_id: stations[1].id, // Alexandria
        destination_station_id: stations[4].id, // Giza
        departure: getDate(7, 0, 0),
        departure_time: getDate(7, 9, 0),
        arrival_time: getDate(7, 12, 30),
        first_class_price: 130.00,
        second_class_price: 70.00,
        quantities: 200,
      },
      {
        train_id: trains[1].id,
        origin_station_id: stations[3].id, // Luxor
        destination_station_id: stations[2].id, // Aswan
        departure: getDate(8, 0, 0),
        departure_time: getDate(8, 13, 0),
        arrival_time: getDate(8, 16, 30),
        first_class_price: 180.00,
        second_class_price: 95.00,
        quantities: 180,
      },
      {
        train_id: trains[2].id,
        origin_station_id: stations[6].id, // Suez
        destination_station_id: stations[0].id, // Cairo
        departure: getDate(9, 0, 0),
        departure_time: getDate(9, 15, 0),
        arrival_time: getDate(9, 18, 0),
        first_class_price: 120.00,
        second_class_price: 65.00,
        quantities: 240,
      },
      {
        train_id: trains[4].id,
        origin_station_id: stations[7].id, // Tanta
        destination_station_id: stations[1].id, // Alexandria
        departure: getDate(10, 0, 0),
        departure_time: getDate(10, 11, 0),
        arrival_time: getDate(10, 13, 30),
        first_class_price: 110.00,
        second_class_price: 60.00,
        quantities: 220,
      },
    ]);
    console.log(`✅ Created ${trips.length} trips\n`);

    // ============ RESERVATIONS ============
    console.log('Creating reservations...');
    const reservations = await Reservation.bulkCreate([
      {
        user_id: users[1].id, // John Smith
        trip_id: trips[0].id,
        seat_class: 'first',
        seat_number: 'A12',
        number_of_seats: 2,
        total_price: 300.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[2].id, // Sarah Johnson
        trip_id: trips[1].id,
        seat_class: 'second',
        seat_number: 'B15',
        number_of_seats: 1,
        total_price: 180.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[3].id, // Ahmed Hassan
        trip_id: trips[2].id,
        seat_class: 'second',
        seat_number: 'C22',
        number_of_seats: 3,
        total_price: 135.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[4].id, // Maria Garcia
        trip_id: trips[3].id,
        seat_class: 'first',
        seat_number: 'A05',
        number_of_seats: 2,
        total_price: 900.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'pending',
      },
      {
        user_id: users[5].id, // Mohamed Ali
        trip_id: trips[4].id,
        seat_class: 'second',
        seat_number: 'B08',
        number_of_seats: 1,
        total_price: 55.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[1].id,
        trip_id: trips[5].id,
        seat_class: 'first',
        seat_number: 'A20',
        number_of_seats: 1,
        total_price: 200.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'confirmed',
      },
      {
        user_id: users[2].id,
        trip_id: trips[6].id,
        seat_class: 'second',
        seat_number: 'C10',
        number_of_seats: 4,
        total_price: 180.00,
        booking_reference: 'BK' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'pending',
      },
    ]);
    console.log(`✅ Created ${reservations.length} reservations\n`);

    console.log('═══════════════════════════════════════════');
    console.log('🎉 Database seeding completed successfully!');
    console.log('═══════════════════════════════════════════\n');
    
    console.log('📊 Summary:');
    console.log(`   Users: ${users.length}`);
    console.log(`   Stations: ${stations.length}`);
    console.log(`   Carriages: ${carriages.length}`);
    console.log(`   Trains: ${trains.length}`);
    console.log(`   Train-Carriage Links: ${trainCarriages.length}`);
    console.log(`   Trips: ${trips.length}`);
    console.log(`   Reservations: ${reservations.length}\n`);
    
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
