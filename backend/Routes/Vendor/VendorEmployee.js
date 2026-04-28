const express = require('express');
const router = express.Router();
const VendorEmployee = require('../../Models/VendorEmployee/Vendoremployee');
const VendorEmployeeCategory = require('../../Models/VendorEmployee/VendoremployeeCategory');
const userAuth = require('../../Middleware/auth');

// Create category
router.post('/category', userAuth, async (req, res) => {
  try {
    const category = await VendorEmployeeCategory.create({ category: req.body.category });
    res.status(201).json(category);
  } catch (err) {
    res.status(500).json({ message: 'Error adding category', error: err.message });
  }
});

// Get all categories
router.get('/category', userAuth, async (req, res) => {
  try {
    const categories = await VendorEmployeeCategory.findAll({ order: [['category', 'ASC']] });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching categories', error: err.message });
  }
});

// Update category
router.put('/category/:id', userAuth, async (req, res) => {
  try {
    const { category } = req.body;
    const item = await VendorEmployeeCategory.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: 'Category not found' });
    await item.update({ category });
    res.json(item);
  } catch (err) {
    res.status(500).json({ message: 'Error updating category', error: err.message });
  }
});

// Delete category
router.delete('/category/:id', userAuth, async (req, res) => {
  try {
    const item = await VendorEmployeeCategory.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: 'Category not found' });

    // Check if being used
    const count = await VendorEmployee.count({ where: { positionId: req.params.id } });
    if (count > 0) {
      return res.status(400).json({ message: 'Cannot delete category that is assigned to employees' });
    }

    await item.destroy();
    res.json({ message: 'Category deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting category', error: err.message });
  }
});

// Create vendor employee
router.post('/add', userAuth, async (req, res) => {
  try {
    const employeeData = {
      ...req.body,
      positionId: req.body.position,
      vendorId: req.body.vendor
    };
    const employee = await VendorEmployee.create(employeeData);
    res.status(201).json(employee);
  } catch (err) {
    res.status(500).json({ message: 'Error adding vendor employee', error: err.message });
  }
});

// Get all vendor employees
router.get('/', userAuth, async (req, res) => {
  try {
    const employees = await VendorEmployee.findAll({
      order: [['createdAt', 'DESC']]
    });
    res.json(employees);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching vendor employees', error: err.message });
  }
});

// Update vendor employee
router.put('/:id', userAuth, async (req, res) => {
  try {
    const [updated] = await VendorEmployee.update(req.body, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ message: 'Vendor Employee not found' });
    const employee = await VendorEmployee.findByPk(req.params.id);
    res.json(employee);
  } catch (err) {
    res.status(500).json({ message: 'Error updating vendor employee', error: err.message });
  }
});

// Delete vendor employee
router.delete('/:id', userAuth, async (req, res) => {
  try {
    const deleted = await VendorEmployee.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ message: 'Vendor Employee not found' });
    res.json({ message: 'Vendor Employee deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting vendor employee', error: err.message });
  }
});

module.exports = router;
