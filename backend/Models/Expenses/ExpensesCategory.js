const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const ExpensesCategory = sequelize.define('ExpensesCategory', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  expensesCategory: {
    type: DataTypes.STRING,
    allowNull: false,
  },
}, {
  timestamps: true,
  tableName: 'expenses_categories',
});

module.exports = ExpensesCategory;
