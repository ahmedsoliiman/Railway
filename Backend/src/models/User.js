const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  full_name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
    },
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    field: 'password', // Map to 'password' column in DB
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
  role: {
    type: DataTypes.STRING(20),
    defaultValue: 'user',
    allowNull: false,
  },
  is_verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  verification_token: {
    type: DataTypes.STRING(10),
    allowNull: true,
  },
  verification_token_expires: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'users',
  timestamps: false, // We manage timestamps manually
  underscored: true,
});

module.exports = User;
