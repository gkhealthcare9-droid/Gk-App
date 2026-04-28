require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { connectDB } = require('./config/database');

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3007;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('uploads'));

const UserRoute = require('./Routes/User/User');
const TaskRoute = require('./Routes/Task/Task');
const CustomerOutstandingRoute = require('./Routes/Outstandig/Outstanding');
const LeadRoute = require('./Routes/Lead/Lead');
const LeadFollowup = require('./Routes/Lead/Followup');

const CustomerRoute = require('./Routes/Customer/Customer');
const VendorRoute = require('./Routes/Vendor/Vendor');
const CustomerContactsRoute = require('./Routes/Customer/CustomerContacts');
const ExpensesRoute = require('./Routes/Expenses/Expenses');
const ProductRoute = require('./Routes/Product/Product');
const VendorEmployeesRoute = require('./Routes/Vendor/VendorEmployee');
const EmployeeRoute = require('./Routes/Customer/Employees');
const InstallationReportRoute = require('./Routes/Reports/InstallationReport');
const CustomerProductRoute = require('./Routes/CustomerProduct/CustomerProduct');
const StatsRoute = require('./Routes/Dashboard/Stats');
const ImportRoute = require('./Routes/Import/ExcelImport');
const ExportRoute = require('./Routes/Import/CustomerExport');
const CategoryRoute = require('./Routes/Classification/Category');
const LocationRoute = require('./Routes/Location/Location');
const SeedRoute = require('./Routes/Utility/SeedData');

app.use('/api/v1/user', UserRoute);
app.use('/api/v1/customer', CustomerRoute);
app.use('/api/v1/customer/product', CustomerProductRoute);
app.use('/api/v1/vendor', VendorRoute);
app.use('/api/v1/expenses', ExpensesRoute);
app.use('/api/v1/customer-contact', CustomerContactsRoute);
app.use('/api/v1/product', ProductRoute);
app.use('/api/v1/vendor-employee', VendorEmployeesRoute);
app.use('/api/v1/customer/employee', EmployeeRoute);
app.use('/api/v1/task', TaskRoute);
app.use('/api/v1/customer/payment', CustomerOutstandingRoute);
app.use('/api/v1/lead', LeadRoute);
app.use('/api/v1/lead/followup', LeadFollowup);
app.use('/api/v1/installation-report', InstallationReportRoute);
app.use('/api/v1/stats', StatsRoute);
app.use('/api/v1/import', ImportRoute);
app.use('/api/v1/export', ExportRoute);
app.use('/api/v1/category', CategoryRoute);
app.use('/api/v1/location', LocationRoute);
app.use('/api/v1/seed', SeedRoute);

app.get('/', (req, res) => {
  res.send('Welcome to the server!');
});

app.get('/api', (req, res) => {
  res.json({ message: 'Hello from the API!' });
});

connectDB();

server.listen(PORT, () => {
  console.log(`🔥 Server is running on port ${PORT} 🛠️`);
});