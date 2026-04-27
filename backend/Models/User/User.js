const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const User = sequelize.define('User', {
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
    unique: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
    },
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  dob: {
    type: DataTypes.DATE,
  },
  doj: {
    type: DataTypes.DATE,
  },
  lastLogin: {
    type: DataTypes.DATE,
  },
  userType: {
    type: DataTypes.ENUM('admin', 'user'),
    defaultValue: 'user',
  },
  positionId: {
    type: DataTypes.BIGINT,
    allowNull: true,
    references: {
      model: 'categories',
      key: 'id'
    }
  },
}, {
  timestamps: true,
  tableName: 'users',
});

module.exports = User;

const Category = require('../Classification/Category');
User.belongsTo(Category, { foreignKey: 'positionId', as: 'position' });
