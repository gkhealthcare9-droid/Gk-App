const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const FollowUp = sequelize.define('FollowUp', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  leadId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
      model: 'leads',
      key: 'id'
    }
  },
  datetime: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  timestamps: true,
  tableName: 'followups',
});

module.exports = FollowUp;
