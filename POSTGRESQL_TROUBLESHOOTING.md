# PostgreSQL Connection Troubleshooting

## If PostgreSQL is running but still can't connect:

### Step 1: Check PostgreSQL Port
Your PostgreSQL might be running on a different port.

**Find the actual port:**
1. Open pgAdmin
2. Look at existing servers in the left panel
3. Or check PostgreSQL installation folder: `C:\Program Files\PostgreSQL\[version]\data\postgresql.conf`
4. Search for `port =` in that file

**Common ports:**
- 5432 (default)
- 5433 (alternative)

### Step 2: Update Project Configuration

If PostgreSQL is on port 5432, update the `.env` file:

```env
DB_PORT=5432
```

If on port 5433, keep:
```env
DB_PORT=5433
```

### Step 3: Create Database First

**Before running migrations**, create the database:

**Option A: Using pgAdmin**
1. Right-click "Databases"
2. Create → Database
3. Name: `train_system`
4. Save

**Option B: Using SQL Query Tool**
1. Connect to PostgreSQL (to "postgres" database)
2. Open Query Tool
3. Run:
```sql
CREATE DATABASE train_system;
```

### Step 4: Test Connection from Command Line

```bash
# Test if PostgreSQL is accessible
psql -U postgres -d postgres -p 5432

# If password prompt appears, PostgreSQL is working!
# Enter your password
# Type \q to exit
```

### Step 5: Check Firewall

Windows Firewall might be blocking:
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Look for "postgres" or "PostgreSQL"
4. Ensure both Private and Public are checked

### Step 6: Restart Everything

```bash
# Restart PostgreSQL service
net stop postgresql-x64-14
net start postgresql-x64-14

# Then try connecting again
```

## Quick Test Command

Run this in your terminal to test connection:

```bash
cd Backend
node -e "const db = require('./src/config/database'); db.pool.query('SELECT NOW()', (err, res) => { if(err) console.error('❌', err.message); else console.log('✅ Connected!', res.rows[0]); process.exit(); })"
```

This will tell you if Node.js can connect to PostgreSQL.
