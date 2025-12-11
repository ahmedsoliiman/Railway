# Database Migrations

This directory contains Sequelize-based database migrations for the Train Booking System.

## Overview

Migrations are automatically tracked and executed when the server starts if `AUTO_MIGRATE=true` is set in `.env`.

## Configuration

Add to your `.env` file:

```env
# Automatically run pending migrations on server startup
AUTO_MIGRATE=true

# Automatically sync Sequelize models (not recommended in production)
AUTO_SYNC=false
```

## How It Works

1. **Automatic Execution**: When you start the server with `npm start`, the migration runner checks for pending migrations
2. **Tracking**: Executed migrations are recorded in the `migrations` table
3. **Safe**: Migrations only run once - previously executed migrations are skipped
4. **Sequential**: Migrations run in alphabetical order by filename

## Creating a New Migration

1. Create a new file in `src/database/migrations/` with a descriptive name:
   ```
   update_train_types_constraint.js
   add_user_phone_field.js
   create_booking_status_enum.js
   ```

2. Use this template:

```javascript
const sequelize = require('../../config/sequelize');

async function up() {
  console.log('🔄 Running migration: [Description]');
  
  try {
    // Your migration code here
    await sequelize.query(`
      ALTER TABLE your_table 
      ADD COLUMN new_field VARCHAR(255);
    `);
    
    console.log('✅ Migration completed successfully!');
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  }
}

async function down() {
  console.log('🔄 Rolling back migration: [Description]');
  
  try {
    // Rollback code here
    await sequelize.query(`
      ALTER TABLE your_table 
      DROP COLUMN new_field;
    `);
    
    console.log('✅ Rollback completed successfully!');
  } catch (error) {
    console.error('❌ Rollback failed:', error);
    throw error;
  }
}

module.exports = { up, down };
```

## Manual Migration Commands

You can also run migrations manually using the migration runner:

### Run all pending migrations
```bash
node src/database/migrations/migrationRunner.js up
```

### Rollback the last migration
```bash
node src/database/migrations/migrationRunner.js down
```

### Check migration status
```bash
node src/database/migrations/migrationRunner.js status
```

## Example Migrations

### Update Train Types

File: `update_train_types_constraint.js`

This migration updates the train types from the old values (premium, standard) to new values (express, ordinary, VIP, tahya masr, sleeper).

**What it does:**
- Updates existing records
- Drops old constraint
- Adds new constraint with updated types
- Provides rollback functionality

### Best Practices

1. **Always provide a down() function** for rollbacks
2. **Test migrations** in development before production
3. **Make migrations idempotent** - they should be safe to run multiple times
4. **Use transactions** for complex migrations
5. **Name files descriptively** - use clear, action-oriented names
6. **Include console logs** for debugging
7. **Handle errors gracefully** - always include try-catch blocks

## Production Considerations

⚠️ **Important for Production:**

1. **Set AUTO_MIGRATE=false** in production `.env`
2. **Run migrations manually** during deployment
3. **Backup database** before running migrations
4. **Test in staging** environment first
5. **Have rollback plan** ready

## Troubleshooting

### Migration fails to run

1. Check database connection
2. Review migration logs
3. Verify SQL syntax
4. Check for missing dependencies

### Migration runs twice

- Migrations are tracked in the `migrations` table
- Each migration only runs once
- If a migration fails, fix it and restart the server

### Rollback needed

```bash
# Rollback last migration
node src/database/migrations/migrationRunner.js down

# Or manually remove from migrations table
DELETE FROM migrations WHERE name = 'your_migration.js';
```

## Current Migrations

1. **update_train_types_constraint.js**
   - Updates train types to: express, ordinary, VIP, tahya masr, sleeper
   - Migrates existing data automatically
   - Status: ✅ Ready to use

## Migration History

The `migrations` table tracks all executed migrations:

```sql
SELECT * FROM migrations ORDER BY executed_at DESC;
```

This shows:
- Migration name
- Execution timestamp
- Order of execution
