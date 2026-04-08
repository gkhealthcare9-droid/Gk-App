import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controllers/Product/Product.dart'; // Adjust path as needed

class AddCustomerProductScreen extends StatefulWidget {
  final String id;
  const AddCustomerProductScreen({super.key, required this.id});

  @override
  State<AddCustomerProductScreen> createState() => _AddCustomerProductScreenState();
}

class _AddCustomerProductScreenState extends State<AddCustomerProductScreen> {
  final ProductController _controller = Get.find<ProductController>();
  String? _selectedCategoryId;
  String? _selectedManufacturerId;
  final TextEditingController _serialNumberController = TextEditingController();
  DateTime? _installationDate; // Changed from _soldDate
  DateTime? _warrantyDate;

  Future<void> _pickInstallationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _installationDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _installationDate = picked;
      });
    }
  }

  Future<void> _pickWarrantyDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _warrantyDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _warrantyDate = picked;
      });
    }
  }

  void _saveAndReturn() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product category.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_selectedManufacturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a manufacturer.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_serialNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a serial number.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_installationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an installation date.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_warrantyDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a warranty end date.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    await _controller.addCustomerProduct(
      customerId: widget.id,
      productCategoryId: _selectedCategoryId!,
      slNumber: _serialNumberController.text.trim(),
      manufacturer: _selectedManufacturerId!,
      soldDate: DateFormat('yyyy-MM-dd').format(_installationDate!),
      warrantyDate: DateFormat('yyyy-MM-dd').format(_warrantyDate!),
      amcStart: null,
      amcEnd: null,
    );

    if (!_controller.isLoading.value) {
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _controller.fetchManufacturers();
      await _controller.fetchCategories(); // Ensure categories are fetched
    });
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? d) => d == null ? 'Select date' : DateFormat('dd/MM/yyyy').format(d);
    final installationDateText = formatDate(_installationDate);
    final warrantyDateText = formatDate(_warrantyDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer Product'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Product Category *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    items: _controller.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.productCategory ?? ""),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        print('//////////////////////////VAL $val');
                        _selectedCategoryId = val;
                        if (val == null) {
                          _selectedManufacturerId = null;
                          _serialNumberController.clear();
                          _installationDate = null;
                          _warrantyDate = null;
                        }
                      });
                    },
                    hint: const Text('Select category'),
                  ),
                  const SizedBox(height: 24),

                  // Manufacturer Dropdown
                  Obx(() {
                    if (_controller.isLoading.value) {
                      return const SizedBox();
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedManufacturerId,
                      decoration: InputDecoration(
                        labelText: 'Manufacturer *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      items: _controller.manufacturers.map((manufacturer) {
                        return DropdownMenuItem(
                          value: manufacturer.id,
                          child: Text(manufacturer.manufacturer),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedManufacturerId = val;
                        });
                      },
                      hint: const Text('Select manufacturer'),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Serial Number Text Field
                  TextFormField(
                    controller: _serialNumberController,
                    decoration: InputDecoration(
                      labelText: 'Serial Number *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Installation Date Picker
                  GestureDetector(
                    onTap: _pickInstallationDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            'Installation Date: $installationDateText',
                            style: TextStyle(
                              fontSize: 16,
                              color: _installationDate == null ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Warranty End Date Picker
                  GestureDetector(
                    onTap: _pickWarrantyDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            'Warranty End Date: $warrantyDateText',
                            style: TextStyle(
                              fontSize: 16,
                              color: _warrantyDate == null ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _saveAndReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (_controller.isLoading.value) const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}