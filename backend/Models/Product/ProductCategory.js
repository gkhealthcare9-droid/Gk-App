const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const ProductCategory = sequelize.define('ProductCategory', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  productCategory: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  image: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: null,
  },
}, {
  timestamps: true,
  tableName: 'product_categories',
});

module.exports = ProductCategory;
