const { sequelize } = require('../config/database');

const User = require('../Models/User/User');
const Customer = require('../Models/Customer/Customer');
const ProductCategory = require('../Models/Product/ProductCategory');
const EmployeeCategory = require('../Models/Employees/EmployeeCategory');

const CustomerOutstanding = require('../Models/Outstanding/CustomerOutstanding');
const CustomerProduct = require('../Models/CustomerProduct/CustomerProduct');
const Employees = require('../Models/Employees/Employees');
const ExpensesCategory = require('../Models/Expenses/ExpensesCategory');
const Transaction = require('../Models/Expenses/Transaction');
const Followup = require('../Models/Leads/Followup');
const InstallationReport = require('../Models/Reports/InstallationReport');
const Lead = require('../Models/Leads/Lead');
const Payment = require('../Models/Outstanding/Payment');
const ProductManufacturer = require('../Models/Product/ProductManufacturer');
const Product = require('../Models/Product/Product');
const VendorEmployeeCategory = require('../Models/VendorEmployee/VendoremployeeCategory');
const VendorEmployee = require('../Models/VendorEmployee/Vendoremployee');
const Vendor = require('../Models/Vendor/Vendor');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('Database connected');

    const users = await User.findAll({ limit: 5 });
    const customers = await Customer.findAll({ limit: 50 });
    const productCategory = await ProductCategory.findOne() || await ProductCategory.create({ category: 'Default Prod Cat', gst: 18, image: '' });
    const employeeCategory = await EmployeeCategory.findOne() || await EmployeeCategory.create({ category: 'Default Emp Cat' });

    if (users.length === 0 || customers.length === 0) {
      throw new Error('Please ensure there is at least one User and one Customer in the DB.');
    }

    const prodCatId = productCategory.id;
    const empCatId = employeeCategory.id;

    // Helper to get random item
    const rand = (arr) => arr[Math.floor(Math.random() * arr.length)];

    console.log('--- Starting Multi-record Seeding (10 records each) ---');

    // 1. Expenses & Transactions
    const expCats = ['Travel', 'Hardware', 'Software', 'Office Supplies', 'Marketing'];
    for (const catName of expCats) {
        const [cat] = await ExpensesCategory.findOrCreate({ where: { expensesCategory: catName } });
        for (let i = 0; i < 2; i++) {
            await Transaction.create({
                userId: rand(users).id,
                amount: Math.floor(Math.random() * 5000) + 100,
                categoryId: cat.id,
                type: Math.random() > 0.5 ? 'credit' : 'debit',
                description: `Sample transaction for ${catName} #${i + 1}`
            }).catch(() => {});
        }
    }
    console.log('Seeded Expenses & Transactions');

    // 2. Manufacturers & Products
    const mfgs = ['Acme Corp', 'Global Tech', 'Health Systems', 'Precision Bio', 'MedTech Solutions'];
    for (const mfgName of mfgs) {
        const [mfg] = await ProductManufacturer.findOrCreate({ where: { manufacturer: mfgName } });
        for (let i = 0; i < 2; i++) {
            const pId = Math.floor(Math.random() * 9000) + 1000;
            await Product.findOrCreate({
                where: { productId: pId },
                defaults: {
                    productCategoryId: prodCatId,
                    productName: `${mfgName} Device ${String.fromCharCode(65 + i)}`,
                    productId: pId,
                    rate: Math.floor(Math.random() * 50000) + 5000
                }
            });
        }
    }
    console.log('Seeded Manufacturers & Products');

    // 3. Customer Products & Installation Reports
    const allMfgs = await ProductManufacturer.findAll();
    for (let i = 0; i < 10; i++) {
        const targetCust = rand(customers);
        const targetMfg = rand(allMfgs);
        const slNum = 'SN-' + Date.now() + '-' + i;
        
        await CustomerProduct.create({
            customerId: targetCust.id,
            productCategoryId: prodCatId,
            manufacturerId: targetMfg.id,
            slNumber: slNum,
            soldDate: new Date()
        });

        // Seed an employee for reports
        const emp = await Employees.create({
            name: `Staff Member ${i + 1} at ${targetCust.customerName || 'Hospital'}`,
            phone: '99' + Math.floor(Math.random() * 89999999 + 10000000),
            positionId: empCatId,
            customerId: targetCust.id
        });

        await InstallationReport.create({
            reportNumber: Math.floor(Math.random() * 899999 + 100000),
            customerId: targetCust.id,
            productCategoryId: prodCatId,
            manufacturerId: targetMfg.id,
            slNumber: slNum,
            soldDate: new Date(),
            engineerId: rand(users).id,
            clientNameId: emp.id,
            signedById: emp.id,
            status: 'working',
            actionTaken: 'Installation and testing completed.'
        });
    }
    console.log('Seeded Customer Products, Employees, and Installation Reports');

    // 4. Outstandings & Payments
    for (let i = 0; i < 10; i++) {
        const targetCust = rand(customers);
        
        // Try creating outstanding (unique per customer)
        await CustomerOutstanding.create({
            customerId: targetCust.id,
            initialDue: 10000,
            currentDue: 10000
        }).catch(() => {}); // Skip if exists

        // Multiple payments
        await Payment.create({
            customerId: targetCust.id,
            amount: 2000,
            type: 'credit',
            invoiceNumber: 'INV-' + Date.now() + '-' + i,
            description: 'Payment part ' + (i + 1)
        });
    }
    console.log('Seeded Outstandings & Payments');

    // 5. Leads & Followups
    for (let i = 0; i < 10; i++) {
        const lead = await Lead.create({
            name: `Lead Prospect ${i + 1}`,
            phone: '88' + Math.floor(Math.random() * 89999999 + 10000000),
            company: 'Prospective Hospital ' + (i + 1),
            status: 'New'
        });

        await Followup.create({
            leadId: lead.id,
            datetime: new Date(),
            notes: 'Initial inquiry call completed.'
        });
    }
    console.log('Seeded Leads & Followups');

    // 6. Vendors & Vendor Employees
    const vendorCats = await VendorEmployeeCategory.findAll();
    const vecId = (vendorCats.length > 0 ? vendorCats[0].id : (await VendorEmployeeCategory.create({ category: 'Field Tech' })).id);

    for (let i = 0; i < 5; i++) {
        const vendor = await Vendor.create({
            vendorName: `Supply Co ${String.fromCharCode(65 + i)}`,
            vendorQuniqueNumber: 'VEND-' + Date.now() + '-' + i,
            vendorPhone: '77' + Math.floor(Math.random() * 89999999 + 10000000)
        });

        for (let j = 0; j < 2; j++) {
            await VendorEmployee.create({
                name: `Vendor Staff ${i}-${j}`,
                phone: '66' + Math.floor(Math.random() * 89999999 + 10000000),
                positionId: vecId,
                vendorId: vendor.id
            });
        }
    }
    console.log('Seeded Vendors & Vendor Employees');

    console.log('--- Bulk Seeding Complete ---');

  } catch (err) {
    console.error('Seed failed:', err.message);
  } finally {
    process.exit();
  }
}

seed();
