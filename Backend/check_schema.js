const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'train_system',
  user: 'postgres',
  password: 'testpass'
});

pool.query(
  "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users' ORDER BY ordinal_position",
  (err, res) => {
    if (err) {
      console.error('Error:', err);
    } else {
      console.log('Users table columns:');
      res.rows.forEach(row => {
        console.log(`  - ${row.column_name}: ${row.data_type}`);
      });
    }
    pool.end();
  }
);
