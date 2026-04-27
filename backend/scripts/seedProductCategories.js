const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const { sequelize } = require('../config/database');
const Category = require('../Models/Classification/Category');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('✅ Connected to Database.');

    const productCategories = [
      'Dialysis Machine',
      'Reprocessing Machine',
      'PTS'
    ];

    console.log('--- Seeding Product Categories ---');

    for (const name of productCategories) {
      const [category, created] = await Category.findOrCreate({
        where: { name, type: 'Product' },
        defaults: { name, type: 'Product' }
      });

      if (created) {
        console.log(`➕ Created category: ${name}`);
      } else {
        console.log(`ℹ️ Category already exists: ${name}`);
      }
    }

    console.log('✅ Seeding completed successfully!');
  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    await sequelize.close();
    process.exit(0);
  }
}

seed();
