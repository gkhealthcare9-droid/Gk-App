const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  productCategoryId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
      model: 'product_categories',
      key: 'id'
    }
  },
  productName: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  productId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true,
  },
  tax: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 0,
  },
  HSN: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  rate: {
    type: DataTypes.DECIMAL(15, 2),
    allowNull: false,
  },
  images: {
    type: DataTypes.JSON, // Use JSON column for array of images
    defaultValue: [],
  },
}, {
  timestamps: true,
  tableName: 'products',
});

module.exports = Product;
