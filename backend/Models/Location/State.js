const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const State = sequelize.define('State', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
}, {
  timestamps: true,
  tableName: 'states',
});

module.exports = State;
