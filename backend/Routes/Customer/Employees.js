const express = require('express');
const router = express.Router();
const Employee = require('../../Models/Employees/Employees');
const EmployeeCategory = require('../../Models/Employees/EmployeeCategory');
const userAuth = require('../../Middleware/auth');

// ────────────── Category Routes ──────────────
// Create category
router.post('/category', userAuth, async (req, res) => {
  try {
    const category = await EmployeeCategory.create({ category: req.body.category });
    res.status(201).json(category);
  } catch (err) {
    res.status(500).json({ message: 'Error adding category', error: err.message });
  }
});

// Get all categories
router.get('/category', userAuth, async (req, res) => {
    try {
      const categories = await EmployeeCategory.findAll({ order: [['category', 'ASC']] });
      res.json(categories);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching categories', error: err.message });
    }
  });

// Update category
router.put('/category/:id', userAuth, async (req, res) => {
  try {
    const { category } = req.body;
    const item = await EmployeeCategory.findByPk(req.params.id);
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
    const item = await EmployeeCategory.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: 'Category not found' });

    // Check if being used
    const count = await Employee.count({ where: { positionId: req.params.id } });
    if (count > 0) {
      return res.status(400).json({ message: 'Cannot delete category that is assigned to employees' });
    }

    await item.destroy();
    res.json({ message: 'Category deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting category', error: err.message });
  }
});

// ────────────── Employee Routes ──────────────
// Create employee
router.post('/add', userAuth, async (req, res) => {
  try {
    const employeeData = {
      ...req.body,
      positionId: req.body.position,
      customerId: req.body.customer
    };
    const employee = await Employee.create(employeeData);
    res.status(201).json(employee);
  } catch (err) {
    res.status(500).json({ message: 'Error adding employee', error: err.message });
  }
});

// Get all employees
router.get('/', userAuth, async (req, res) => {
  try {
    const employees = await Employee.findAll({
      order: [['createdAt', 'DESC']],
      include: [{ model: EmployeeCategory }]
    });
    res.json(employees);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching employees', error: err.message });
  }
});

// Get employees by customer
router.get('/by-customer/:id', userAuth, async (req, res) => {
  try {
    const employees = await Employee.findAll({
      where: { customerId: req.params.id },
      include: [{ model: EmployeeCategory }]
    });
    res.json(employees);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching employees by customer', error: err.message });
  }
});

// Update employee
router.put('/:id', userAuth, async (req, res) => {
  try {
    const [updated] = await Employee.update(req.body, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ message: 'Employee not found' });
    const employee = await Employee.findByPk(req.params.id);
    res.json(employee);
  } catch (err) {
    res.status(500).json({ message: 'Error updating employee', error: err.message });
  }
});

// Delete employee
router.delete('/:id', userAuth, async (req, res) => {
  try {
    const deleted = await Employee.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ message: 'Employee not found' });
    res.json({ message: 'Employee deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting employee', error: err.message });
  }
});

module.exports = router;
