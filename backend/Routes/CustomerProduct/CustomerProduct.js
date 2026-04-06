const CustomerProduct = require('../../Models/CustomerProduct/CustomerProduct');
const express = require('express');
const router = express.Router();
const userAuth = require('../../Middleware/auth');

// Add Customer Product
router.post('/add', userAuth, async (req, res) => {
  try {
    const { customer, productCategory, manufacturer, slNumber, soldDate, warranty, amcStart, amcEnd } = req.body;

    if (warranty && (amcStart || amcEnd)) {
      return res.status(400).json({ message: 'Product is under warranty. Cannot add AMC now.' });
    }

    const productData = {
      customerId: customer,
      productCategoryId: productCategory,
      manufacturerId: manufacturer,
      slNumber,
      soldDate,
      warranty: warranty || null,
      amcStart: warranty ? null : (amcStart || null),
      amcEnd: warranty ? null : (amcEnd || null),
    };

    const newProduct = await CustomerProduct.create(productData);
    res.status(201).json({ message: 'Customer Product added successfully', product: newProduct });
  } catch (err) {
    res.status(500).json({ message: 'Error adding customer product', error: err.message });
  }
});

// Get by Customer
router.get('/by-customer/:customerId', userAuth, async (req, res) => {
    try {
      const products = await CustomerProduct.findAll({
        where: { customerId: req.params.customerId },
        order: [['createdAt', 'DESC']]
      });
      res.json(products);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching customer products', error: err.message });
    }
  });

// Update
router.put('/:id', userAuth, async (req, res) => {
    try {
      const { customer, productCategory, manufacturer, slNumber, soldDate, warranty, amcStart, amcEnd } = req.body;
  
      if (warranty && (amcStart || amcEnd)) {
        return res.status(400).json({ message: 'Product is under warranty. Cannot add AMC.' });
      }
  
      const updateData = {
        customerId: customer,
        productCategoryId: productCategory,
        manufacturerId: manufacturer,
        slNumber,
        soldDate,
        warranty: warranty || null,
        amcStart: warranty ? null : (amcStart || null),
        amcEnd: warranty ? null : (amcEnd || null),
      };
  
      const [updated] = await CustomerProduct.update(updateData, { where: { id: req.params.id } });
      if (updated === 0) return res.status(404).json({ message: 'Customer Product not found' });
      const product = await CustomerProduct.findByPk(req.params.id);
      res.json({ message: 'Customer Product updated successfully', product });
    } catch (err) {
      res.status(500).json({ message: 'Error updating customer product', error: err.message });
    }
  });

// Delete
router.delete('/:id', userAuth, async (req, res) => {
    try {
      const deleted = await CustomerProduct.destroy({ where: { id: req.params.id } });
      if (deleted === 0) return res.status(404).json({ message: 'Customer Product not found' });
      res.json({ message: 'Customer Product deleted successfully' });
    } catch (err) {
      res.status(500).json({ message: 'Error deleting customer product', error: err.message });
    }
  });
  
module.exports = router;
