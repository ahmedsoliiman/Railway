const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const CarriageType = sequelize.define('CarriageType', {
  carriage_type_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  type: {
    type: DataTypes.STRING(50),
    allowNull: false,
    validate: {
      isIn: {
        args: [['first class', 'second class', 'third class', 'sleeper']],
        msg: 'Carriage type must be one of: first class, second class, third class, sleeper'
      }
    }
  },
  capacity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: {
        args: [1],
        msg: 'Capacity must be at least 1'
      },
      max: {
        args: [100],
        msg: 'Capacity cannot exceed 100'
      }
    }
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: {
        args: [0],
        msg: 'Price must be non-negative'
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
  tableName: 'carriage_types',
  timestamps: false,
  underscored: true,
});

module.exports = CarriageType;
