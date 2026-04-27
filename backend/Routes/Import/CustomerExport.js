const express = require('express');
const router = express.Router();
const xlsx = require('xlsx');
const auth = require('../../Middleware/auth');
const Customer = require('../../Models/Customer/Customer');
const CustomerOutstanding = require('../../Models/Outstanding/CustomerOutstanding');

router.get('/customers', auth, async (req, res) => {
  try {
    console.log('--- Customer Export Started ---');
    
    // Fetch all customers
    const customers = await Customer.findAll({ order: [['customerName', 'ASC']] });
    
    // Fetch all outstandings to map them
    const outstandings = await CustomerOutstanding.findAll();
    const outstandingMap = {};
    outstandings.forEach(o => {
      outstandingMap[o.customerId] = o.currentDue;
    });

    // Prepare data for Excel
    const data = customers.map(c => ({
      'Unique ID': c.customerQuniqueNumber,
      'Customer Name': c.customerName,
      'Company': c.customerCompany || 'N/A',
      'Phone 1': c.customerPhone || 'N/A',
      'Phone 2': c.customerPhone2 || 'N/A',
      'Email': c.customerEmail || 'N/A',
      'GSTIN': c.customerGSTIN || 'N/A',
      'Address 1': c.addressOne || 'N/A',
      'Address 2': c.addressTwo || 'N/A',
      'City': c.city || 'N/A',
      'State': c.state || 'N/A',
      'Pincode': c.pincode || 'N/A',
      'Current Outstanding': outstandingMap[c.id] || 0
    }));

    // Generate Sheet
    const ws = xlsx.utils.json_to_sheet(data);
    const wb = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(wb, ws, 'Customers');

    // Write to buffer
    const buf = xlsx.write(wb, { type: 'buffer', bookType: 'xlsx' });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=customers_export_' + Date.now() + '.xlsx');
    res.send(buf);

    console.log('--- Customer Export Finished ---');
  } catch (err) {
    console.error('Export Error:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
