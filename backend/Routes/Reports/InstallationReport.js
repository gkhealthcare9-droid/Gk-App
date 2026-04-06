const express = require('express');
const router = express.Router();
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const cloudinary = require('cloudinary').v2;
const InstallationReport = require('../../Models/Reports/InstallationReport');
const userAuth = require('../../Middleware/auth');

// Cloudinary config
cloudinary.config({
  cloud_name: 'dfmtzif75',
  api_key: '914528999856855',
  api_secret: 'QAs6_pa7vCozj6o0USKnMm8lJkM'
});

// Multer config
const uploadPath = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadPath)) fs.mkdirSync(uploadPath);

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadPath),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname),
});
const upload = multer({ storage });

// Add Installation Report
router.post(
    '/',
    userAuth,
    upload.fields([{ name: 'clientSignature', maxCount: 1 }, { name: 'pdf', maxCount: 1 }]),
    async (req, res) => {
      try {
        let clientSignatureUrl = null;
        let pdfUrl = null;
  
        if (req.files['clientSignature']) {
          const result = await cloudinary.uploader.upload(req.files['clientSignature'][0].path, { folder: 'installation/signatures' });
          clientSignatureUrl = result.secure_url;
          fs.unlinkSync(req.files['clientSignature'][0].path);
        }
  
        if (req.files['pdf']) {
          const result = await cloudinary.uploader.upload(req.files['pdf'][0].path, { folder: 'installation/pdfs', resource_type: 'auto', type: 'upload' });
          pdfUrl = result.secure_url;
          fs.unlinkSync(req.files['pdf'][0].path);
        }

        const maxReport = await InstallationReport.max('reportNumber') || 1000;
  
        const reportData = {
          ...req.body,
          reportNumber: maxReport + 1,
          engineerId: req.user.id,
          customerId: req.body.customer,
          productCategoryId: req.body.productCategory,
          manufacturerId: req.body.manufacturer,
          clientNameId: req.body.clientName,
          signedById: req.body.signedBy,
          clientSignature: clientSignatureUrl,
          pdf: pdfUrl,
        };
  
        const report = await InstallationReport.create(reportData);
        res.status(201).json({ success: true, report });
      } catch (err) {
        res.status(500).json({ success: false, error: 'Server error', message: err.message });
      }
    }
  );
  
// Get All
router.get('/', userAuth, async (req, res) => {
    try {
      const reports = await InstallationReport.findAll({ order: [['createdAt', 'DESC']] });
      res.json(reports);
    } catch (err) {
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });
  
// Get Single
router.get('/:id', userAuth, async (req, res) => {
    try {
      const report = await InstallationReport.findByPk(req.params.id);
      if (!report) return res.status(404).json({ success: false, error: 'Report not found' });
      res.json({ success: true, report });
    } catch (err) {
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });
  
// Delete
router.delete('/:id', userAuth, async (req, res) => {
    try {
      const deleted = await InstallationReport.destroy({ where: { id: req.params.id } });
      if (deleted === 0) return res.status(404).json({ success: false, error: 'Report not found' });
      res.json({ success: true, message: 'Report deleted' });
    } catch (err) {
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });
  
module.exports = router;
