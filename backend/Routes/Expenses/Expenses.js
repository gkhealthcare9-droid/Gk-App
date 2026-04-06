const express = require("express");
const Wallet = require("../../Models/Expenses/Expenses");
const Transaction = require("../../Models/Expenses/Transaction");
const router = express.Router();
const authMiddleware = require("../../Middleware/auth");
const multer = require("multer");
const cloudinary = require("cloudinary").v2;
const fs = require("fs");
const ExpensesCategory = require("../../Models/Expenses/ExpensesCategory");

// Cloudinary config
cloudinary.config({
  cloud_name: 'dfmtzif75',
  api_key: '914528999856855',
  api_secret: 'QAs6_pa7vCozj6o0USKnMm8lJkM'
});

const upload = multer({ dest: 'uploads/' });

const uploadToCloudinary = async (filePath) => {
  const result = await cloudinary.uploader.upload(filePath, {
    folder: 'expenses-images',
    resource_type: 'image'
  });
  fs.unlinkSync(filePath);
  return result.secure_url;
};

// Add Funds
router.post('/add-funds', upload.single('bill'), async (req, res) => {
  try {
    let { amount, user, description } = req.body;
    amount = Number(amount);
    if (isNaN(amount) || amount === 0) return res.status(400).json({ message: 'Invalid amount' });

    const billUrl = req.file ? await uploadToCloudinary(req.file.path) : null;

    let wallet = await Wallet.findOne({ where: { userId: user } });
    if (!wallet) {
      wallet = await Wallet.create({ userId: user, balance: 0 });
    }

    const type = amount > 0 ? 'credit' : 'debit';

    const transaction = await Transaction.create({
      userId: user,
      amount: Math.abs(amount),
      type: type,
      bill: billUrl,
      description
    });

    wallet.balance = Number(wallet.balance) + amount;
    await wallet.save();

    res.status(200).json({ message: 'Funds adjusted successfully', wallet });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});

// Get Wallet
router.get('/get-wallet', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const wallet = await Wallet.findOne({ where: { userId } });
    if (!wallet) return res.status(404).json({ message: 'Wallet not found' });
    res.status(200).json(wallet);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});

// Get Transactions
router.get('/transactions', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const transactions = await Transaction.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']]
    });
    res.status(200).json(transactions);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching transactions', error: error.message });
  }
});

// Withdraw Funds
router.post('/withdraw-funds', authMiddleware, upload.single('bill'), async (req, res) => {
  try {
    const { amount, description, category } = req.body;
    const userId = req.user.id;

    let withdrawalAmount = Number(amount);
    if (isNaN(withdrawalAmount) || withdrawalAmount <= 0) return res.status(400).json({ message: 'Invalid amount' });

    const wallet = await Wallet.findOne({ where: { userId } });
    if (!wallet) return res.status(404).json({ message: 'Wallet not found' });

    const billUrl = req.file ? await uploadToCloudinary(req.file.path) : null;

    const transaction = await Transaction.create({
      userId,
      amount: withdrawalAmount,
      type: 'debit',
      bill: billUrl,
      categoryId: category || null,
      description
    });

    wallet.balance = Number(wallet.balance) - withdrawalAmount;
    await wallet.save();

    res.status(200).json({ message: 'Funds withdrawn successfully', wallet });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});

// Get categories
router.get('/category', async (req, res) => {
  try {
    const categories = await ExpensesCategory.findAll();
    res.status(200).json(categories);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching categories', error: err.message });
  }
});

module.exports = router;