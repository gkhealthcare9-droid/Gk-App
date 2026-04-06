const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const ProductManufacturer = sequelize.define('ProductManufacturer', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  manufacturer: {
    type: DataTypes.STRING,
    allowNull: false,
  },
}, {
  timestamps: true,
  tableName: 'product_manufacturers',
});

module.exports = ProductManufacturer;