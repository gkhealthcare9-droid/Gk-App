const { sequelize } = require('../config/database');

async function checkPos() {
  try {
    const [results] = await sequelize.query('SELECT * FROM contact_positions');
    console.log('Positions in contact_positions:');
    results.forEach(pos => {
      console.log(`- ID: ${pos.id}, Name: ${pos.position}`);
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

checkPos();
