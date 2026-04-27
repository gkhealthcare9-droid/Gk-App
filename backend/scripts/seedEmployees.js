const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const { sequelize } = require('../config/database');
const Employees = require('../Models/Employees/Employees');
const EmployeeCategory = require('../Models/Employees/EmployeeCategory');
const Customer = require('../Models/Customer/Customer');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('Connected to Database.');

    // 1. Ensure Categories Exist
    let categories = await EmployeeCategory.findAll();
    if (categories.length === 0) {
      console.log('No categories found. Creating defaults...');
      categories = await EmployeeCategory.bulkCreate([
        { category: 'Technician' },
        { category: 'Sales Executive' },
        { category: 'Maintenance' },
        { category: 'Manager' },
        { category: 'Nurse' }
      ]);
    }

    // 2. Get Customers
    const customers = await Customer.findAll({ limit: 5 });
    if (customers.length === 0) {
      console.log('No customers found. Please seed customers first.');
      process.exit(1);
    }

    // 3. Dummy Employees Data
    const dummyEmployees = [
      { name: 'Dr. Ramesh Babu', phone: '9876543210' },
      { name: 'Suresh Raina', phone: '9876543211' },
      { name: 'Anita Kumari', phone: '9876543212' },
      { name: 'Vimal Shah', phone: '9876543213' },
      { name: 'Priya Dharshini', phone: '9876543214' },
      { name: 'Karthik Rao', phone: '9876543215' },
      { name: 'Deepa Lakshmi', phone: '9876543216' },
      { name: 'Arun Kumar', phone: '9876543217' },
      { name: 'Sunita Mehra', phone: '9876543218' },
      { name: 'Rohan Sharma', phone: '9876543219' }
    ];

    console.log('Seeding 10 employees...');
    for (let i = 0; i < dummyEmployees.length; i++) {
      const customer = customers[i % customers.length];
      const category = categories[i % categories.length];

      await Employees.create({
        name: dummyEmployees[i].name,
        phone: dummyEmployees[i].phone,
        dob: new Date(1980 + i, i, i + 1), // Realistic-looking DOB
        positionId: category.id,
        customerId: customer.id
      });
    }

    console.log('Successfully seeded 10 dummy employees!');
  } catch (error) {
    console.error('Seeding failed:', error);
  } finally {
    await sequelize.close();
    process.exit(0);
  }
}

seed();
