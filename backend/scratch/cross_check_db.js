const { sequelize } = require('../config/database');

async function crossCheck() {
  try {
    const [contacts] = await sequelize.query('SELECT * FROM customer_contacts');
    const [positions] = await sequelize.query('SELECT * FROM contact_positions');
    const [customers] = await sequelize.query('SELECT id, hospitalName FROM customers LIMIT 5');

    console.log('--- DATABASE CROSS-CHECK ---');
    console.log('Total Contacts:', contacts.length);
    contacts.forEach(c => {
      console.log(`Contact: ID=${c.id}, Name=${c.name}, PosID=${c.positionId}, CustID=${c.customerId}`);
    });

    console.log('\nTotal Positions:', positions.length);
    positions.forEach(p => {
      console.log(`Position: ID=${p.id}, Name=${p.position}`);
    });

    console.log('\nSample Customers:');
    customers.forEach(cu => {
      console.log(`Customer: ID=${cu.id}, Name=${cu.hospitalName}`);
    });
    
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

crossCheck();
