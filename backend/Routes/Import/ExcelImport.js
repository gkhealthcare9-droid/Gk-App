const express = require('express');
const router = express.Router();
const multer = require('multer');
const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');
const auth = require('../../Middleware/auth');
const Customer = require('../../Models/Customer/Customer');
const CustomerOutstanding = require('../../Models/Outstanding/CustomerOutstanding');
const Task = require('../../Models/Task/Task');

const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, 'import_' + Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

router.post('/excel', auth, upload.single('file'), async (req, res) => {
  try {
    console.log('--- Excel Import Started ---');
    if (!req.file) {
      console.error('No file received');
      return res.status(400).json({ message: 'No file uploaded' });
    }

    console.log('File received:', req.file.originalname, 'at', req.file.path);

    const filePath = req.file.path;
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

    console.log('Parsed data rows:', data.length);
    if (data.length > 0) {
      console.log('First row headers:', Object.keys(data[0]));
    }

    let importedCount = 0;

    for (const row of data) {
      // Create a case-insensitive key lookup helper
      const getVal = (patterns) => {
        const keys = Object.keys(row);
        for (const pattern of patterns) {
          const match = keys.find(k => k.toLowerCase().trim() === pattern.toLowerCase());
          if (match) return row[match];
        }
        return null;
      };

      const customerName = getVal(['Customer Name', 'Name', 'Customer']);
      if (!customerName) {
        console.warn('Skipping row - missing Customer Name');
        continue;
      }

      console.log('Processing customer:', customerName);

      // Upsert Customer
      let [customer, created] = await Customer.findOrCreate({
        where: { customerName },
        defaults: {
          addressOne: getVal(['Customer / Buyer Address', 'Address', 'Address 1']),
          city: getVal(['City']),
          state: getVal(['State', 'Province']),
          customerQuniqueNumber: 'GK' + Date.now().toString().slice(-6) + Math.floor(100+Math.random()*900)
        }
      });

      console.log(created ? 'Created new customer' : 'Found existing customer');

      // Handle Outstanding
      const oAmount = getVal(['Total Outstanding', 'Outstanding', 'Balance']);
      const outstandingAmount = Number(oAmount) || 0;
      if (outstandingAmount > 0) {
        console.log('Adding outstanding:', outstandingAmount);
        await CustomerOutstanding.findOrCreate({
          where: { customerId: customer.id },
          defaults: {
            initialDue: outstandingAmount,
            currentDue: outstandingAmount
          }
        });
      }

      // Create Task/Follow-up
      const purpose = getVal(['Purpose of Visit', 'Purpose']);
      const statusValue = getVal(['Status']);

      if (purpose || statusValue) {
        console.log('Creating task for visit:', purpose);
        await Task.create({
          taskNumber: Math.floor(100000 + Math.random() * 900000),
          taskCategory: purpose || 'Follow-up',
          taskName: `Excel Import: ${customerName}`,
          taskDescription: `
Pymt flw up by: ${getVal(['Pymt flw up by', 'Follow up by']) || 'N/A'}
MOP: ${getVal(['MOP']) || 'N/A'}
Supply: ${getVal(['Supply']) || 'N/A'}
Remarks: ${getVal(['Remarks']) || 'N/A'}
Distributor: ${getVal(['Distributor']) || 'N/A'}
Mounesh Remarks March: ${getVal(['Mounesh Remarks March']) || 'N/A'}
Priority Task: ${getVal(['Priority Task', 'Priority']) || 'N/A'}
          `.trim(),
          taskStatus: statusValue === 'Completed' ? 'Completed' : 'Pending',
          assignedToId: req.user.id,
          dueDate: new Date(),
          priority: getVal(['Priority Task', 'Priority']) === 'High' ? 'High' : 'Medium'
        });
      }
      importedCount++;
    }

    fs.unlinkSync(filePath);
    console.log('Import successful. Count:', importedCount);
    res.json({ message: `Successfully imported ${importedCount} records`, count: importedCount });
  } catch (err) {
    console.error('Import Error:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
