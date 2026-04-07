const { State, City } = require('../Models/Location/State'); // Wait, models might be exported differently
const StateModel = require('../Models/Location/State');
const CityModel = require('../Models/Location/City');
const { sequelize } = require('../config/database');

const seedKarnataka = async () => {
  try {
    console.log('--- Seeding Karnataka Data ---');
    
    // Ensure connection
    await sequelize.authenticate();
    
    // Sync to ensure tables exist
    await sequelize.sync({ alter: true });

    // 1. Create/Find Karnataka State
    const [state, created] = await StateModel.findOrCreate({
      where: { name: 'Karnataka' },
      defaults: { name: 'Karnataka' }
    });

    console.log(created ? 'Created state: Karnataka' : 'Karnataka state already exists');

    // 2. List of Cities
    const majorCities = [
      'Bengaluru', 'Mysuru', 'Hubballi-Dharwad', 'Kalaburagi', 'Mangaluru',
      'Belagavi', 'Davanagere', 'Ballari', 'Vijayapura', 'Shivamogga',
      'Tumakuru', 'Raichur', 'Bidar', 'Udupi', 'Hosapete',
      'Gadag-Betageri', 'Hassan', 'Bhadravati', 'Chitradurga', 'Kolar',
      'Mandya', 'Chikmagalur', 'Gangavati', 'Bagalkot', 'Ranebennuru'
    ];

    let cityCount = 0;
    for (const cityName of majorCities) {
      const [city, cityCreated] = await CityModel.findOrCreate({
        where: { name: cityName, stateId: state.id },
        defaults: { name: cityName, stateId: state.id }
      });
      if (cityCreated) cityCount++;
    }

    console.log(`Successfully seeded ${cityCount} new cities in Karnataka.`);
  } catch (err) {
    console.error('Error seeding Karnataka data:', err);
  } finally {
    // We don't necessarily want to close it if it's called from another script
    // but for standalone it's good.
    // process.exit();
  }
};

if (require.main === module) {
  seedKarnataka().then(() => process.exit());
}

module.exports = seedKarnataka;
