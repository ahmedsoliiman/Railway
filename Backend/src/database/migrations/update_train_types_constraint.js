const sequelize = require('../../config/sequelize');

/**
 * Migration: Update train types constraint
 * Changes: express, premium, standard -> express, ordinary, VIP, tahya masr, sleeper
 */

async function up() {
  const queryInterface = sequelize.getQueryInterface();
  
  console.log('🔄 Updating train types constraint...');
  
  try {
    // Step 1: Update existing records
    console.log('  → Updating existing train records...');
    await sequelize.query(`
      UPDATE trains 
      SET type = CASE 
        WHEN type = 'premium' THEN 'express'
        WHEN type = 'standard' THEN 'ordinary'
        ELSE type 
      END
      WHERE type IN ('premium', 'standard');
    `);
    
    // Step 2: Drop old constraint
    console.log('  → Dropping old constraint...');
    await sequelize.query(`
      ALTER TABLE trains DROP CONSTRAINT IF EXISTS trains_type_check;
    `);
    
    // Step 3: Add new constraint
    console.log('  → Adding new constraint...');
    await sequelize.query(`
      ALTER TABLE trains 
      ADD CONSTRAINT trains_type_check 
      CHECK (type IN ('express', 'ordinary', 'VIP', 'tahya masr', 'sleeper'));
    `);
    
    console.log('✅ Train types constraint updated successfully!\n');
    console.log('   New types: express, ordinary, VIP, tahya masr, sleeper\n');
  } catch (error) {
    console.error('❌ Error updating train types:', error);
    throw error;
  }
}

async function down() {
  console.log('🔄 Reverting train types constraint...');
  
  try {
    // Revert to old constraint
    await sequelize.query(`
      ALTER TABLE trains DROP CONSTRAINT IF EXISTS trains_type_check;
    `);
    
    await sequelize.query(`
      ALTER TABLE trains 
      ADD CONSTRAINT trains_type_check 
      CHECK (type IN ('express', 'premium', 'standard'));
    `);
    
    // Revert data
    await sequelize.query(`
      UPDATE trains 
      SET type = CASE 
        WHEN type = 'ordinary' THEN 'standard'
        WHEN type = 'VIP' THEN 'premium'
        WHEN type = 'tahya masr' THEN 'express'
        WHEN type = 'sleeper' THEN 'express'
        ELSE type 
      END;
    `);
    
    console.log('✅ Train types constraint reverted successfully!\n');
  } catch (error) {
    console.error('❌ Error reverting train types:', error);
    throw error;
  }
}

// Allow running this migration directly
if (require.main === module) {
  (async () => {
    try {
      await up();
      console.log('✅ Migration completed successfully!');
      process.exit(0);
    } catch (error) {
      console.error('❌ Migration failed:', error);
      process.exit(1);
    }
  })();
}

module.exports = { up, down };
