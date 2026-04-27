const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');
const ContactPosition = require('./ContactPosition');

const CustomerContact = sequelize.define('CustomerContact', {
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
  },
  phone2: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  positionId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
      model: 'contact_positions',
      key: 'id'
    }
  },
  customerId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
      model: 'customers',
      key: 'id'
    }
  },
}, {
  timestamps: true,
  tableName: 'customer_contacts',
});

// Associations
CustomerContact.belongsTo(ContactPosition, { foreignKey: 'positionId', as: 'position' });
ContactPosition.hasMany(CustomerContact, { foreignKey: 'positionId' });

module.exports = CustomerContact;
