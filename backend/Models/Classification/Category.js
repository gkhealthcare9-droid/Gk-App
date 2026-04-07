const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Category = sequelize.define('Category', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  type: {
    type: DataTypes.ENUM('Employee', 'Product', 'General'),
    defaultValue: 'General',
  },
}, {
  timestamps: true,
  tableName: 'categories',
});

module.exports = Category;
