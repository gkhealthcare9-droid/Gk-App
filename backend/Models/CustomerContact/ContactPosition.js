const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const ContactPosition = sequelize.define('ContactPosition', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  position: {
    type: DataTypes.STRING,
    allowNull: false,
  },
}, {
  timestamps: true,
  tableName: 'contact_positions',
});

module.exports = ContactPosition;
