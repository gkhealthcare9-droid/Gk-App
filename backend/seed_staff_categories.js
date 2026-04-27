const { sequelize } = require('./config/database');
const Category = require('./Models/Classification/Category');

async function seedStaffCategories() {
  try {
    await sequelize.authenticate();
    const categories = await Category.findAll({ where: { type: 'Employee' } });
    
    if (categories.length === 0) {
      console.log('No Employee categories found. Seeding default staff positions...');
      const staffPositions = [
        'Sales Executive',
        'Service Engineer',
        'Sales Manager',
        'Accountant',
        'Administrator',
        'Technical Support',
        'Operations Manager'
      ];
      
      for (const name of staffPositions) {
        await Category.create({ name, type: 'Employee' });
      }
      console.log('Staff positions seeded successfully.');
    } else {
      console.log('Employee categories already exist:', categories.map(c => c.name));
    }
  } catch (error) {
    console.error('Error seeding staff categories:', error);
  } finally {
    await sequelize.close();
  }
}

seedStaffCategories();
