const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const VendorEmployeeCategory = sequelize.define('VendorEmployeeCategory', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
  },
}, {
  timestamps: true,
  tableName: 'vendor_employee_categories',
});

module.exports = VendorEmployeeCategory;
