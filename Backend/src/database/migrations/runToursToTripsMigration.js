const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5433,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'train_booking_db',
});

async function runMigration() {
  const client = await pool.connect();
  
  try {
    console.log('Starting migration: Rename tours to trips...');
    
    await client.query('BEGIN');
    
    // Step 1: Rename the tours table to trips
    console.log('Step 1: Renaming tours table to trips...');
    await client.query('ALTER TABLE tours RENAME TO trips');
    console.log('✓ Table renamed successfully');
    
    // Step 2: Rename the tour_id column in reservations to trip_id
    console.log('Step 2: Renaming tour_id column to trip_id...');
    await client.query('ALTER TABLE reservations RENAME COLUMN tour_id TO trip_id');
    console.log('✓ Column renamed successfully');
    
    await client.query('COMMIT');
    
    console.log('\n✅ Migration completed successfully!');
    console.log('- tours table → trips table');
    console.log('- reservations.tour_id → reservations.trip_id');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

runMigration().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
