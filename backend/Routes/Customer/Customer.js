const express = require('express');
const Customer = require('../../Models/Customer/Customer');
const router = express.Router();
const userAuth = require('../../Middleware/auth');
const multer = require('multer');
const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');
const { Op } = require('sequelize');

const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, 'customers_' + Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

const generateUniqueNumber = () => {
  const prefix = 'GK-';
  const random = Math.floor(1000 + Math.random() * 9000); // Ensures 4 digits
  return `${prefix}${random}`;
};

const generateUniqueCustomerNumber = async (maxRetries = 10) => {
  let attempts = 0;
  while (attempts < maxRetries) {
    const uniqueNumber = generateUniqueNumber();
    const exists = await Customer.findOne({ where: { customerQuniqueNumber: uniqueNumber } });
    if (!exists) return uniqueNumber;
    attempts++;
  }
  throw new Error('Failed to generate unique customer number after max retries');
};

const normalizeField = (value) => {
  return value && value.trim() !== '' ? value : null;
};

// ========== Add New Customer ==========
router.post('/add', userAuth, async (req, res) => {
  try {
    const {
      customerName, customerPhone, customerPhone2, customerEmail, customerGSTIN, customerCompany,
      addressOne, addressTwo, city, state, pincode
    } = req.body;

    const uniqueNumber = await generateUniqueCustomerNumber();

    const data = {
      customerName,
      customerPhone: normalizeField(customerPhone),
      customerPhone2: normalizeField(customerPhone2),
      customerEmail: normalizeField(customerEmail),
      customerGSTIN: normalizeField(customerGSTIN),
      customerCompany: normalizeField(customerCompany),
      customerQuniqueNumber: uniqueNumber,
      addressOne,
      addressTwo,
      city,
      state,
      pincode,
    };

    const newCustomer = await Customer.create(data);
    res.status(201).json(newCustomer);
  } catch (err) {
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
});

// Get all customers
router.get('/', userAuth, async (req, res) => {
  try {
    const customers = await Customer.findAll({ order: [['customerName', 'ASC']] });
    res.json(customers);
  } catch (err) {
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
});

// Update customer by ID
router.put('/:id', userAuth, async (req, res) => {
  try {
    const updated = await Customer.update(req.body, { where: { id: req.params.id } });
    if (updated[0] === 0) return res.status(404).json({ message: 'Customer not found' });
    const customer = await Customer.findByPk(req.params.id);
    res.json(customer);
  } catch (err) {
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
});

// Delete customer by ID
router.delete('/:id', userAuth, async (req, res) => {
  try {
    const deleted = await Customer.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ message: 'Customer not found' });
    res.json({ message: 'Customer deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
});

router.get('/by-unique/:uniqueNumber', userAuth, async (req, res) => {
  try {
    const customer = await Customer.findOne({ where: { customerQuniqueNumber: req.params.uniqueNumber } });
    if (!customer) return res.status(404).json({ message: 'Customer not found' });
    res.json(customer);
  } catch (err) {
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
});


module.exports = router;
