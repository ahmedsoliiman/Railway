const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Carriage = sequelize.define('Carriage', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  carriage_number: { 
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  carriage_type_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'carriage_types',
      key: 'carriage_type_id',
    },
    onUpdate: 'CASCADE',
    onDelete: 'RESTRICT',
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
