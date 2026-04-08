import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/Product/Product.dart';
import '../../Models/product/getproduct_model.dart';

class ProductSelectionScreen extends StatefulWidget {
  final String? initialCategoryId;
  final Function(GetProductModel) onProductSelected;
  final int productIndex;

  const ProductSelectionScreen({
    super.key,
    this.initialCategoryId,
    required this.onProductSelected,
    required this.productIndex,
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxnString _selectedCategoryId = RxnString();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId.value = widget.initialCategoryId;
    _searchCtrl.addListener(() {
      _searchQuery.value = _searchCtrl.text;
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {});
      });
    });
    if (_productController.products.isEmpty) {
      _productController.fetchProducts();
    }
  }

  bool _matchesProductSearch(GetProductModel product) {
    final query = _searchQuery.value.toLowerCase();
    if (_selectedCategoryId.value != null &&
        product.productCategory?.id != _selectedCategoryId.value) {
      return false;
    }
    if (query.isEmpty) return true;
    return (product.productName?.toLowerCase().contains(query) ?? false) ||
        (product.productCategory?.productCategory?.toLowerCase().contains(query) ?? false) ||
        (product.hsn?.toLowerCase().contains(query) ?? false) ||
        (product.tax?.toString().contains(query) ?? false) ||
        (product.rate?.toString().contains(query) ?? false);
  }

  List<TextSpan> _highlightText(String text) {
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return [TextSpan(text: text)];
    }
    final matches = <TextSpan>[];
    final lower = text.toLowerCase();
    int start = 0;
    int idx = lower.indexOf(query);
    while (idx != -1) {
      if (idx > start) {
        matches.add(TextSpan(text: text.substring(start, idx)));
      }
      matches.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = idx + query.length;
      idx = lower.indexOf(query, start);
    }
    if (start < text.length) {
      matches.add(TextSpan(text: text.substring(start)));
    }
    return matches;
  }

  Widget _buildDetailRow(IconData icon, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Expanded(child: value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Select Product"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (_productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCategoryId.value,
                    decoration: InputDecoration(
                      hintText: 'Filter by Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All Categories'),
                      ),
                      ..._productController.products
                          .map((p) => p.productCategory)
                          .where((c) => c != null)
                          .map((c) => c!)
                          .toSet()
                          .map(
                            (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.productCategory!),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId.value = val!.isEmpty ? null : val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                      prefixIcon: const Icon(Icons.search, size: 22),
                      hintText: 'Search products…',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1565C0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _productController.products.isEmpty
                  ? const Center(
                child: Text(
                  'No Products Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _productController.products
                    .where(_matchesProductSearch)
                    .length,
                itemBuilder: (ctx, i) {
                  final product = _productController.products
                      .where(_matchesProductSearch)
                      .toList()[i];
                  return InkWell(
                    onTap: () {
                      widget.onProductSelected(product);
                      Get.back();
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag,
                                  size: 22,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: _highlightText(
                                        product.productName ?? 'Unnamed',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.category,
                              'Category',
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: _highlightText(
                                    product.productCategory?.productCategory ??
                                        'N/A',
                                  ),
                                ),
                              ),
                            ),
                            _buildDetailRow(
                              Icons.code,
                              'HSN',
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: _highlightText(product.hsn ?? 'N/A'),
                                ),
                              ),
                            ),
                            _buildDetailRow(
                              Icons.currency_rupee,
                              'Rate',
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: _highlightText(
                                    product.rate != null
                                        ? '₹${product.rate!.toStringAsFixed(2)}'
                                        : 'N/A',
                                  ),
                                ),
                              ),
                            ),
                            _buildDetailRow(
                              Icons.percent,
                              'Tax',
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: _highlightText(
                                    product.tax != null
                                        ? '${product.tax}%'
                                        : 'N/A',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}