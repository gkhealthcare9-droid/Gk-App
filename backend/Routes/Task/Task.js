const express = require('express');
const router = express.Router();
const Task = require('../../Models/Task/Task');
const auth = require('../../Middleware/auth');
const { Op } = require('sequelize');

// Create Task
router.post('/create', auth, async (req, res) => {
  try {
    // In MySQL, we can use id if taskNumber is the same as ID, or manage it ourselves.
    // For consistency with existing app, let's find the max taskNumber and increment.
    const maxTask = await Task.max('taskNumber') || 100;
    
    const taskData = {
      ...req.body,
      taskNumber: maxTask + 1,
      assignedToId: req.body.assignedTo // Adjust field mapping
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
    const task = await Task.findByPk(req.params.id);
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
      }
    });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all tasks with assigned user info
router.get('/all', auth, async (req, res) => {
  try {
    // In Sequelize, used include for populate behavior
    // Note: Associations need to be defined in models or a central store for include to work
    const tasks = await Task.findAll(); 
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
      }
    });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
