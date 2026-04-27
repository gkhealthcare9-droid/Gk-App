const { sequelize } = require('../config/database');

async function listAll() {
  try {
    const [results] = await sequelize.query('SELECT id, name, phone, customerId FROM customer_contacts');
    console.log('All contacts in customer_contacts:');
    results.forEach(c => {
      console.log(`- ID: ${c.id}, Name: ${c.name}, Phone: ${c.phone}, Customer: ${c.customerId}`);
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

listAll();
