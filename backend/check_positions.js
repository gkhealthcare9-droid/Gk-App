const { sequelize } = require('./config/database');
const ContactPosition = require('./Models/CustomerContact/ContactPosition');

async function checkPositions() {
  try {
    await sequelize.authenticate();
    const positions = await ContactPosition.findAll();
    console.log('Current positions:', JSON.stringify(positions, null, 2));
    if (positions.length === 0) {
      console.log('No positions found. Suggesting adding some.');
    }
  } catch (error) {
    console.error('Error checking positions:', error);
  } finally {
    await sequelize.close();
  }
}

checkPositions();
