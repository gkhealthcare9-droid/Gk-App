const { sequelize } = require('../config/database');

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
const Category = require('../Models/Classification/Category');
const VendorEmployeeCategory = require('../Models/VendorEmployee/VendoremployeeCategory');
const VendorEmployee = require('../Models/VendorEmployee/Vendoremployee');
const Vendor = require('../Models/Vendor/Vendor');

const models = [
  CustomerOutstanding, CustomerProduct, Employees, ExpensesCategory, Transaction,
  Followup, InstallationReport, Lead, Payment, ProductManufacturer, Product,
  VendorEmployeeCategory, VendorEmployee, Vendor
];

async function printSchema() {
  for (const M of models) {
    if(!M) continue;
    console.log(`\n--- ${M.name} ---`);
    const attrs = M.getAttributes();
    for (const key of Object.keys(attrs)) {
      console.log(`${key}: ${attrs[key].type.constructor.name}${attrs[key].allowNull === false ? ' (Required)' : ''}`);
    }
  }
  process.exit(0);
}
printSchema();
