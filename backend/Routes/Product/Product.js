const express = require('express');
const router = express.Router();
const multer = require("multer");
const fs = require("fs");
const cloudinary = require("cloudinary").v2;
const userAuth = require('../../Middleware/auth');
const Product = require('../../Models/Product/Product');
const ProductCategory = require('../../Models/Product/ProductCategory');
const ProductManufacturer = require('../../Models/Product/ProductManufacturer');

// Cloudinary config
cloudinary.config({
  cloud_name: 'dfmtzif75',
  api_key: '914528999856855',
  api_secret: 'QAs6_pa7vCozj6o0USKnMm8lJkM'
});

// Multer setup
const upload = multer({ dest: 'uploads/' });
const multiUpload = multer({ dest: 'uploads/' }).array('images', 5);

const uploadToCloudinary = async (filePath, folder = 'product-images') => {
  const result = await cloudinary.uploader.upload(filePath, {
    folder,
    resource_type: 'image'
  });
  fs.unlinkSync(filePath);
  return result.secure_url;
};

async function generateUniqueProductId() {
    let unique = false;
    let productId;

    while (!unique) {
        productId = Math.floor(1000 + Math.random() * 9000);
        const existing = await Product.findOne({ where: { productId } });
        if (!existing) unique = true;
    }
    return productId;
}

// Create manufacturer
router.post('/manufacturer', userAuth, async (req, res) => {
  try {
    const manufacturer = await ProductManufacturer.create({ manufacturer: req.body.manufacturer });
    res.status(201).json(manufacturer);
  } catch (err) {
    res.status(500).json({ message: 'Error adding manufacturer', error: err.message });
  }
});

// Get all manufacturers
router.get('/manufacturer', userAuth, async (req, res) => {
    try {
      const manufacturers = await ProductManufacturer.findAll({ order: [['createdAt', 'DESC']] });
      res.json(manufacturers);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching manufacturers', error: err.message });
    }
  });

// Create category
router.post('/category', userAuth, upload.single('image'), async (req, res) => {
    try {
      const { productCategory } = req.body;
      let imageUrl = null;
  
      if (req.file) {
        imageUrl = await uploadToCloudinary(req.file.path, 'category-images');
      }
  
      const category = await ProductCategory.create({
        productCategory,
        image: imageUrl
      });
  
      res.status(201).json(category);
    } catch (err) {
      res.status(500).json({ message: 'Error creating category', error: err.message });
    }
  });

// Get all categories
router.get('/category', userAuth, async (req, res) => {
  try {
    const categories = await ProductCategory.findAll({ order: [['createdAt', 'DESC']] });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching categories', error: err.message });
  }
});

// Get all products
router.get('/product', userAuth, async (req, res) => {
  try {
    // Note: includes will require associations to be defined. 
    // For now we'll just return raw data or join if associations set.
    const products = await Product.findAll({
      order: [['createdAt', 'DESC']]
    });
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching products', error: err.message });
  }
});

// Create product
router.post('/product', userAuth, multiUpload, async (req, res) => {
  try {
    const { productCategory, productName, tax, HSN, rate } = req.body;
    const productId = await generateUniqueProductId();

    let imageUrls = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const url = await uploadToCloudinary(file.path, 'product-images');
        imageUrls.push(url);
      }
    }

    const product = await Product.create({
      productCategoryId: productCategory,
      productName,
      tax,
      HSN,
      rate,
      images: imageUrls,
      productId
    });

    res.status(201).json(product);
  } catch (err) {
    res.status(500).json({ message: 'Error creating product', error: err.message });
  }
});

// Update product
router.put('/product/:id', userAuth, multiUpload, async (req, res) => {
  try {
    const { productCategory, productName, tax, HSN, rate } = req.body;
    const updateData = {
      productCategoryId: productCategory,
      productName,
      tax,
      HSN,
      rate
    };

    if (req.files && req.files.length > 0) {
      const imageUrls = [];
      for (const file of req.files) {
        const url = await uploadToCloudinary(file.path, 'product-images');
        imageUrls.push(url);
      }
      updateData.images = imageUrls;
    }

    const [updated] = await Product.update(updateData, { where: { id: req.params.id } });
    if (updated === 0) return res.status(404).json({ message: 'Product not found' });
    const product = await Product.findByPk(req.params.id);
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: 'Error updating product', error: err.message });
  }
});

module.exports = router;