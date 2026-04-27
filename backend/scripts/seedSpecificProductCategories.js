const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const { sequelize } = require('../config/database');
const ProductCategory = require('../Models/Product/ProductCategory');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('✅ Connected to Database.');

    const categoriesToSeed = [
      'Dialysis Machine',
      'Reprocessing Machine',
      'PTS'
    ];

    console.log('--- Seeding Specific Product Categories ---');

    for (const name of categoriesToSeed) {
      const [category, created] = await ProductCategory.findOrCreate({
        where: { productCategory: name },
        defaults: { productCategory: name }
      });

      if (created) {
        console.log(`➕ Created ProductCategory: ${name}`);
      } else {
        console.log(`ℹ️ ProductCategory already exists: ${name}`);
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
