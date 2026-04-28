const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Vendor = sequelize.define('Vendor', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  vendorName: { type: DataTypes.STRING, allowNull: false },
  vendorPhone: { type: DataTypes.STRING, allowNull: true },
  vendorEmail: { type: DataTypes.STRING, allowNull: true },
  vendorGSTIN: { type: DataTypes.STRING, allowNull: true },
  vendorCompany: { type: DataTypes.STRING, allowNull: true },
  addressOne: { type: DataTypes.STRING, allowNull: true },
  addressTwo: { type: DataTypes.STRING, allowNull: true },
  city: { type: DataTypes.STRING, allowNull: true },
  state: { type: DataTypes.STRING, allowNull: true },
  pincode: { type: DataTypes.STRING, allowNull: true },
  vendorQuniqueNumber: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: true,
  },
}, {
  timestamps: true,
  tableName: 'vendors',
});

module.exports = Vendor;
