const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const Task = sequelize.define('Task', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  taskNumber: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true,
  },
  taskCategory: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  taskName: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  taskDescription: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  taskStatus: {
    type: DataTypes.ENUM('Pending', 'In-Progress', 'Completed'),
    defaultValue: 'Pending',
  },
  assignedToId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  dueDate: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  priority: {
    type: DataTypes.ENUM('Low', 'Medium', 'High'),
    defaultValue: 'Medium',
  },
  customerId: {
    type: DataTypes.BIGINT,
    allowNull: true,
    references: {
      model: 'customers',
      key: 'id'
    }
  },
}, {
  timestamps: true,
  tableName: 'tasks',
});

// Associations
const User = require('../User/User');
const Customer = require('../Customer/Customer');

Task.belongsTo(User, { as: 'assignedTo', foreignKey: 'assignedToId' });
Task.belongsTo(Customer, { foreignKey: 'customerId' });

module.exports = Task;