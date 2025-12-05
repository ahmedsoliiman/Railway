const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const TrainCarriage = sequelize.define('TrainCarriage', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  train_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'trains',
      key: 'id',
    },
    onDelete: 'CASCADE',
  },
  carriage_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'carriages',
      key: 'id',
    },
    onDelete: 'RESTRICT',
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: 1,
    },
  },
}, {
  tableName: 'train_carriages',
  timestamps: false,
  underscored: true,
  indexes: [
    {
      unique: true,
      fields: ['train_id', 'carriage_id'],
    },
  ],
});

module.exports = TrainCarriage;
