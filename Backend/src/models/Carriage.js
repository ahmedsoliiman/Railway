const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Carriage = sequelize.define('Carriage', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  class_type: {
    type: DataTypes.ENUM('first', 'second', 'economic'),
    allowNull: false,
  },
  seats_count: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
    },
  },
  model: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  description: {
    type: DataTypes.TEXT,
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
  tableName: 'carriages',
  timestamps: false,
  underscored: true,
});

module.exports = Carriage;
