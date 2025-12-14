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
  type: { 
    type: DataTypes.STRING(50),
    allowNull: false,
    validate: {
      isIn: {
        args: [['express', 'ordinary', 'VIP', 'tahya masr', 'sleeper']],
        msg: 'Train type must be one of: express, ordinary, VIP, tahya masr, sleeper'
      }
    }
  },
  status: { 
    type: DataTypes.STRING(50),
    allowNull: false,
    defaultValue: 'active',
    validate: {
      isIn: {
        args: [['active', 'maintenance', 'retired']],
        msg: 'Status must be one of: active, maintenance, retired'
      }
    }
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
