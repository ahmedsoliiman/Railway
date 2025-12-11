-- Update train types constraint
-- Run this to update the database with new train types

-- Drop the old constraint
ALTER TABLE trains DROP CONSTRAINT IF EXISTS trains_type_check;

-- Add new constraint with updated train types
ALTER TABLE trains ADD CONSTRAINT trains_type_check 
CHECK (type IN ('express', 'ordinary', 'VIP', 'tahya masr', 'sleeper'));

-- Update existing trains with old types to new types
UPDATE trains SET type = 'express' WHERE type = 'premium';
UPDATE trains SET type = 'ordinary' WHERE type = 'standard';
