const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const City = sequelize.define('City', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  stateId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
      model: 'states',
      key: 'id'
    }
  },
}, {
  timestamps: true,
  tableName: 'cities',
  indexes: [
    {
      unique: true,
      fields: ['stateId', 'name']
    }
  ]
});

module.exports = City;
