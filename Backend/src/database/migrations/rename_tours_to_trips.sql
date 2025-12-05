-- Migration: Rename 'tours' to 'trips' and 'tour_id' to 'trip_id'
-- Date: 2025-12-05

BEGIN;

-- Step 1: Rename the tours table to trips
ALTER TABLE tours RENAME TO trips;

-- Step 2: Rename the tour_id column in reservations table to trip_id
ALTER TABLE reservations RENAME COLUMN tour_id TO trip_id;

-- Step 3: Update the foreign key constraint name (optional, for clarity)
-- First, find the existing constraint name
-- You may need to adjust this based on your actual constraint name
-- ALTER TABLE reservations DROP CONSTRAINT reservations_tour_id_fkey;
-- ALTER TABLE reservations ADD CONSTRAINT reservations_trip_id_fkey 
--   FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE;

COMMIT;
