const { sequelize } = require('./config/database');
const ContactPosition = require('./Models/CustomerContact/ContactPosition');

async function seedPositions() {
  try {
    await sequelize.authenticate();
    const positions = await ContactPosition.findAll();
    if (positions.length === 0) {
      console.log('No positions found. Seeding default positions...');
      const defaultPositions = [
        'Doctor',
        'Nurse',
        'Technician',
        'Administrator',
        'Purchase Manager',
        'Biomedical Engineer',
        'HOD',
        'Clerk'
      ];
      for (const pos of defaultPositions) {
        await ContactPosition.create({ position: pos });
      }
      console.log('Seeding completed.');
    } else {
      console.log('Positions already exist:', positions.map(p => p.position));
    }
  } catch (error) {
    console.error('Error seeding positions:', error);
  } finally {
    await sequelize.close();
  }
}

seedPositions();
