const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Customer = sequelize.define('Customer', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  customerName: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  customerPhone: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: null,
  },
  customerPhone2: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  customerEmail: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: null,
  },
  customerGSTIN: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: null,
  },
  customerCompany: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  customerQuniqueNumber: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  addressOne: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  addressTwo: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  city: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  state: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  pincode: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  timestamps: true,
  tableName: 'customers',
});

module.exports = Customer;
