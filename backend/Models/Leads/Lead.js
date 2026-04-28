const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Lead = sequelize.define('Lead', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  address: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  position: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  city: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  state: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  categoryId: {
    type: DataTypes.BIGINT,
    allowNull: true,
    references: {
      model: 'product_categories',
      key: 'id'
    }
  },
  leadValue: {
    type: DataTypes.DECIMAL(15, 2),
    allowNull: true,
  },
  company: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'new',
  },
  assignedId: {
    type: DataTypes.BIGINT,
    allowNull: true,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  source: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  leadType: {
    type: DataTypes.ENUM('hot', 'cold', 'warm'),
    defaultValue: 'cold',
  },
}, {
  timestamps: true,
  tableName: 'leads',
});

module.exports = Lead;
