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

router.get('/states', auth, async (req, res) => {
  try {
    const states = await State.findAll({ order: [['name', 'ASC']] });
    res.json(states);
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

router.get('/cities/by-state/:stateId', auth, async (req, res) => {
  try {
    const cities = await City.findAll({ where: { stateId: req.params.stateId }, order: [['name', 'ASC']] });
    res.json(cities);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
