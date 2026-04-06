const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Wallet = sequelize.define('Wallet', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    unique: true,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  balance: {
    type: DataTypes.DECIMAL(15, 2),
    defaultValue: 0,
  },
}, {
  timestamps: true,
  tableName: 'wallets',
});

module.exports = Wallet;