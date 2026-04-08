import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Models/product/customer_product.dart';
import 'package:sales_grow/Utils/Colors.dart';

class EditCustomerProductScreen extends StatefulWidget {
  final CustomerProduct product;

  const EditCustomerProductScreen({super.key, required this.product});

  @override
  State<EditCustomerProductScreen> createState() => _EditCustomerProductScreenState();
}

class _EditCustomerProductScreenState extends State<EditCustomerProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = Get.find<ProductController>();

  late TextEditingController _serialController;
  DateTime? _soldDate;
  DateTime? _warrantyDate;
  DateTime? _amcStartDate;
  DateTime? _amcEndDate;

  String? _selectedCategoryId;
  String? _selectedManufacturerId;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController(text: widget.product.slNumber);
    _soldDate = widget.product.soldDate;
    _warrantyDate = widget.product.warranty;
    _amcStartDate = widget.product.amcStart;
    _amcEndDate = widget.product.amcEnd;

    _selectedCategoryId = widget.product.productCategory?.id;
    _selectedManufacturerId = widget.product.manufacturer?.id;

    Future.delayed(Duration.zero, () {
      if (_productController.categories.isEmpty) {
        _productController.fetchCategories();
      }
      if (_productController.manufacturers.isEmpty) {
        _productController.fetchManufacturers();
      }
    });
  }

  Future<void> _selectDate(DateTime? initialDate, Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: date != null ? DateFormat('dd-MM-yyyy').format(date) : '',
      ),
    );
  }

  void _saveChanges() async {
    print('🛠️ _saveChanges() called');

    if (!_formKey.currentState!.validate()) {
      print('❗ Form validation failed');
      return;
    }

    if (_soldDate == null || _warrantyDate == null) {
      print('❗ Missing sold or warranty date');
      Get.snackbar('Missing Dates', 'Sold Date and Warranty Date are required.',
          backgroundColor: AppColors.yellow.withOpacity(0.2), colorText: AppColors.black);
      return;
    }

    if (_selectedCategoryId == null || _selectedManufacturerId == null) {
      print('❗ Missing dropdown selection');
      Get.snackbar('Missing Selection', 'Please select both Category and Manufacturer.',
          backgroundColor: AppColors.yellow.withOpacity(0.2), colorText: AppColors.black);
      return;
    }

    final updatedProduct = PostCustomerProductModel(
      customer: widget.product.customer.id,
      productCategory: _selectedCategoryId!,
      manufacturer: _selectedManufacturerId!,
      slNumber: _serialController.text.trim(),
      soldDate: _soldDate!,
      warranty: _warrantyDate!,
      amcStart: _amcStartDate,
      amcEnd: _amcEndDate,
    );

    print('📦 Sending updateCustomerProduct() request...');
    print('   → Customer: ${widget.product.customer.id}');
    print('   → Category: $_selectedCategoryId');
    print('   → Manufacturer: $_selectedManufacturerId');
    print('   → Serial Number: ${_serialController.text.trim()}');

    final success = await _productController.updateCustomerProduct(widget.product.id, updatedProduct);

    print('✅ updateCustomerProduct returned: $success');

    if (success) {
      Get.back(result: true);
      Get.snackbar('Updated', 'Customer product updated successfully',
          backgroundColor: Colors.green.shade100, colorText: AppColors.black);
    } else {
      Get.snackbar('Failed', 'Failed to update customer product',
          backgroundColor: Colors.red.shade100, colorText: AppColors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Customer Product')),
      body: Obx(() {
        final categories = _productController.categories;
        final manufacturers = _productController.manufacturers;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            shadowColor: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      items: categories
                          .map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.productCategory ?? ''),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      decoration: InputDecoration(
                        labelText: 'Product Category',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) => val == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedManufacturerId,
                      items: manufacturers
                          .map((man) => DropdownMenuItem(
                        value: man.id,
                        child: Text(man.manufacturer),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedManufacturerId = val),
                      decoration: InputDecoration(
                        labelText: 'Manufacturer',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) => val == null ? 'Please select a manufacturer' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serialController,
                      decoration: InputDecoration(
                        labelText: 'Serial Number',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField('Sold Date', _soldDate, () => _selectDate(_soldDate, (val) => setState(() => _soldDate = val))),
                    const SizedBox(height: 16),
                    _buildDateField('Warranty Date', _warrantyDate, () => _selectDate(_warrantyDate, (val) => setState(() => _warrantyDate = val))),
                    const SizedBox(height: 16),
                    _buildDateField('AMC Start Date', _amcStartDate, () => _selectDate(_amcStartDate, (val) => setState(() => _amcStartDate = val))),
                    const SizedBox(height: 16),
                    _buildDateField('AMC End Date', _amcEndDate, () => _selectDate(_amcEndDate, (val) => setState(() => _amcEndDate = val))),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('✅ Save Changes button clicked');
                          _saveChanges();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
