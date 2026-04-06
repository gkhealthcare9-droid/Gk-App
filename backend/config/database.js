const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = process.env.MYSQL_URL
  ? new Sequelize(process.env.MYSQL_URL, { logging: false })
  : new Sequelize(
      process.env.MYSQLDATABASE || process.env.DB_NAME || 'gk_healthcare',
      process.env.MYSQLUSER || process.env.DB_USER || 'root',
      process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || '',
      {
        host: process.env.MYSQLHOST || process.env.DB_HOST || 'localhost',
        port: process.env.MYSQLPORT || process.env.DB_PORT || 3306,
        dialect: 'mysql',
        logging: false,
      }
    );

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connected to MySQL 🚀');
    // Sync models with the database
    await sequelize.sync({ alter: true });
  } catch (error) {
    console.error('❌ MySQL connection error:', error.message);
    process.exit(1);
  }
};

module.exports = { sequelize, connectDB };
