import 'dart:io' as io;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:file_picker/file_picker.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final ProductController _productController = Get.put(ProductController());

  final TextEditingController _productNameCtrl = TextEditingController();
  final TextEditingController _hsnCtrl = TextEditingController();
  final TextEditingController _rate = TextEditingController();
  final TextEditingController _tax = TextEditingController();

  String? selectedCategory;
  List<PlatformFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _productController.fetchCategories();
    });
  }

  Future<void> pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedImages = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: CustomAppBar(title: "Create Product"),
        body: Obx(() {
          if (_productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdownField(
                  value: selectedCategory,
                  items:
                      _productController.categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(
                                category.productCategory ?? 'Unnamed',
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                    });
                  },
                  hintText: 'Select Category',
                  icon: Icons.list,
                ),
                const SizedBox(height: 16),

                // Product Name
                CustomTextField(
                  controller: _productNameCtrl,
                  label: 'Part Name',
                  hintText: ' Part name',
                  icon: Icons.shopping_bag,
                ),
                const SizedBox(height: 16),

                // HSN Code
                CustomTextField(
                  controller: _hsnCtrl,
                  label: 'HSN Code',
                  hintText: ' HSN Code',
                  icon: Icons.code,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _tax,
                  label: 'Tax (%)',
                  hintText: 'Tax Rate %',
                  icon: Icons.percent,
                  // showSuffixIcon and onTapSuffix remain unused here
                  showSuffixIcon: false,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _rate,
                  label: 'Rate',
                  hintText: 'Selling Price',
                  icon: Icons.currency_rupee,
                ),
                const SizedBox(height: 16),

                // Image Picker
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Product Images"),
                ),
                const SizedBox(height: 10),

                // Selected Images Preview
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.memory(
                                    selectedImages[i].bytes!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    io.File(selectedImages[i].path!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Submit Button
                Center(
                child: ElevatedButton(
                onPressed: () {
                final rate = double.tryParse(_rate.text);
                final tax = int.tryParse(_tax.text);

                if (selectedCategory == null) {
                  CustomAlert.error('Please select a category');
                  return;
                }
                if (_productNameCtrl.text.trim().isEmpty) {
                  CustomAlert.error('Please enter Part name');
                  return;
                }
                if (_hsnCtrl.text.trim().isEmpty) {
                  CustomAlert.error('Please enter HSN code');
                  return;
                }
                if (rate == null) {
                  CustomAlert.error('Please enter valid Price');
                  return;
                }
                if (tax == null) {
                  CustomAlert.error('Please enter valid tax percentage');
                  return;
                }
                // if (selectedImages.isEmpty) {
                // Get.snackbar('Error', 'Please select at least one product image');
                // return;
                // }

                // Collect bytes for each image
                Future.microtask(() async {
                  List<Uint8List> imageBytesList = [];
                  List<String> fileNames = [];

                  for (var file in selectedImages) {
                    if (kIsWeb) {
                      if (file.bytes != null) {
                        imageBytesList.add(file.bytes!);
                        fileNames.add(file.name);
                      }
                    } else {
                      final bytes = await io.File(file.path!).readAsBytes();
                      imageBytesList.add(bytes);
                      fileNames.add(file.name);
                    }
                  }

                  _productController.addProduct(
                    hsn: _hsnCtrl.text.trim(),
                    category: selectedCategory!,
                    productName: _productNameCtrl.text.trim(),
                    rate: rate,
                    tax: tax,
                    imageBytesList: imageBytesList,
                    fileNames: fileNames,
                  );
                });
                },
                style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48), // Full-width, consistent height
                backgroundColor: Color(0xFF2DC6E2), // Cyan background
                foregroundColor: Colors.white, // White text
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: const Text("Submit Product"),
          ),
          ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
