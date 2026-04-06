const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Employees = sequelize.define('Employees', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  dob: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  positionId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'employee_categories',
            key: 'id'
        }
  },
  customerId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'customers',
            key: 'id'
        }
  },
}, {
  timestamps: true,
  tableName: 'employees',
});

module.exports = Employees;
