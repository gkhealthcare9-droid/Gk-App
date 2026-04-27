const { sequelize } = require('../config/database');

async function checkCols() {
  try {
    const [results] = await sequelize.query('SHOW COLUMNS FROM customer_contacts');
    console.log('Columns in customer_contacts:');
    results.forEach(col => {
      console.log(`- ${col.Field} (${col.Type})`);
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

checkCols();
