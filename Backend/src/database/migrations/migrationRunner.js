const fs = require('fs');
const path = require('path');
const sequelize = require('../../config/sequelize');

/**
 * Migration Runner
 * Automatically runs all migration files in the migrations directory
 */

// Create migrations tracking table
async function createMigrationsTable() {
  await sequelize.query(`
    CREATE TABLE IF NOT EXISTS migrations (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) UNIQUE NOT NULL,
      executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);
}

// Get list of executed migrations
async function getExecutedMigrations() {
  const [results] = await sequelize.query(`
    SELECT name FROM migrations ORDER BY executed_at ASC;
  `);
  return results.map(r => r.name);
}

// Mark migration as executed
async function markMigrationExecuted(migrationName) {
  await sequelize.query(`
    INSERT INTO migrations (name) VALUES (:name);
  `, {
    replacements: { name: migrationName }
  });
}

// Get all migration files
function getMigrationFiles() {
  const migrationsDir = __dirname;
  const files = fs.readdirSync(migrationsDir);
  
  return files
    .filter(file => 
      file.endsWith('.js') && 
      file !== 'migrationRunner.js' &&
      file !== 'runMigrations.js' &&
      file !== 'runToursToTripsMigration.js'
    )
    .sort(); // Sort alphabetically
}

// Run all pending migrations
async function runAllMigrations() {
  try {
    console.log('📦 Checking for pending migrations...\n');
    
    // Ensure migrations table exists
    await createMigrationsTable();
    
    // Get executed migrations
    const executedMigrations = await getExecutedMigrations();
    console.log(`   Already executed: ${executedMigrations.length} migrations`);
    
    // Get all migration files
    const allMigrations = getMigrationFiles();
    console.log(`   Total migrations found: ${allMigrations.length}\n`);
    
    // Find pending migrations
    const pendingMigrations = allMigrations.filter(
      migration => !executedMigrations.includes(migration)
    );
    
    if (pendingMigrations.length === 0) {
      console.log('✅ No pending migrations. Database is up to date!\n');
      return;
    }
    
    console.log(`🔄 Found ${pendingMigrations.length} pending migration(s):\n`);
    
    // Run each pending migration
    for (const migrationFile of pendingMigrations) {
      console.log(`   ▶ Running: ${migrationFile}`);
      
      try {
        const migration = require(path.join(__dirname, migrationFile));
        
        if (typeof migration.up !== 'function') {
          console.log(`   ⚠️  Skipping ${migrationFile}: No 'up' function found\n`);
          continue;
        }
        
        // Run the migration
        await migration.up();
        
        // Mark as executed
        await markMigrationExecuted(migrationFile);
        
        console.log(`   ✅ Completed: ${migrationFile}\n`);
      } catch (error) {
        console.error(`   ❌ Failed: ${migrationFile}`);
        console.error(`   Error: ${error.message}\n`);
        throw error; // Stop on first error
      }
    }
    
    console.log('✅ All migrations completed successfully!\n');
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  }
}

// Run a specific migration
async function runMigration(migrationName) {
  try {
    await createMigrationsTable();
    
    const migration = require(path.join(__dirname, migrationName));
    
    if (typeof migration.up !== 'function') {
      throw new Error(`Migration ${migrationName} does not have an 'up' function`);
    }
    
    console.log(`🔄 Running migration: ${migrationName}`);
    await migration.up();
    await markMigrationExecuted(migrationName);
    console.log(`✅ Migration completed: ${migrationName}\n`);
  } catch (error) {
    console.error(`❌ Migration failed: ${migrationName}`, error);
    throw error;
  }
}

// Rollback last migration
async function rollbackLastMigration() {
  try {
    await createMigrationsTable();
    
    const executedMigrations = await getExecutedMigrations();
    
    if (executedMigrations.length === 0) {
      console.log('ℹ️  No migrations to rollback');
      return;
    }
    
    const lastMigration = executedMigrations[executedMigrations.length - 1];
    console.log(`🔄 Rolling back migration: ${lastMigration}`);
    
    const migration = require(path.join(__dirname, lastMigration));
    
    if (typeof migration.down !== 'function') {
      throw new Error(`Migration ${lastMigration} does not have a 'down' function`);
    }
    
    await migration.down();
    
    // Remove from migrations table
    await sequelize.query(`
      DELETE FROM migrations WHERE name = :name;
    `, {
      replacements: { name: lastMigration }
    });
    
    console.log(`✅ Rollback completed: ${lastMigration}\n`);
  } catch (error) {
    console.error('❌ Rollback failed:', error);
    throw error;
  }
}

// CLI execution
if (require.main === module) {
  const command = process.argv[2];
  
  (async () => {
    try {
      switch (command) {
        case 'up':
          await runAllMigrations();
          break;
        case 'down':
          await rollbackLastMigration();
          break;
        case 'status':
          await createMigrationsTable();
          const executed = await getExecutedMigrations();
          const all = getMigrationFiles();
          const pending = all.filter(m => !executed.includes(m));
          console.log(`\n📊 Migration Status:`);
          console.log(`   Executed: ${executed.length}`);
          console.log(`   Pending: ${pending.length}`);
          console.log(`   Total: ${all.length}\n`);
          if (pending.length > 0) {
            console.log('Pending migrations:');
            pending.forEach(m => console.log(`   - ${m}`));
          }
          break;
        default:
          console.log(`
Usage: node migrationRunner.js [command]

Commands:
  up       Run all pending migrations
  down     Rollback the last migration
  status   Show migration status
          `);
      }
      process.exit(0);
    } catch (error) {
      console.error('Error:', error);
      process.exit(1);
    }
  })();
}

module.exports = {
  runAllMigrations,
  runMigration,
  rollbackLastMigration,
  getExecutedMigrations,
  getMigrationFiles
};
