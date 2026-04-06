const express = require('express');
const router = express.Router();
const FollowUp = require('../../Models/Leads/Followup');
const auth = require('../../Middleware/auth');
const { Op } = require('sequelize');

// Add FollowUp
router.post('/add', auth, async (req, res) => {
  try {
    const followupData = {
      ...req.body,
      leadId: req.body.lead
    };
    const followup = await FollowUp.create(followupData);
    res.json(followup);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get FollowUps by Lead ID
router.get('/lead/:leadId', auth, async (req, res) => {
  try {
    const followups = await FollowUp.findAll({
      where: { leadId: req.params.leadId },
      order: [['datetime', 'DESC']]
    });
    res.json(followups);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Today's FollowUps
router.get('/today', auth, async (req, res) => {
  try {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date();
    end.setHours(23, 59, 59, 999);

    const followups = await FollowUp.findAll({
      where: {
        datetime: { [Op.between]: [start, end] }
      },
      order: [['datetime', 'DESC']]
    });
    res.json(followups);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update FollowUp
router.put('/:id', auth, async (req, res) => {
  try {
    const [updated] = await FollowUp.update(req.body, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ error: 'FollowUp not found' });
    const followup = await FollowUp.findByPk(req.params.id);
    res.json(followup);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete FollowUp
router.delete('/:id', auth, async (req, res) => {
  try {
    const deleted = await FollowUp.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ error: 'FollowUp not found' });
    res.json({ message: 'FollowUp deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;