const express = require('express');
const router = express.Router();
const { sequelize } = require('../../config/database');
const { Op } = require('sequelize');
const CustomerContact = require('../../Models/CustomerContact/CustomerContact');
const ContactPosition = require('../../Models/CustomerContact/ContactPosition');
const userAuth = require('../../Middleware/auth');

// ────────────── Position Routes ──────────────
// Create position
router.post('/position', userAuth, async (req, res) => {
  try {
    const position = await ContactPosition.create({ position: req.body.position });
    res.status(201).json(position);
  } catch (err) {
    res.status(500).json({ message: 'Error adding position', error: err.message });
  }
});

// Get all positions (Public so dropdowns work)
router.get('/position', async (req, res) => {
    try {
      const positions = await ContactPosition.findAll({ order: [['position', 'ASC']] });
      res.json(positions);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching positions', error: err.message });
    }
  });

// ────────────── Contact Routes ──────────────
// Create contact
router.post('/add', userAuth, async (req, res) => {
  try {
    const contactData = {
      ...req.body,
      positionId: req.body.position,
      customerId: req.body.customer
    };
    const contact = await CustomerContact.create(contactData);
    res.status(201).json(contact);
  } catch (err) {
    res.status(500).json({ message: 'Error adding contact', error: err.message });
  }
});

// Get all contacts
router.get('/', userAuth, async (req, res) => {
  try {
    const contacts = await CustomerContact.findAll({
      order: [['createdAt', 'DESC']],
      include: [{ model: ContactPosition, as: 'position' }]
    });
    res.json(contacts);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching contacts', error: err.message });
  }
});

// Get contacts by customer
router.get('/by-customer/:id', userAuth, async (req, res) => {
  try {
    const contacts = await CustomerContact.findAll({
      where: { customerId: req.params.id },
      include: [{ model: ContactPosition, as: 'position' }]
    });
    res.json(contacts);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching customer contacts', error: err.message });
  }
});

// Update contact
router.put('/:id', userAuth, async (req, res) => {
  try {
    let contactId = req.params.id;
    console.log(`📝 Attempting smart update for contact ID: ${contactId}`);
    
    // 🔍 PHASE 1: Find the record (with Fallback for ID Desync)
    let existingContact = await CustomerContact.findByPk(contactId);
    
    if (!existingContact) {
      console.log(`⚠️ ID ${contactId} not found. Attempting fallback match by Name OR Phone...`);
      // Flexible search within the same customer
      existingContact = await CustomerContact.findOne({
        where: {
          customerId: Number(req.body.customer),
          [Op.or]: [
            { name: req.body.name },
            { phone: req.body.phone }
          ]
        }
      });
      
      if (!existingContact) {
        console.log(`❌ No matching contact found even with flexible fallback.`);
        return res.status(404).json({ message: 'Contact not found' });
      }
      
      contactId = existingContact.id;
      console.log(`✅ Flexible match found! Correct ID is: ${contactId}`);
    }

    // 🚀 PHASE 2: Update using Sequelize
    console.log(`🛠️ Updating contact ${contactId} via Sequelize...`);
    
    await existingContact.update({
      name: req.body.name || existingContact.name,
      phone: req.body.phone || existingContact.phone,
      phone2: req.body.phone2 !== undefined ? req.body.phone2 : existingContact.phone2,
      email: req.body.email !== undefined ? req.body.email : existingContact.email,
      positionId: req.body.position ? Number(req.body.position) : existingContact.positionId,
      customerId: req.body.customer ? Number(req.body.customer) : existingContact.customerId,
    });
    
    // 🔄 PHASE 3: Re-fetch with associations to return fresh data
    const updatedContact = await CustomerContact.findByPk(contactId, {
      include: [{ model: ContactPosition, as: 'position' }]
    });
    
    console.log(`🏁 UPDATE COMPLETE: Name=${updatedContact?.name}, Position=${updatedContact?.position?.position}`);
    
    res.json(updatedContact);
  } catch (err) {
    console.error(`🚨 Update Error:`, err);
    res.status(500).json({ message: 'Error updating contact', error: err.message });
  }
});

// Delete contact
router.delete('/:id', userAuth, async (req, res) => {
  try {
    const deleted = await CustomerContact.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ message: 'Contact not found' });
    res.json({ message: 'Contact deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting contact', error: err.message });
  }
});

module.exports = router;
