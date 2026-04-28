const express = require('express');
const router = express.Router();
const State = require('../../Models/Location/State');
const City = require('../../Models/Location/City');
const auth = require('../../Middleware/auth');

// ========== State Routes ==========
router.post('/states/add', auth, async (req, res) => {
  try {
    const state = await State.create(req.body);
    res.status(201).json(state);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/states', async (req, res) => {
  try {
    const states = await State.findAll({ order: [['name', 'ASC']] });
    res.json(states);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update State
router.put('/states/:id', auth, async (req, res) => {
  try {
    const { name } = req.body;
    const state = await State.findByPk(req.params.id);
    if (!state) return res.status(404).json({ error: 'State not found' });

    await state.update({ name });
    res.json(state);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete State
router.delete('/states/:id', auth, async (req, res) => {
  try {
    const state = await State.findByPk(req.params.id);
    if (!state) return res.status(404).json({ error: 'State not found' });

    // Check if state has cities
    const citiesCount = await City.count({ where: { stateId: req.params.id } });
    if (citiesCount > 0) {
      return res.status(400).json({ error: 'Cannot delete state with existing cities' });
    }

    await state.destroy();
    res.json({ message: 'State deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ========== City Routes ==========
router.post('/cities/add', auth, async (req, res) => {
  try {
    const city = await City.create(req.body);
    res.status(201).json(city);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/cities', auth, async (req, res) => {
  try {
    const cities = await City.findAll({ include: [State], order: [['name', 'ASC']] });
    res.json(cities);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/cities/by-state/:stateId', async (req, res) => {
  try {
    const sId = req.params.stateId;
    console.log(`--- API: Fetching cities for stateId: ${sId} ---`);

    const cities = await City.findAll({
      where: { stateId: sId },
      attributes: [
        [City.sequelize.fn('MIN', City.sequelize.col('id')), 'id'],
        'name'
      ],
      group: ['name'],
      order: [['name', 'ASC']]
    });

    console.log(`--- API: Found ${cities.length} unique cities for stateId: ${sId} ---`);
    res.json(cities);
  } catch (err) {
    console.error('--- API Error (cities/by-state):', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Update City
router.put('/cities/:id', auth, async (req, res) => {
  try {
    const { name, stateId } = req.body;
    const city = await City.findByPk(req.params.id);
    if (!city) return res.status(404).json({ error: 'City not found' });
    
    await city.update({ name, stateId });
    res.json(city);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete City
router.delete('/cities/:id', auth, async (req, res) => {
  try {
    const city = await City.findByPk(req.params.id);
    if (!city) return res.status(404).json({ error: 'City not found' });
    
    await city.destroy();
    res.json({ message: 'City deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
