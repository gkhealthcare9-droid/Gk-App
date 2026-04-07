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

router.get('/dashboard', auth, async (req, res) => {
  try {
    const [
      customerCount,
      vendorCount,
      employeeCount,
      productCount,
      leadCount,
      categoryCount,
      stateCount,
      cityCount,
      totalOutstanding
    ] = await Promise.all([
      Customer.count(),
      Vendor.count(),
      Employees.count(),
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
      employees: employeeCount,
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
