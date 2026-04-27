const express = require('express');
const router = express.Router();
const auth = require('../../Middleware/auth');
const Customer = require('../../Models/Customer/Customer');
const Vendor = require('../../Models/Vendor/Vendor');
const Employees = require('../../Models/Employees/Employees');
const Product = require('../../Models/Product/Product');
const Lead = require('../../Models/Leads/Lead');
const CustomerOutstanding = require('../../Models/Outstanding/CustomerOutstanding');
const Category = require('../../Models/Classification/Category');
const State = require('../../Models/Location/State');
const City = require('../../Models/Location/City');

const { Op } = require('sequelize');
const User = require('../../Models/User/User');

router.get('/dashboard', auth, async (req, res) => {
  try {
    // Strictly only the Master Admin (ID 1 or "GK Healthcare") can see all staff profiles.
    // Other admins (Level 2) should only see the 'user' records.
    const isMainAdmin = req.user.id === 1 || req.user.id === '1' || (req.user.name && req.user.name.toUpperCase() === 'GK HEALTHCARE');
    console.log(`Checking stats for User ${req.user.id} (${req.user.name}) - isMainAdmin: ${isMainAdmin}`);
    
    const [
      customerCount,
      vendorCount,
      staffCount,
      productCount,
      leadCount,
      categoryCount,
      stateCount,
      cityCount,
      totalOutstanding
    ] = await Promise.all([
      Customer.count(),
      Vendor.count(),
      User.count({ where: { userType: 'user' } }),
      Product.count(),
      Lead.count(),
      Category.count(),
      State.count(),
      City.count(),
      CustomerOutstanding.sum('currentDue')
    ]);

    res.json({
      customers: customerCount,
      vendors: vendorCount,
      employees: staffCount, // Kept key as 'employees' to avoid breaking frontend logic immediately, but it now counts Users (Staff)
      staff: staffCount,
      products: productCount,
      leads: leadCount,
      categories: categoryCount,
      states: stateCount,
      cities: cityCount,
      totalOutstanding: totalOutstanding || 0
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
