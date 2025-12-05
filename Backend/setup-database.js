const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function setupDatabase() {
  console.log('🚀 Starting database setup...\n');

  // First, connect to the default 'postgres' database
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5433,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    database: 'postgres', // Connect to default database first
  });

  try {
    await client.connect();
    console.log('✅ Connected to PostgreSQL server\n');

    // Check if train_system database exists
    const checkDb = await client.query(
      `SELECT 1 FROM pg_database WHERE datname = '${process.env.DB_NAME || 'train_system'}'`
    );

    if (checkDb.rows.length > 0) {
      console.log('⚠️  Database already exists. Do you want to recreate it?');
      console.log('   This will DELETE all existing data!');
      console.log('   To recreate, manually drop the database and run this script again.\n');
      console.log('   Or run: DROP DATABASE train_system; in PostgreSQL\n');
      await client.end();
      process.exit(0);
    }

    console.log('📝 Creating database and tables...\n');

    // Create the database
    await client.query(`CREATE DATABASE ${process.env.DB_NAME || 'train_system'}`);
    console.log('✅ Database created\n');

    await client.end();

    // Connect to the newly created database
    const dbClient = new Client({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5433,
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME || 'train_system',
    });

    await dbClient.connect();
    console.log('✅ Connected to train_system database\n');

    // Read and execute the schema.sql file as a single transaction
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');

    try {
      await dbClient.query(schema);
    } catch (err) {
      console.error('Error executing schema:', err.message);
      throw err;
    }

    await dbClient.end();

    console.log('✅ All tables created successfully!\n');
    console.log('📊 Database setup complete!\n');
    console.log('Tables created:');
    console.log('  • users (with admin user)');
    console.log('  • email_verifications');
    console.log('  • stations (with sample data)');
    console.log('  • trains (with sample data)');
    console.log('  • carriages (with sample data)');
    console.log('  • train_carriages');
    console.log('  • trips (with sample data)');
    console.log('  • reservations\n');
    console.log('🔐 Admin credentials:');
    console.log('  Email: admin@trainbooking.com');
    console.log('  Password: Admin@123\n');
    console.log('🚂 You can now start the server with: node server.js\n');

  } catch (error) {
    console.error('❌ Error during database setup:', error.message);
    process.exit(1);
  }
}

setupDatabase();
