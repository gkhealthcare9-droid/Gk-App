const express = require('express');
const router = express.Router();
const Category = require('../../Models/Classification/Category');
const auth = require('../../Middleware/auth');

// Create category
router.post('/add', auth, async (req, res) => {
  try {
    const category = await Category.create(req.body);
    res.status(201).json(category);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all categories
router.get('/', auth, async (req, res) => {
  try {
    const { type } = req.query;
    const filter = type ? { where: { type } } : {};
    const categories = await Category.findAll({ ...filter, order: [['name', 'ASC']] });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update category
router.put('/:id', auth, async (req, res) => {
  try {
    const [updated] = await Category.update(req.body, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ message: 'Category not found' });
    const category = await Category.findByPk(req.params.id);
    res.json(category);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete category
router.delete('/:id', auth, async (req, res) => {
  try {
    const deleted = await Category.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ message: 'Category not found' });
    res.json({ message: 'Category deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
