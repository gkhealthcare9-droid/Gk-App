const { Sequelize } = require('sequelize');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function initialize() {
  const { DB_HOST, DB_USER, DB_PASSWORD, DB_NAME } = process.env;

  console.log(`--- Attempting Connection to MySQL on ${DB_HOST} ---`);

  try {
    // 1. Create database if it doesn't exist
    console.log(`Checking if database '${DB_NAME}' exists...`);
    const connection = await mysql.createConnection({
            host: DB_HOST || 'localhost',
            user: DB_USER || 'root',
            password: DB_PASSWORD || ''
        });
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;`);
    console.log(`✅ Database '${DB_NAME}' checked/created.`);
    await connection.end();

    // 2. Test Sequelize connection
    const { connectDB } = require('../config/database');
    await connectDB();
    console.log('✅ Connection Establishment Verified!');
  } catch (error) {
    console.error('❌ Connection Failed Registry!');
    console.error('Error Details:', error.message);
    if (error.message.includes('ECONNREFUSED')) {
      console.log('TIP: Make sure the "MySQL" module is started in your XAMPP Control Panel.');
    }
  } finally {
    process.exit();
  }
}

initialize();
