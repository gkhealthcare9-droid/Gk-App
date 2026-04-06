const express = require('express');
const router = express.Router();
const CustomerOutstanding = require('../../Models/Outstanding/CustomerOutstanding');
const Payment = require('../../Models/Outstanding/Payment');
const auth = require('../../Middleware/auth');

// Add Payment
router.post('/add-payment', auth, async (req, res) => {
  try {
    const { customer, amount, type, invoiceNumber, description } = req.body;

    const payment = await Payment.create({
      customerId: customer,
      amount,
      type,
      invoiceNumber,
      description
    });

    let outstanding = await CustomerOutstanding.findOne({ where: { customerId: customer } });

    if (!outstanding) {
      const initialDue = type === 'debit' ? Number(amount) : 0;
      outstanding = await CustomerOutstanding.create({
        customerId: customer,
        initialDue,
        currentDue: initialDue
      });
    } else {
      let newDue = Number(outstanding.currentDue);
      if (type === 'debit') newDue += Number(amount);
      else if (type === 'credit') newDue -= Number(amount);

      outstanding.currentDue = newDue;
      await outstanding.save();
    }

    res.json({ message: 'Payment added and outstanding updated', payment, outstanding });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Outstanding by Customer
router.get('/customer/:customerId', auth, async (req, res) => {
  try {
    const data = await CustomerOutstanding.findOne({ where: { customerId: req.params.customerId } });
    if (!data) return res.status(404).json({ message: 'No outstanding found' });
    const payments = await Payment.findAll({ where: { customerId: req.params.customerId } });
    res.json({ ...data.toJSON(), payments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get All Outstanding
router.get('/', auth, async (req, res) => {
  try {
    const all = await CustomerOutstanding.findAll({ order: [['createdAt', 'DESC']] });
    res.json(all);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete Payment
router.delete('/delete-payment/:paymentId', auth, async (req, res) => {
  try {
    const payment = await Payment.findByPk(req.params.paymentId);
    if (!payment) return res.status(404).json({ message: 'Payment not found' });

    const outstanding = await CustomerOutstanding.findOne({ where: { customerId: payment.customerId } });
    if (outstanding) {
      let newDue = Number(outstanding.currentDue);
      if (payment.type === 'debit') newDue -= Number(payment.amount);
      else if (payment.type === 'credit') newDue += Number(payment.amount);
      outstanding.currentDue = newDue;
      await outstanding.save();
    }

    await Payment.destroy({ where: { id: req.params.paymentId } });
    res.json({ message: 'Payment deleted and outstanding updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
