const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const CustomerOutstanding = sequelize.define('CustomerOutstanding', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  initialDue: {
    type: DataTypes.DECIMAL(15, 2),
    defaultValue: 0,
  },
  currentDue: {
    type: DataTypes.DECIMAL(15, 2),
    defaultValue: 0,
  },
  customerId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    unique: true,
    references: {
      model: 'customers',
      key: 'id'
    }
  },
}, {
  timestamps: true,
  tableName: 'customer_outstandings',
});

module.exports = CustomerOutstanding;