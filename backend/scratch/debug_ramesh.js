const { sequelize } = require('../config/database');

async function debugRamesh() {
  try {
    const [results] = await sequelize.query('SELECT * FROM customer_contacts WHERE name = "Ramesh"');
    console.log('Ramesh current data:', results[0]);
    
    if (results[0]) {
      console.log('Attempting manual update to positionId = 3...');
      await sequelize.query('UPDATE customer_contacts SET positionId = 3 WHERE id = ?', { replacements: [results[0].id] });
      
      const [results2] = await sequelize.query('SELECT * FROM customer_contacts WHERE id = ?', { replacements: [results[0].id] });
      console.log('Ramesh data after manual update:', results2[0]);
    }
    
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

debugRamesh();
