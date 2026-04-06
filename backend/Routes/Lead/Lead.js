const express = require('express');
const router = express.Router();
const Lead = require('../../Models/Leads/Lead');
const auth = require('../../Middleware/auth');

// Add Lead
router.post('/add', auth, async (req, res) => {
  try {
    const leadData = {
      ...req.body,
      assignedId: req.body.assigned, // map Mongoose assigned to assignedId
      categoryId: req.body.category   // map Mongoose category to categoryId
    };
    const lead = await Lead.create(leadData);
    res.json(lead);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get All Leads
router.get('/', auth, async (req, res) => {
  try {
    const leads = await Lead.findAll({
      order: [['createdAt', 'DESC']]
    });
    res.json(leads);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Lead Status
router.put('/status/:id', auth, async (req, res) => {
  try {
    const { status } = req.body;
    const [updated] = await Lead.update({ status }, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ error: 'Lead not found' });
    const lead = await Lead.findByPk(req.params.id);
    res.json(lead);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Leads by Assigned User
router.get('/assigned', auth, async (req, res) => {
  try {
    const leads = await Lead.findAll({
      where: { assignedId: req.user.id },
      order: [['createdAt', 'DESC']]
    });
    res.json(leads);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Lead
router.put('/:id', auth, async (req, res) => {
  try {
    const [updated] = await Lead.update(req.body, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ error: 'Lead not found' });
    const lead = await Lead.findByPk(req.params.id);
    res.json(lead);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete Lead
router.delete('/:id', auth, async (req, res) => {
  try {
    const deleted = await Lead.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ error: 'Lead not found' });
    res.json({ message: 'Lead deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;