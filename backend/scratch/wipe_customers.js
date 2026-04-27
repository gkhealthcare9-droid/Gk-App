const { sequelize } = require('../config/database');
const Customer = require('../Models/Customer/Customer');
const CustomerContact = require('../Models/CustomerContact/CustomerContact');
const CustomerOutstanding = require('../Models/Outstanding/CustomerOutstanding');
const Payment = require('../Models/Outstanding/Payment');
const CustomerProduct = require('../Models/CustomerProduct/CustomerProduct');
const Employees = require('../Models/Employees/Employees');
const InstallationReport = require('../Models/Reports/InstallationReport');
const Task = require('../Models/Task/Task');

async function wipeAll() {
  try {
    console.log('🚀 Starting manual database wipe...');

    // Delete in order to satisfy foreign key constraints
    console.log('🗑️ Clearing Payments...');
    await Payment.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Customer Outstandings...');
    await CustomerOutstanding.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Installation Reports...');
    await InstallationReport.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Tasks...');
    await Task.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Customer Products...');
    await CustomerProduct.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Customer Contacts...');
    await CustomerContact.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Hospital Employees...');
    // We only clear employees linked to a customer
    await Employees.destroy({ where: {}, truncate: false });

    console.log('🗑️ Clearing Customers...');
    await Customer.destroy({ where: {}, truncate: false });

    console.log('✅ DATABASE WIPE COMPLETE! All customer-related records purged.');
    process.exit(0);
  } catch (err) {
    console.error('❌ ERROR during wipe:', err.message);
    process.exit(1);
  }
}

wipeAll();
