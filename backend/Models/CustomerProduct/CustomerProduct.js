const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');

const CustomerProduct = sequelize.define('CustomerProduct', {
    id: {
        type: DataTypes.BIGINT,
        primaryKey: true,
        autoIncrement: true,
    },
    customerId: {
        type: DataTypes.BIGINT,
        allowNull: false,
        references: {
            model: 'customers',
            key: 'id'
        }
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
    amcStart: {
        type: DataTypes.DATE,
        allowNull: true,
        defaultValue: null,
    },
    amcEnd: {
        type: DataTypes.DATE,
        allowNull: true,
        defaultValue: null,
    },
}, {
    timestamps: true,
    tableName: 'customer_products',
});

module.exports = CustomerProduct;
