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
    const errors = [];

    const generateSafeUniqueNumber = async () => {
      const prefix = 'GK-';
      let uniqueNumber;
      let exists = true;
      let attempts = 0;
      
      while (exists && attempts < 20) {
        uniqueNumber = `${prefix}${Math.floor(1000 + Math.random() * 9000)}`;
        const found = await Customer.findOne({ where: { customerQuniqueNumber: uniqueNumber } });
        if (!found) exists = false;
        attempts++;
      }
      return uniqueNumber;
    };

    for (let i = 0; i < data.length; i++) {
      const row = data[i];
      try {
        // Create a case-insensitive key lookup helper
        const getVal = (patterns) => {
          const keys = Object.keys(row);
          for (const pattern of patterns) {
            const match = keys.find(k => k.toLowerCase().replace(/[\s\-_]/g, '') === pattern.toLowerCase().replace(/[\s\-_]/g, ''));
            if (match) return String(row[match]).trim();
          }
          return null;
        };

        const customerName = getVal(['Customer Name', 'Name', 'Customer', 'Hospital', 'Hospital Name']);
        if (!customerName) {
          console.warn(`Skipping row ${i + 1} - missing Customer Name`);
          errors.push({ row: i + 1, error: 'Missing Customer Name' });
          continue;
        }

        console.log(`Processing row ${i + 1}: ${customerName}`);

        const customerPhone = getVal(['Customer Phone', 'Phone', 'Mobile', 'Phone 1', 'customerPhone', 'Contact']);
        let uniqueId = getVal(['Unique ID', 'Customer ID', 'customerQuniqueNumber', 'ID', 'Serial No', 'S.No']);

        // Check for existing customer ONLY by Unique ID to allow duplicate names
        let existingCustomer = null;
        if (uniqueId) {
          existingCustomer = await Customer.findOne({ where: { customerQuniqueNumber: uniqueId } });
        }

        let customer, created;
        if (existingCustomer) {
          customer = existingCustomer;
          created = false;
        } else {
          // If no unique ID found (or provided), generate a new one and create a new record
          if (!uniqueId) uniqueId = await generateSafeUniqueNumber();
          customer = await Customer.create({
            customerName,
            customerPhone,
            customerPhone2: getVal(['Phone 2', 'Secondary Phone', 'customerPhone2']),
            customerEmail: getVal(['Customer Email', 'Email', 'customerEmail']),
            customerGSTIN: getVal(['GSTIN', 'GST Number', 'customerGSTIN', 'GST']),
            customerCompany: getVal(['Customer Company', 'Company', 'customerCompany', 'Institution']),
            addressOne: getVal(['Address 1', 'Address One', 'customerAddress1', 'addressOne', 'Address']),
            addressTwo: getVal(['Address 2', 'Address Two', 'customerAddress2', 'addressTwo']),
            city: getVal(['City', 'customerCity', 'Location']),
            state: getVal(['State', 'customerState', 'Province']),
            pincode: getVal(['Pincode', 'Zip Code', 'customerPincode', 'Zip']),
            customerQuniqueNumber: uniqueId
          });
          created = true;
        }

        console.log(created ? 'Created new customer' : 'Found existing customer (merging)');

        // Update if existing to ensure all data is synced
        if (!created) {
          await customer.update({
            customerPhone: customerPhone || customer.customerPhone,
            customerPhone2: getVal(['Phone 2', 'Secondary Phone', 'customerPhone2']) || customer.customerPhone2,
            customerEmail: getVal(['Customer Email', 'Email', 'customerEmail']) || customer.customerEmail,
            customerGSTIN: getVal(['GSTIN', 'GST Number', 'customerGSTIN', 'GST']) || customer.customerGSTIN,
            customerCompany: getVal(['Customer Company', 'Company', 'customerCompany', 'Institution']) || customer.customerCompany,
            addressOne: getVal(['Address 1', 'Address One', 'customerAddress1', 'addressOne', 'Address']) || customer.addressOne,
            addressTwo: getVal(['Address 2', 'Address Two', 'customerAddress2', 'addressTwo']) || customer.addressTwo,
            city: getVal(['City', 'customerCity', 'Location']) || customer.city,
            state: getVal(['State', 'customerState', 'Province']) || customer.state,
            pincode: getVal(['Pincode', 'Zip Code', 'customerPincode', 'Zip']) || customer.pincode,
          });
        }

        // Handle Outstanding
        const oAmount = getVal(['Total Outstanding', 'Outstanding', 'Balance', 'Initial Due', 'Due']);
        const outstandingAmount = Number(oAmount) || 0;
        if (outstandingAmount > 0) {
          const [out, outCreated] = await CustomerOutstanding.findOrCreate({
            where: { customerId: customer.id },
            defaults: {
              initialDue: outstandingAmount,
              currentDue: outstandingAmount
            }
          });
          if (!outCreated) {
            await out.update({ currentDue: outstandingAmount });
          }
        }

        // Create Task/Follow-up (Optional if columns exist)
        const purpose = getVal(['Purpose of Visit', 'Purpose', 'Task Category', 'Category']);
        const statusValue = getVal(['Status', 'Task Status']);

        if (purpose || statusValue) {
          await Task.create({
            taskNumber: Math.floor(100000 + Math.random() * 900000),
            taskCategory: purpose || 'Follow-up',
            taskName: `Excel Import: ${customerName}`,
            taskDescription: `
Pymt flw up by: ${getVal(['Pymt flw up by', 'Follow up by', 'Staff']) || 'N/A'}
MOP: ${getVal(['MOP', 'Payment Method']) || 'N/A'}
Supply: ${getVal(['Supply']) || 'N/A'}
Remarks: ${getVal(['Remarks', 'Notes']) || 'N/A'}
Distributor: ${getVal(['Distributor']) || 'N/A'}
            `.trim(),
            taskStatus: statusValue === 'Completed' ? 'Completed' : 'Pending',
            assignedToId: req.user.id,
            dueDate: new Date(),
            priority: getVal(['Priority']) === 'High' ? 'High' : 'Medium'
          });
        }
        importedCount++;
      } catch (rowError) {
        console.error(`Error on row ${i + 1}:`, rowError);
        errors.push({ row: i + 1, error: rowError.message });
      }
    }

    fs.unlinkSync(filePath);
    console.log('Import finished. Count:', importedCount, 'Errors:', errors.length);
    res.json({ 
      message: `Successfully imported ${importedCount} records`, 
      count: importedCount, 
      errors: errors.length > 0 ? errors : undefined 
    });
  } catch (err) {
    console.error('Core Import Error:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
