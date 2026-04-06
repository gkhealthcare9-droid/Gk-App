const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const EmployeeCategory = sequelize.define('EmployeeCategory', {
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
  tableName: 'employee_categories',
});

module.exports = EmployeeCategory;
