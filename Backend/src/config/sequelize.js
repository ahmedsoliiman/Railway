const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5433,
    dialect: 'postgres',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 20,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

// Test connection and optionally sync models
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Sequelize: Database connection established successfully');
    
    // Auto-sync tables in development
    // This automatically updates the database schema to match your models
    if (process.env.AUTO_SYNC === 'true') {
      await sequelize.sync({ alter: true }); // alter: true = automatically update existing tables
      console.log('✅ Sequelize: All models synchronized with database (schema updated automatically)');
    }
  } catch (error) {
    console.error('❌ Sequelize: Unable to connect to database:', error);
    process.exit(-1);
  }
};

testConnection();

module.exports = sequelize;
