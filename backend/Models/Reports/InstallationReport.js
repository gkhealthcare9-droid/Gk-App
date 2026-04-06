const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const InstallationReport = sequelize.define('InstallationReport', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
  },
  reportNumber: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true,
  },
  customerId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'customers',
            key: 'id'
        }
  },
  date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  productCategoryId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'product_categories',
            key: 'id'
        }
  },
  manufacturerId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'product_manufacturers',
            key: 'id'
        }
  },
  slNumber: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  soldDate: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  warranty: {
    type: DataTypes.DATE,
    allowNull: true,
    defaultValue: null,
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'working',
  },
  actionTaken: {
    type: DataTypes.TEXT,
    allowNull: true,
    defaultValue: null,
  },
  noteByEngineer: {
    type: DataTypes.TEXT,
    allowNull: true,
    defaultValue: null,
  },
  engineerId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'users',
            key: 'id'
        }
  },
  clientNameId: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'employees',
            key: 'id'
        }
  },
  signedById: {
    type: DataTypes.BIGINT,
    allowNull: false,
    references: {
            model: 'employees',
            key: 'id'
        }
  },
  clientSignature: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: null,
  },
  pdf: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: null,
  },
}, {
  timestamps: true,
  tableName: 'installation_reports',
});

module.exports = InstallationReport;
