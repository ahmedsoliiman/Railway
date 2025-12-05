const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Train = sequelize.define('Train', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  train_number: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  type: {
    type: DataTypes.STRING(50),
    allowNull: false,
  },
  total_seats: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  first_class_seats: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  second_class_seats: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  facilities: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  status: {
    type: DataTypes.STRING(20),
    defaultValue: 'active',
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
  tableName: 'trains',
  timestamps: false,
  underscored: true,
});

module.exports = Train;
