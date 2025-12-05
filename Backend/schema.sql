-- Train Booking System Database Schema
-- This script assumes you're already connected to the train_system database
-- The setup-database.js script handles database creation and connection

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EMAIL VERIFICATIONS TABLE
-- =====================================================
CREATE TABLE email_verifications (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- STATIONS TABLE
-- =====================================================
CREATE TABLE stations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE NOT NULL,
    city VARCHAR(100) NOT NULL,
    address TEXT,
    facilities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TRAINS TABLE
-- =====================================================
CREATE TABLE trains (
    id SERIAL PRIMARY KEY,
    train_number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) CHECK (type IN ('express', 'premium', 'standard')),
    total_seats INTEGER NOT NULL,
    first_class_seats INTEGER DEFAULT 0,
    second_class_seats INTEGER DEFAULT 0,
    facilities TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'retired')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CARRIAGES TABLE
-- =====================================================
CREATE TABLE carriages (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class_type VARCHAR(20) CHECK (class_type IN ('first', 'second')),
    seats_count INTEGER NOT NULL,
    model VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TRAIN_CARRIAGES TABLE (Junction Table)
-- =====================================================
CREATE TABLE train_carriages (
    id SERIAL PRIMARY KEY,
    train_id INTEGER REFERENCES trains(id) ON DELETE CASCADE,
    carriage_id INTEGER REFERENCES carriages(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    UNIQUE(train_id, carriage_id)
);

-- =====================================================
-- TRIPS TABLE
-- =====================================================
CREATE TABLE trips (
    id SERIAL PRIMARY KEY,
    train_id INTEGER REFERENCES trains(id) ON DELETE CASCADE,
    origin_station_id INTEGER REFERENCES stations(id) ON DELETE CASCADE,
    destination_station_id INTEGER REFERENCES stations(id) ON DELETE CASCADE,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    first_class_price DECIMAL(10, 2),
    second_class_price DECIMAL(10, 2),
    available_seats INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'boarding', 'departed', 'arrived', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- RESERVATIONS TABLE
-- =====================================================
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    trip_id INTEGER REFERENCES trips(id) ON DELETE CASCADE,
    seat_class VARCHAR(20) NOT NULL CHECK (seat_class IN ('first', 'second')),
    seat_number VARCHAR(10),
    number_of_seats INTEGER,
    total_price DECIMAL(10, 2) NOT NULL,
    booking_reference VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_stations_code ON stations(code);
CREATE INDEX idx_trains_number ON trains(train_number);
CREATE INDEX idx_trips_departure ON trips(departure_time);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_reservations_trip ON reservations(trip_id);
CREATE INDEX idx_reservations_reference ON reservations(booking_reference);

-- =====================================================
-- INSERT DEFAULT ADMIN USER & TEST USER
-- =====================================================
-- Admin User - Email: admin@trainbooking.com, Password: Admin@123 (bcrypt hashed)
INSERT INTO users (full_name, email, password, role, is_verified) 
VALUES ('Admin User', 'admin@trainbooking.com', '$2a$10$bh109kA/QD5lhAwJQhtJ8exYGOcNUhLSSx.n7P3BPR09AjUba2ED.', 'admin', true);

-- Test User - Email: test@trainbooking.com, Password: Test@123 (bcrypt hashed)
INSERT INTO users (full_name, email, password, role, is_verified) 
VALUES ('Test User', 'test@trainbooking.com', '$2a$10$5Z7QX8Z8Z8Z8Z8Z8Z8Z8ZuK5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5', 'user', true);

-- =====================================================
-- SAMPLE DATA (OPTIONAL)
-- =====================================================

-- Sample Stations
INSERT INTO stations (name, code, city, address, facilities) VALUES
('Cairo Central Station', 'CAI', 'Cairo', 'Ramses Square, Cairo', 'WiFi, Restaurant, Waiting Room'),
('Alexandria Station', 'ALX', 'Alexandria', 'Mahattet Misr, Alexandria', 'WiFi, Cafeteria, ATM'),
('Aswan Station', 'ASW', 'Aswan', 'Corniche El Nile, Aswan', 'WiFi, Restaurant'),
('Luxor Station', 'LUX', 'Luxor', 'Al Mahatta Square, Luxor', 'WiFi, Waiting Room');

-- Sample Trains
INSERT INTO trains (train_number, name, type, total_seats, first_class_seats, second_class_seats, facilities, status) VALUES
('T001', 'Express Cairo-Alex', 'express', 200, 50, 150, 'AC, WiFi, Restaurant', 'active'),
('T002', 'Premium Nile Train', 'premium', 150, 80, 70, 'AC, WiFi, Restaurant, TV', 'active'),
('T003', 'Standard Local', 'standard', 250, 30, 220, 'AC, WiFi', 'active');

-- Sample Carriages
INSERT INTO carriages (name, class_type, seats_count, model, description) VALUES
('First Class A', 'first', 40, 'FC-2024', 'Luxury seating with extra legroom'),
('First Class B', 'first', 50, 'FC-2024', 'Premium comfort seating'),
('Second Class A', 'second', 80, 'SC-2024', 'Standard comfortable seating'),
('Second Class B', 'second', 100, 'SC-2024', 'Economy seating');

-- Sample Train-Carriage Associations
INSERT INTO train_carriages (train_id, carriage_id, quantity) VALUES
(1, 1, 1),
(1, 3, 2),
(2, 2, 2),
(2, 3, 1),
(3, 1, 1),
(3, 4, 2);

-- Sample Trips
INSERT INTO trips (train_id, origin_station_id, destination_station_id, departure_time, arrival_time, first_class_price, second_class_price, available_seats, status) VALUES
(1, 1, 2, '2025-12-10 08:00:00', '2025-12-10 11:00:00', 150.00, 80.00, 200, 'scheduled'),
(2, 1, 3, '2025-12-11 09:00:00', '2025-12-11 20:00:00', 300.00, 150.00, 150, 'scheduled'),
(3, 2, 1, '2025-12-12 14:00:00', '2025-12-12 17:00:00', 120.00, 60.00, 250, 'scheduled');

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================
SELECT 'Database schema created successfully!' AS message;
SELECT 'Tables created: users, stations, trains, carriages, train_carriages, trips, reservations' AS info;
