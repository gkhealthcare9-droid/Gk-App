import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/Product/Product.dart';
import '../../Models/product/getproduct_model.dart';
import '../../Models/product/product_category_model.dart';
import '../../Utils/Colors.dart';

class EditProductScreen extends StatefulWidget {
  final GetProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductController _productController = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController hsnController = TextEditingController();

  ProductCategoryModel? selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product.productName ?? '';
    rateController.text = widget.product.rate?.toString() ?? '';
    taxController.text = widget.product.tax?.toString() ?? '';
    hsnController.text = widget.product.hsn ?? '';

    selectedCategory = _productController.categories.firstWhereOrNull(
      (cat) => cat.id == widget.product.productCategory?.id,
    );
  }

  void _saveChanges() async {
    print("🔍 Save button pressed");
    print("Product Name: ${nameController.text}");
    print("Rate: ${rateController.text}");
    print("Tax: ${taxController.text}");
    print("HSN: ${hsnController.text}");
    print("Selected Category: ${selectedCategory?.id}");

    if (nameController.text.isEmpty ||
        rateController.text.isEmpty ||
        selectedCategory == null) {
      print("❌ Validation failed — missing required fields");
      Get.snackbar("Error", "Please fill in all required fields");
      return;
    }

    print("✅ Validation passed. Updating product...");

    final success = await _productController.updateProduct(
      id: widget.product.id!,
      productName: nameController.text,
      rate: double.tryParse(rateController.text) ?? 0,
      tax: int.tryParse(taxController.text) ?? 0,
      hsn: hsnController.text,
      categoryId: selectedCategory!.id!,
    );

    if (success) {
      Get.snackbar("Success", "Product updated successfully");
      Navigator.pop(
        context,
        GetProductModel(
          id: widget.product.id,
          productName: nameController.text,
          rate: double.tryParse(rateController.text) ?? 0,
          tax: int.tryParse(taxController.text) ?? 0,
          hsn: hsnController.text,
          productCategory: ProductCategory(
            id: selectedCategory?.id,
            productCategory: selectedCategory?.productCategory,
          ),
        ),
      );
    } else {
      Get.snackbar("Failed", "Could not update product");
      print("jishad ==== ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Product Name", nameController),
            const SizedBox(height: 12),
            _buildTextField("Rate", rateController, TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField("Tax %", taxController, TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField("HSN Code", hsnController),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProductCategoryModel>(
              initialValue: selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Product Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items:
                  _productController.categories.map((cat) {
                    return DropdownMenuItem<ProductCategoryModel>(
                      value: cat,
                      child: Text(cat.productCategory ?? 'Unnamed'),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                print("BUTTON TAPPED");
                _saveChanges();
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
