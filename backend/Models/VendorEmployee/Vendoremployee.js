const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const VendorEmployee = sequelize.define('VendorEmployee', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  name: { type: DataTypes.STRING, allowNull: false },
  phone: { type: DataTypes.STRING, allowNull: false },
  email: { type: DataTypes.STRING, allowNull: true },
  dob: { type: DataTypes.DATE, allowNull: true },
  positionId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'vendor_employee_categories',
            key: 'id'
        }
  },
  vendorId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'vendors',
            key: 'id'
        }
  },
}, {
  timestamps: true,
  tableName: 'vendor_employees',
});

module.exports = VendorEmployee;
