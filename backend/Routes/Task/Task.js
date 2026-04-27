const express = require('express');
const router = express.Router();
const Task = require('../../Models/Task/Task');
const User = require('../../Models/User/User');
const Customer = require('../../Models/Customer/Customer');
const auth = require('../../Middleware/auth');
const { Op } = require('sequelize');

// Create Task
router.post('/create', auth, async (req, res) => {
  try {
    const maxTask = await Task.max('taskNumber') || 100;
    
    const taskData = {
      ...req.body,
      taskNumber: maxTask + 1,
      assignedToId: req.body.assignedTo,
      customerId: req.body.customerId
    };

    const task = await Task.create(taskData);
    res.json(task);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Task
router.put('/update/:id', auth, async (req, res) => {
  try {
    const updated = await Task.update(
      { ...req.body, updatedAt: new Date() },
      { where: { id: req.params.id } }
    );
    if (updated[0] === 0) return res.status(404).json({ message: 'Task not found' });
    const task = await Task.findByPk(req.params.id, {
      include: [
        { model: User, as: 'assignedTo', attributes: ['id', 'name', 'email'] },
        { model: Customer }
      ]
    });
    res.json(task);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all tasks assigned to logged in user
router.get('/my-tasks', auth, async (req, res) => {
  try {
    const tasks = await Task.findAll({
      where: {
        assignedToId: req.user.id,
        taskStatus: { [Op.in]: ['Pending', 'In-Progress'] }
      },
      include: [
        { model: User, as: 'assignedTo', attributes: ['id', 'name', 'email'] },
        { model: Customer }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all tasks with assigned user info
router.get('/all', auth, async (req, res) => {
  try {
    const tasks = await Task.findAll({
      include: [
        { model: User, as: 'assignedTo', attributes: ['id', 'name', 'email'] },
        { model: Customer }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get tasks by status
router.get('/status/:status', auth, async (req, res) => {
  try {
    const tasks = await Task.findAll({
      where: {
        assignedToId: req.user.id,
        taskStatus: req.params.status
      },
      include: [
        { model: User, as: 'assignedTo', attributes: ['id', 'name', 'email'] },
        { model: Customer }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete Task
router.delete('/:id', auth, async (req, res) => {
  try {
    // Only admins can delete tasks
    if (req.user.userType !== 'admin') {
      return res.status(403).json({ message: 'Only administrators can delete tasks' });
    }

    const task = await Task.findByPk(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    await task.destroy();
    res.json({ message: 'Task deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
