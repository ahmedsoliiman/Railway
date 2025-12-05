const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5433,
  database: 'train_system',
  user: 'postgres',
  password: 'testpass'
});

async function checkSchema() {
  try {
    await client.connect();
    console.log('Connected to database\n');

    // Get all tables
    const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);
    
    console.log('=== TABLES ===');
    tablesResult.rows.forEach(row => console.log(`  - ${row.table_name}`));
    console.log();

    // Get trips columns
    const tripsResult = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'trips' 
      ORDER BY ordinal_position;
    `);
    
    console.log('=== TRIPS TABLE ===');
    tripsResult.rows.forEach(row => {
      console.log(`  ${row.column_name}: ${row.data_type} ${row.is_nullable === 'NO' ? 'NOT NULL' : 'NULL'}`);
    });
    console.log();

    // Get reservations columns
    const reservationsResult = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'reservations' 
      ORDER BY ordinal_position;
    `);
    
    console.log('=== RESERVATIONS TABLE ===');
    reservationsResult.rows.forEach(row => {
      console.log(`  ${row.column_name}: ${row.data_type} ${row.is_nullable === 'NO' ? 'NOT NULL' : 'NULL'}`);
    });

    await client.end();
  } catch (error) {
    console.error('Error:', error.message);
    await client.end();
  }
}

checkSchema();
