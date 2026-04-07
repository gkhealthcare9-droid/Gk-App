require('dotenv').config();
const { State, City } = require('../Models/Location/State'); // Check where models are
const StateModel = require('../Models/Location/State');
const CityModel = require('../Models/Location/City');
const { sequelize } = require('../config/database');
const fs = require('fs');
const path = require('path');

// Extract JSON from the local file
const contentPath = path.join(__dirname, 'india_cities.json');

async function seedIndia() {
  try {
    console.log('--- Seeding All India Data ---');
    
    // Read and parse JSON content
    const rawContent = fs.readFileSync(contentPath, 'utf8');
    const citiesData = JSON.parse(rawContent);
    console.log(`Found ${citiesData.length} cities in dataset.`);

    await sequelize.authenticate();
    await sequelize.sync({ alter: true });

    // 1. Extract Unique States
    const stateNames = [...new Set(citiesData.map(c => c.state))].sort();
    console.log(`Found ${stateNames.length} unique states/UTs.`);

    const stateMap = {}; // name -> id

    for (const name of stateNames) {
      const [state] = await StateModel.findOrCreate({ where: { name } });
      stateMap[name] = state.id;
    }
    console.log('States seeded successfully.');

    // 2. Insert Cities (Bulk)
    // We clear existing cities first to avoid duplicates or messy data if re-running
    // Or just findOrCreate. Bulk is faster.
    console.log('Processing cities...');
    const cityRecords = citiesData.map(c => ({
      name: c.name,
      stateId: stateMap[c.state]
    }));

    // Chunk insertion to avoid huge queries
    const chunkSize = 100;
    for (let i = 0; i < cityRecords.length; i += chunkSize) {
      const chunk = cityRecords.slice(i, i + chunkSize);
      // We use findOrCreate for each to be safe but slow, OR just bulkCreate if table is clear
      // Let's use bulkCreate with updateOnDuplicate if supported, or just wipe and re-seed
      await CityModel.bulkCreate(chunk, { ignoreDuplicates: true });
    }

    console.log('--- Seeding Completed Successfully ---');
    process.exit(0);
  } catch (error) {
    console.error('Seeding failed:', error);
    process.exit(1);
  }
}

seedIndia();
