-- Database Restructuring Migration
-- This script updates the schema to match the academic requirements

-- Step 1: Create CarriageType table
CREATE TABLE IF NOT EXISTS carriage_types (
  carriage_type_id SERIAL PRIMARY KEY,
  type VARCHAR(50) NOT NULL CHECK (type IN ('first class', 'second class', 'third class', 'sleeper')),
  capacity INTEGER NOT NULL CHECK (capacity >= 1 AND capacity <= 100),
  price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Insert default carriage types
INSERT INTO carriage_types (type, capacity, price) VALUES
('first class', 40, 150.00),
('second class', 60, 100.00),
('third class', 80, 60.00),
('sleeper', 30, 200.00)
ON CONFLICT DO NOTHING;

-- Step 3: Create TripDeparture table
CREATE TABLE IF NOT EXISTS trip_departures (
  departure_id SERIAL PRIMARY KEY,
  trip_id INTEGER NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  departure_time TIMESTAMP NOT NULL,
  arrival_time TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (arrival_time > departure_time)
);

-- Step 4: Migrate existing trip timing data to TripDeparture
INSERT INTO trip_departures (trip_id, departure_time, arrival_time)
SELECT id, departure_time, arrival_time FROM trips
WHERE departure_time IS NOT NULL AND arrival_time IS NOT NULL
ON CONFLICT DO NOTHING;

-- Step 5: Create Payment table (rename from bookings to avoid conflict)
CREATE TABLE IF NOT EXISTS payments (
  payment_id SERIAL PRIMARY KEY,
  booking_id INTEGER NOT NULL,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('credit_card', 'debit_card', 'cash')),
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 6: Rename reservations table to bookings
ALTER TABLE IF EXISTS reservations RENAME TO bookings;

-- Step 7: Update bookings table structure
ALTER TABLE IF EXISTS bookings RENAME COLUMN id TO booking_id;
ALTER TABLE IF EXISTS bookings 
  ALTER COLUMN status TYPE VARCHAR(20),
  DROP CONSTRAINT IF EXISTS bookings_status_check;
ALTER TABLE IF EXISTS bookings
  ADD CONSTRAINT bookings_status_check CHECK (status IN ('pending', 'confirmed', 'cancelled'));

-- Step 8: Add foreign key to payments after bookings rename
ALTER TABLE IF EXISTS payments
  ADD CONSTRAINT fk_payments_booking
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;

-- Step 9: Update Carriage table
-- Add carriage_type_id column
ALTER TABLE IF EXISTS carriages ADD COLUMN IF NOT EXISTS carriage_type_id INTEGER;

-- Migrate existing class_type data to carriage_type_id
UPDATE carriages SET carriage_type_id = (
  CASE 
    WHEN class_type = 'first' THEN (SELECT carriage_type_id FROM carriage_types WHERE type = 'first class')
    WHEN class_type = 'second' THEN (SELECT carriage_type_id FROM carriage_types WHERE type = 'second class')
    WHEN class_type = 'economic' THEN (SELECT carriage_type_id FROM carriage_types WHERE type = 'third class')
    ELSE (SELECT carriage_type_id FROM carriage_types WHERE type = 'second class')
  END
)
WHERE carriage_type_id IS NULL;

-- Add foreign key constraint
ALTER TABLE IF EXISTS carriages
  ADD CONSTRAINT fk_carriages_carriage_type
  FOREIGN KEY (carriage_type_id) REFERENCES carriage_types(carriage_type_id) ON DELETE RESTRICT;

-- Drop old columns from carriages
ALTER TABLE IF EXISTS carriages DROP COLUMN IF EXISTS class_type;
ALTER TABLE IF EXISTS carriages DROP COLUMN IF EXISTS seats_count;

-- Step 10: Update Train table
-- Remove unnecessary columns
ALTER TABLE IF EXISTS trains DROP COLUMN IF EXISTS train_number;
ALTER TABLE IF EXISTS trains DROP COLUMN IF EXISTS total_seats;
ALTER TABLE IF EXISTS trains DROP COLUMN IF EXISTS first_class_seats;
ALTER TABLE IF EXISTS trains DROP COLUMN IF EXISTS second_class_seats;

-- Update status field type
ALTER TABLE IF EXISTS trains
  ALTER COLUMN status TYPE VARCHAR(50);

-- Step 11: Update Trip table
-- Remove pricing and timing columns
ALTER TABLE IF EXISTS trips DROP COLUMN IF EXISTS first_class_price;
ALTER TABLE IF EXISTS trips DROP COLUMN IF EXISTS second_class_price;
ALTER TABLE IF EXISTS trips DROP COLUMN IF EXISTS departure;
ALTER TABLE IF EXISTS trips DROP COLUMN IF EXISTS departure_time;
ALTER TABLE IF EXISTS trips DROP COLUMN IF EXISTS arrival_time;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_trip_departures_trip_id ON trip_departures(trip_id);
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_carriages_type_id ON carriages(carriage_type_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_trip_id ON bookings(trip_id);

-- Migration complete
SELECT 'Database restructuring migration completed successfully!' AS status;
