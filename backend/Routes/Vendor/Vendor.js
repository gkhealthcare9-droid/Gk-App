const express = require('express');
const Vendor = require('../../Models/Vendor/Vendor');
const router = express.Router();
const userAuth = require('../../Middleware/auth');
const multer = require('multer');
const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, 'vendors_' + Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });
const generateUniqueNumber = () => `GK${Math.floor(100 + Math.random() * 900)}`;

// Add Vendor
router.post('/add', userAuth, async (req, res) => {
  try {
    let { vendorName, vendorPhone, vendorEmail, vendorGSTIN, vendorCompany, addressOne, addressTwo, city, state, pincode } = req.body;

    let uniqueNumber;
    let exists = true;
    while (exists) {
      uniqueNumber = generateUniqueNumber();
      const found = await Vendor.findOne({ where: { vendorQuniqueNumber: uniqueNumber } });
      if (!found) exists = false;
    }

    const newVendor = await Vendor.create({
      vendorName, vendorPhone, vendorEmail, vendorGSTIN, vendorCompany, addressOne, addressTwo, city, state, pincode,
      vendorQuniqueNumber: uniqueNumber
    });

    res.status(201).json(newVendor);
  } catch (err) {
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
});

// Get All
router.get('/', userAuth, async (req, res) => {
  try {
    const vendors = await Vendor.findAll({ order: [['vendorName', 'ASC']] });
    res.json(vendors);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching vendors', error: err.message });
  }
});

// Update Vendor
router.put('/:id', userAuth, async (req, res) => {
  try {
    const [updated] = await Vendor.update(req.body, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ message: 'Vendor not found' });
    const vendor = await Vendor.findByPk(req.params.id);
    res.json(vendor);
  } catch (err) {
    res.status(500).json({ message: 'Error updating vendor', error: err.message });
  }
});

// Delete Vendor
router.delete('/:id', userAuth, async (req, res) => {
  try {
    const deleted = await Vendor.destroy({ where: { id: req.params.id } });
    if (deleted === 0) return res.status(404).json({ message: 'Vendor not found' });
    res.json({ message: 'Vendor deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting vendor', error: err.message });
  }
});

module.exports = router;
