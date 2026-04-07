const express = require('express');
const router = express.Router();
const { State, City } = require('../../Models/Location/State');
const StateModel = require('../../Models/Location/State');
const CityModel = require('../../Models/Location/City');
const fs = require('fs');
const path = require('path');
const auth = require('../../Middleware/auth'); // Optional: Add auth if you want it protected

router.post('/india', async (req, res) => {
  try {
    console.log('--- Seeding All India Data (Via Route) ---');
    
    // Read local JSON file
    const contentPath = path.join(__dirname, '../../scripts/india_cities.json');
    if (!fs.existsSync(contentPath)) {
      return res.status(404).json({ message: 'india_cities.json not found in scripts folder' });
    }

    const rawContent = fs.readFileSync(contentPath, 'utf8');
    const citiesData = JSON.parse(rawContent);
    
    // 1. Extract Unique States
    const stateNames = [...new Set(citiesData.map(c => c.state))].sort();
    const stateMap = {}; 

    for (const name of stateNames) {
      const [state] = await StateModel.findOrCreate({ where: { name } });
      stateMap[name] = state.id;
    }

    // 2. Insert Cities
    const cityRecords = citiesData.map(c => ({
      name: c.name,
      stateId: stateMap[c.state]
    }));

    await CityModel.bulkCreate(cityRecords, { ignoreDuplicates: true });

    res.status(200).json({ 
      message: 'Seeding successful', 
      statesCount: stateNames.length, 
      citiesCount: citiesData.length 
    });
  } catch (error) {
    console.error('Seeding route failed:', error);
    res.status(500).json({ message: 'Seeding failed', error: error.message });
  }
});

module.exports = router;
