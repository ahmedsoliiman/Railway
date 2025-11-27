const db = require('../../config/database');
const bcrypt = require('bcryptjs');

async function runMigrations() {
  console.log('🚀 Starting database migrations...\n');

  try {
    // Create Users Table
    console.log('Creating users table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        full_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Users table created\n');

    // Create Email Verifications Table
    console.log('Creating email_verifications table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS email_verifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        verification_code VARCHAR(10) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Email verifications table created\n');

    // Create Stations Table
    console.log('Creating stations table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS stations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        city VARCHAR(255) NOT NULL,
        address TEXT,
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        facilities TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Stations table created\n');

    // Create Trains Table
    console.log('Creating trains table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS trains (
        id SERIAL PRIMARY KEY,
        train_number VARCHAR(50) UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        type VARCHAR(50) NOT NULL,
        total_seats INTEGER NOT NULL,
        first_class_seats INTEGER DEFAULT 0,
        second_class_seats INTEGER DEFAULT 0,
        facilities TEXT,
        status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'retired')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Trains table created\n');

    // Create Tours Table
    console.log('Creating tours table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS tours (
        id SERIAL PRIMARY KEY,
        train_id INTEGER REFERENCES trains(id) ON DELETE CASCADE,
        origin_station_id INTEGER REFERENCES stations(id),
        destination_station_id INTEGER REFERENCES stations(id),
        departure_time TIMESTAMP NOT NULL,
        arrival_time TIMESTAMP NOT NULL,
        first_class_price DECIMAL(10, 2),
        second_class_price DECIMAL(10, 2),
        available_seats INTEGER NOT NULL,
        status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'boarding', 'departed', 'arrived', 'cancelled')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Tours table created\n');

    // Create Reservations Table
    console.log('Creating reservations table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS reservations (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        tour_id INTEGER REFERENCES tours(id) ON DELETE CASCADE,
        seat_class VARCHAR(20) NOT NULL CHECK (seat_class IN ('first', 'second')),
        seat_number VARCHAR(10),
        number_of_seats INTEGER DEFAULT 1,
        total_price DECIMAL(10, 2) NOT NULL,
        booking_reference VARCHAR(20) UNIQUE NOT NULL,
        status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Reservations table created\n');

    // Create indexes for better performance
    console.log('Creating indexes...');
    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_tours_departure ON tours(departure_time);
      CREATE INDEX IF NOT EXISTS idx_reservations_user ON reservations(user_id);
      CREATE INDEX IF NOT EXISTS idx_reservations_tour ON reservations(tour_id);
    `);
    console.log('✅ Indexes created\n');

    // Insert default admin user
    console.log('Creating default admin user...');
    const hashedPassword = await bcrypt.hash('Admin@123', 10);
    await db.query(`
      INSERT INTO users (full_name, email, password, role, is_verified)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (email) DO NOTHING;
    `, ['Admin User', 'admin@trainbooking.com', hashedPassword, 'admin', true]);
    console.log('✅ Default admin user created (email: admin@trainbooking.com, password: Admin@123)\n');

    // Insert sample stations
    console.log('Inserting sample stations...');
    await db.query(`
      INSERT INTO stations (name, city, address, latitude, longitude, facilities)
      VALUES 
        ('Cairo Central Station', 'Cairo', 'Ramses Square, Cairo', 30.0626, 31.2497, 'WiFi, Restaurant, Waiting Room'),
        ('Alexandria Main Station', 'Alexandria', 'Misr Station, Alexandria', 31.1975, 29.8925, 'WiFi, Cafe, Parking'),
        ('Aswan Station', 'Aswan', 'Corniche El Nile, Aswan', 24.0889, 32.8998, 'WiFi, Waiting Room'),
        ('Luxor Station', 'Luxor', 'Station Street, Luxor', 25.6989, 32.6421, 'WiFi, Restaurant'),
        ('Mansoura Station', 'Mansoura', 'Railway Street, Mansoura', 31.0364, 31.3807, 'WiFi, Cafe')
      ON CONFLICT DO NOTHING;
    `);
    console.log('✅ Sample stations inserted\n');

    // Insert sample trains
    console.log('Inserting sample trains...');
    await db.query(`
      INSERT INTO trains (train_number, name, type, total_seats, first_class_seats, second_class_seats, facilities, status)
      VALUES 
        ('TR-001', 'Cairo Express', 'Express', 200, 50, 150, 'AC, WiFi, Food Service', 'active'),
        ('TR-002', 'Alexandria Elite', 'Premium', 150, 80, 70, 'AC, WiFi, Food Service, Entertainment', 'active'),
        ('TR-003', 'Nile Valley Train', 'Standard', 250, 60, 190, 'AC, WiFi', 'active'),
        ('TR-004', 'Desert Star', 'Express', 180, 70, 110, 'AC, WiFi, Food Service', 'active')
      ON CONFLICT (train_number) DO NOTHING;
    `);
    console.log('✅ Sample trains inserted\n');

    // Insert sample tours
    console.log('Inserting sample tours...');
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(8, 0, 0, 0);
    
    const tours = [
      { train: 1, origin: 1, dest: 2, dep: 8, arr: 12, first: 150, second: 80 },
      { train: 2, origin: 2, dest: 1, dep: 14, arr: 18, first: 160, second: 85 },
      { train: 3, origin: 1, dest: 3, dep: 20, arr: 32, first: 250, second: 120 },
      { train: 4, origin: 1, dest: 4, dep: 9, arr: 18, first: 200, second: 100 },
    ];

    for (const tour of tours) {
      const depTime = new Date(tomorrow);
      depTime.setHours(tour.dep, 0, 0, 0);
      const arrTime = new Date(tomorrow);
      arrTime.setHours(tour.arr, 0, 0, 0);

      await db.query(`
        INSERT INTO tours (train_id, origin_station_id, destination_station_id, departure_time, arrival_time, first_class_price, second_class_price, available_seats, status)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        ON CONFLICT DO NOTHING;
      `, [tour.train, tour.origin, tour.dest, depTime, arrTime, tour.first, tour.second, 200, 'scheduled']);
    }
    console.log('✅ Sample tours inserted\n');

    console.log('🎉 All migrations completed successfully!\n');
    console.log('📝 Default Admin Credentials:');
    console.log('   Email: admin@trainbooking.com');
    console.log('   Password: Admin@123\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Migration error:', error);
    process.exit(1);
  }
}

runMigrations();
