-- GK Healthcare Database Schema (MySQL)

-- User Table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    dob DATE NULL,
    doj DATE NULL,
    lastLogin DATETIME NULL,
    userType ENUM('admin', 'user') DEFAULT 'user',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Product Category Table
CREATE TABLE IF NOT EXISTS product_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    productCategory VARCHAR(255) NOT NULL,
    image VARCHAR(255) DEFAULT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Product Manufacturer Table
CREATE TABLE IF NOT EXISTS product_manufacturers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    manufacturer VARCHAR(255) NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Product Table
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    productCategoryId BIGINT NOT NULL,
    productName VARCHAR(255) NOT NULL,
    productId INT NOT NULL UNIQUE,
    tax DECIMAL(5, 2) DEFAULT 0,
    HSN VARCHAR(255) NULL,
    rate DECIMAL(15, 2) NOT NULL,
    images JSON NULL, -- Store array of strings as JSON
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (productCategoryId) REFERENCES product_categories(id) ON DELETE CASCADE
);

-- Customer Table
CREATE TABLE IF NOT EXISTS customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customerName VARCHAR(255) NOT NULL,
    customerPhone VARCHAR(255) DEFAULT NULL,
    customerPhone2 VARCHAR(255) DEFAULT NULL,
    customerEmail VARCHAR(255) DEFAULT NULL,
    customerGSTIN VARCHAR(255) DEFAULT NULL,
    customerCompany VARCHAR(255) DEFAULT NULL,
    customerQuniqueNumber VARCHAR(255) NOT NULL UNIQUE,
    addressOne VARCHAR(255) NULL,
    addressTwo VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    pincode VARCHAR(255) NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Leads Table
CREATE TABLE IF NOT EXISTS leads (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NULL,
    position VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    pincode VARCHAR(255) NULL,
    categoryId BIGINT NULL,
    leadValue DECIMAL(15, 2) NULL,
    company VARCHAR(255) NULL,
    description TEXT NULL,
    status VARCHAR(50) DEFAULT 'new',
    assignedId BIGINT NULL,
    source VARCHAR(255) NULL,
    leadType ENUM('hot', 'cold', 'warm') DEFAULT 'cold',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (categoryId) REFERENCES product_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (assignedId) REFERENCES users(id) ON DELETE SET NULL
);

-- Followups Table
CREATE TABLE IF NOT EXISTS followups (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    leadId BIGINT NOT NULL,
    datetime DATETIME NOT NULL,
    notes TEXT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (leadId) REFERENCES leads(id) ON DELETE CASCADE
);

-- Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    taskNumber INT NOT NULL UNIQUE,
    taskCategory VARCHAR(255) NOT NULL,
    taskName VARCHAR(255) NOT NULL,
    taskDescription TEXT NOT NULL,
    taskStatus ENUM('Pending', 'In-Progress', 'Completed') DEFAULT 'Pending',
    assignedToId BIGINT NOT NULL,
    dueDate DATETIME NOT NULL,
    priority ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (assignedToId) REFERENCES users(id) ON DELETE CASCADE
);

-- Employee Categories Table
CREATE TABLE IF NOT EXISTS employee_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(255) NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Employees Table
CREATE TABLE IF NOT EXISTS employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    dob DATE NULL,
    positionId BIGINT NOT NULL,
    customerId BIGINT NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (positionId) REFERENCES employee_categories(id),
    FOREIGN KEY (customerId) REFERENCES customers(id) ON DELETE CASCADE
);

-- Vendors Table
CREATE TABLE IF NOT EXISTS vendors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vendorName VARCHAR(255) NOT NULL,
    vendorPhone VARCHAR(255) NULL,
    vendorEmail VARCHAR(255) NULL,
    vendorGSTIN VARCHAR(255) NULL,
    vendorCompany VARCHAR(255) NULL,
    addressOne VARCHAR(255) NULL,
    addressTwo VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    pincode VARCHAR(255) NULL,
    vendorQuniqueNumber VARCHAR(255) NOT NULL UNIQUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Vendor Employee Categories Table
CREATE TABLE IF NOT EXISTS vendor_employee_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(255) NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Vendor Employees Table
CREATE TABLE IF NOT EXISTS vendor_employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    dob DATE NULL,
    positionId BIGINT NOT NULL,
    vendorId BIGINT NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (positionId) REFERENCES vendor_employee_categories(id),
    FOREIGN KEY (vendorId) REFERENCES vendors(id) ON DELETE CASCADE
);

-- Expenses Categories Table
CREATE TABLE IF NOT EXISTS expenses_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    expensesCategory VARCHAR(255) NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    userId BIGINT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    categoryId BIGINT NULL,
    type ENUM('credit', 'debit') NOT NULL,
    bill VARCHAR(255) DEFAULT NULL,
    description TEXT NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (categoryId) REFERENCES expenses_categories(id)
);

-- Wallets (Expenses) Table
CREATE TABLE IF NOT EXISTS wallets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    userId BIGINT NOT NULL UNIQUE,
    balance DECIMAL(15, 2) DEFAULT 0,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
);

-- Payments Table (Customer Outstanding)
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customerId BIGINT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    type ENUM('credit', 'debit') NOT NULL,
    invoiceNumber VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (customerId) REFERENCES customers(id) ON DELETE CASCADE
);

-- Outstanding Table
CREATE TABLE IF NOT EXISTS customer_outstandings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    initialDue DECIMAL(15, 2) DEFAULT 0,
    currentDue DECIMAL(15, 2) DEFAULT 0,
    customerId BIGINT NOT NULL UNIQUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (customerId) REFERENCES customers(id) ON DELETE CASCADE
);

-- Customer Product Table
CREATE TABLE IF NOT EXISTS customer_products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customerId BIGINT NOT NULL,
    productCategoryId BIGINT NOT NULL,
    manufacturerId BIGINT NOT NULL,
    slNumber VARCHAR(255) NOT NULL,
    soldDate DATE NOT NULL,
    warranty DATE NULL,
    amcStart DATE NULL,
    amcEnd DATE NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (customerId) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (productCategoryId) REFERENCES product_categories(id),
    FOREIGN KEY (manufacturerId) REFERENCES product_manufacturers(id)
);

-- Installation Report Table
CREATE TABLE IF NOT EXISTS installation_reports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reportNumber INT NOT NULL UNIQUE,
    customerId BIGINT NOT NULL,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    productCategoryId BIGINT NOT NULL,
    manufacturerId BIGINT NOT NULL,
    slNumber VARCHAR(255) NOT NULL,
    soldDate DATE NOT NULL,
    warranty DATE NULL,
    status VARCHAR(50) DEFAULT 'working',
    actionTaken TEXT NULL,
    noteByEngineer TEXT NULL,
    engineerId BIGINT NOT NULL,
    clientNameId BIGINT NOT NULL,
    signedById BIGINT NOT NULL,
    clientSignature VARCHAR(255) NULL,
    pdf VARCHAR(255) NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (customerId) REFERENCES customers(id),
    FOREIGN KEY (productCategoryId) REFERENCES product_categories(id),
    FOREIGN KEY (manufacturerId) REFERENCES product_manufacturers(id),
    FOREIGN KEY (engineerId) REFERENCES users(id),
    FOREIGN KEY (clientNameId) REFERENCES employees(id),
    FOREIGN KEY (signedById) REFERENCES employees(id)
);
