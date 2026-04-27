import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AddVendor/vendor_controller.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Models/product/getproduct_model.dart';
import 'package:sales_grow/Models/Vendor/Vendor.dart';
import '../Widgets/CustomAlert.dart';
import '../Widgets/CustomAppBar.dart';

class DeliveryChallanScreen extends StatefulWidget {
  const DeliveryChallanScreen({super.key});

  @override
  State<DeliveryChallanScreen> createState() => _DeliveryChallanScreenState();
}

class _DeliveryChallanScreenState extends State<DeliveryChallanScreen> {
  final TextEditingController _vendorIdCtrl = TextEditingController(text: 'GK');
  final TextEditingController _vendorNameCtrl = TextEditingController();
  final TextEditingController _vendorAddressCtrl = TextEditingController();
  final TextEditingController _vendorAddressCtrlTwo = TextEditingController();
  final TextEditingController _vendorGSTCtrl = TextEditingController();
  final TextEditingController _vendorStateCtrl = TextEditingController();
  final TextEditingController _vendorContactCtrl = TextEditingController();
  final TextEditingController _vendorAccountsCtrl = TextEditingController();
  final TextEditingController _vendorEmailCtrl = TextEditingController();
  final TextEditingController _vendorCityCtrl = TextEditingController();
  final TextEditingController _vendorPincodeCtrl = TextEditingController();
  final TextEditingController _poNumberCtrl = TextEditingController();
  final TextEditingController _createdByCtrl = TextEditingController();
  final TextEditingController _transportChargeCtrl = TextEditingController(
    text: '800.00',
  );
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _productSearchCtrl = TextEditingController();
  final RxList<Map<String, dynamic>> _products = <Map<String, dynamic>>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxString _productSearchQuery = ''.obs;
  final RxString _selectedState = ''.obs;
  final RxString _selectedCity = ''.obs;
  final RxnString _selectedCategoryId = RxnString();
  final RxString _selectedTax = 'IGST (18%)'.obs;
  final RxBool _showVendorList = false.obs;
  final RxBool _isVendorLoading = false.obs;
  final RxBool _showVendorDetails = false.obs;
  final RxBool _showProductList = false.obs;
  final List<String> _taxOptions = ['IGST (18%)', 'GST (12%)'];
  final ProductController _productController = Get.put(ProductController());
  final VendorController _vendorController = Get.put(VendorController());
  final Map<int, FocusNode> _productIdFocusNodes = {};
  final FocusNode _vendorIdFocusNode = FocusNode();
  final GlobalKey _filterSectionKey = GlobalKey();
  final GlobalKey _productFilterSectionKey = GlobalKey();
  final GlobalKey _productCardKey = GlobalKey();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _addProduct();
    Future.delayed(Duration.zero, () async {
      await _productController.fetchProducts();
      await _vendorController.fetchVendors();
    });
    _vendorIdCtrl.addListener(_fetchVendorDetails);
    _searchCtrl.addListener(() {
      _searchQuery.value = _searchCtrl.text;
      _showVendorList.value =
          _searchQuery.value.isNotEmpty ||
          _selectedState.value.isNotEmpty ||
          _selectedCity.value.isNotEmpty;
    });
    _productSearchCtrl.addListener(() {
      _productSearchQuery.value = _productSearchCtrl.text;
      setState(() {
        _showProductList.value =
            _productSearchQuery.value.isNotEmpty ||
            _selectedCategoryId.value != null;
      });
    });
  }

  List<String> get _allCities {
    final list =
        _vendorController.vendors
            .where(
              (v) =>
                  _selectedState.value.isEmpty
                      ? true
                      : (v.state?.toLowerCase() ==
                          _selectedState.value.toLowerCase()),
            )
            .map((v) => v.city?.trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    list.sort();
    return list;
  }

  List<String> get _allStates {
    final list =
        _vendorController.vendors
            .map((v) => v.state?.trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    list.sort();
    return list;
  }

  bool _matchesSearch(VendorModel v) {
    final q = _searchQuery.value.toLowerCase();
    return (v.vendorQuniqeNumber?.toLowerCase().contains(q) ?? false) ||
        (v.vendorName?.toLowerCase().contains(q) ?? false) ||
        (v.vendorCompany?.toLowerCase().contains(q) ?? false) ||
        (v.vendorPhone?.toLowerCase().contains(q) ?? false) ||
        (v.vendorEmail?.toLowerCase().contains(q) ?? false) ||
        (v.vendorGSTIN?.toLowerCase().contains(q) ?? false) ||
        (v.addressOne?.toLowerCase().contains(q) ?? false) ||
        (v.addressTwo?.toLowerCase().contains(q) ?? false) ||
        (v.city?.toLowerCase().contains(q) ?? false) ||
        (v.state?.toLowerCase().contains(q) ?? false) ||
        (v.pincode?.toLowerCase().contains(q) ?? false);
  }

  bool _matchesProductSearch(GetProductModel product) {
    final query = _productSearchQuery.value.toLowerCase();
    if (_selectedCategoryId.value != null &&
        product.productCategory?.id != _selectedCategoryId.value) {
      return false;
    }
    if (query.isEmpty) return true;
    return (product.productName?.toLowerCase().contains(query) ?? false) ||
        (product.productCategory?.productCategory?.toLowerCase().contains(
              query,
            ) ??
            false) ||
        (product.hsn?.toLowerCase().contains(query) ?? false) ||
        (product.tax?.toString().contains(query) ?? false) ||
        (product.rate?.toString().contains(query) ?? false);
  }

  List<TextSpan> _highlightText(String text) {
    final query = _productSearchQuery.value.toLowerCase();
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

  Widget _highlight(String? text) {
    if (text == null || text.isEmpty) return const Text('N/A');
    final query = _searchQuery.value;
    if (query.isEmpty) return Text(text);
    final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
    final matches = pattern.allMatches(text);
    if (matches.isEmpty) return Text(text);
    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: spans,
      ),
    );
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

  void _selectVendor(VendorModel vendor) {
    setState(() {
      _vendorIdCtrl.text = vendor.vendorQuniqeNumber ?? 'GK';
      _vendorNameCtrl.text = vendor.vendorName ?? '';
      _vendorAddressCtrl.text = vendor.addressOne ?? '';
      _vendorAddressCtrlTwo.text = vendor.addressTwo ?? '';
      _vendorCityCtrl.text = vendor.city ?? '';
      _vendorPincodeCtrl.text = vendor.pincode ?? '';
      _vendorGSTCtrl.text = vendor.vendorGSTIN ?? '';
      _vendorStateCtrl.text = vendor.state ?? '';
      _vendorContactCtrl.text = vendor.vendorPhone ?? '';
      _vendorAccountsCtrl.text = vendor.vendorCompany ?? '';
      _vendorEmailCtrl.text = vendor.vendorEmail ?? '';
      _showVendorList.value = false;
      _showVendorDetails.value = true;
    });
  }

  void _selectProduct(GetProductModel product, int index) {
    setState(() {
      _products[index]['selectedProduct'] = product;
      (_products[index]['productId'] as TextEditingController).text =
          product.productId?.toString() ?? '';
      (_products[index]['name'] as TextEditingController).text =
          product.productName ?? '';
      (_products[index]['hsn'] as TextEditingController).text =
          product.hsn ?? '';
      (_products[index]['rate'] as TextEditingController).text =
          product.rate?.toStringAsFixed(2) ?? '';
      (_products[index]['tax'] as TextEditingController).text =
          product.tax?.toString() ?? '';
      (_products[index]['description'] as TextEditingController).text =
          product.productCategory?.productCategory ?? '';
      _showProductList.value = false;
      _productSearchCtrl.clear();
      _selectedCategoryId.value = null;
      _products.refresh();
    });
  }

  Widget _buildFilterSection() {
    return Container(
      key: _filterSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue:
                        _selectedState.value.isEmpty
                            ? null
                            : _selectedState.value,
                    decoration: InputDecoration(
                      hintText: 'Filter by State',
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
                        child: Text('All States'),
                      ),
                      ..._allStates.map(
                        (st) => DropdownMenuItem(value: st, child: Text(st)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedState.value = v ?? '';
                        _selectedCity.value = '';
                        _showVendorList.value =
                            _selectedState.value.isNotEmpty ||
                            _selectedCity.value.isNotEmpty ||
                            _searchQuery.value.isNotEmpty;
                        _vendorIdCtrl.text = 'GK';
                        _vendorNameCtrl.clear();
                        _vendorAddressCtrl.clear();
                        _vendorAddressCtrlTwo.clear();
                        _vendorCityCtrl.clear();
                        _vendorPincodeCtrl.clear();
                        _vendorGSTCtrl.clear();
                        _vendorStateCtrl.clear();
                        _vendorContactCtrl.clear();
                        _vendorAccountsCtrl.clear();
                        _vendorEmailCtrl.clear();
                        _showVendorDetails.value = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue:
                        _selectedCity.value.isEmpty
                            ? null
                            : _selectedCity.value,
                    decoration: InputDecoration(
                      hintText: 'Filter by City',
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
                        child: Text('All Cities'),
                      ),
                      ..._allCities.map(
                        (ct) => DropdownMenuItem(value: ct, child: Text(ct)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedCity.value = v ?? '';
                        _showVendorList.value =
                            _selectedState.value.isNotEmpty ||
                            _selectedCity.value.isNotEmpty ||
                            _searchQuery.value.isNotEmpty;
                        _vendorIdCtrl.text = 'GK';
                        _vendorNameCtrl.clear();
                        _vendorAddressCtrl.clear();
                        _vendorAddressCtrlTwo.clear();
                        _vendorCityCtrl.clear();
                        _vendorPincodeCtrl.clear();
                        _vendorGSTCtrl.clear();
                        _vendorStateCtrl.clear();
                        _vendorContactCtrl.clear();
                        _vendorAccountsCtrl.clear();
                        _vendorEmailCtrl.clear();
                        _showVendorDetails.value = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              prefixIcon: const Icon(Icons.search, size: 22),
              hintText: 'Search vendors by ID, name, company, etc.',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductFilterSection() {
    return Container(
      key: _productFilterSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final catsRaw =
                _productController.products
                    .map((p) => p.productCategory)
                    .where((c) => c != null)
                    .map((c) => c!)
                    .toList();
            final uniqueCats =
                {for (var c in catsRaw) c.id!: c}.values.toList();
            return DropdownButtonFormField<String>(
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
                ...uniqueCats.map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.productCategory!),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedCategoryId.value = val!.isEmpty ? null : val;
                  _showProductList.value =
                      _productSearchQuery.value.isNotEmpty ||
                      _selectedCategoryId.value != null;
                });
              },
            );
          }),
          const SizedBox(height: 8),
          TextField(
            controller: _productSearchCtrl,
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
    );
  }

  Widget _buildVendorList() {
    return Obx(() {
      final filteredVendors =
          _vendorController.vendors.where((v) {
            final matchesSearch = _matchesSearch(v);
            final matchesState =
                _selectedState.value.isEmpty
                    ? true
                    : (v.state?.toLowerCase() ==
                        _selectedState.value.toLowerCase());
            final matchesCity =
                _selectedCity.value.isEmpty
                    ? true
                    : (v.city?.toLowerCase() ==
                        _selectedCity.value.toLowerCase());
            return matchesSearch && matchesState && matchesCity;
          }).toList();

      if (_vendorController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (filteredVendors.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'No Vendors Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: filteredVendors.length,
        itemBuilder: (ctx, i) {
          final v = filteredVendors[i];
          return InkWell(
            onTap: () => _selectVendor(v),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    v.vendorName?.isNotEmpty ?? false
                        ? v.vendorName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: _highlight(v.vendorCompany),
                subtitle: _highlight(v.vendorName),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildDetailRow(
                    Icons.person,
                    'Name',
                    _highlight(v.vendorName),
                  ),
                  _buildDetailRow(
                    Icons.business,
                    'Company',
                    _highlight(v.vendorCompany),
                  ),
                  _buildDetailRow(
                    Icons.phone,
                    'Phone',
                    _highlight(v.vendorPhone),
                  ),
                  _buildDetailRow(
                    Icons.email,
                    'Email',
                    _highlight(v.vendorEmail),
                  ),
                  _buildDetailRow(
                    Icons.badge,
                    'GSTIN',
                    _highlight(v.vendorGSTIN),
                  ),
                  _buildDetailRow(
                    Icons.home,
                    'Address',
                    _highlight(
                      '${v.addressOne ?? ''}${v.addressTwo != null && v.addressTwo!.isNotEmpty ? ', ${v.addressTwo}' : ''}${v.city != null && v.city!.isNotEmpty ? ', ${v.city}' : ''}${v.state != null && v.state!.isNotEmpty ? ', ${v.state}' : ''}${v.pincode != null && v.pincode!.isNotEmpty ? ' - ${v.pincode}' : ''}',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildProductList(int index) {
    return Obx(() {
      if (_productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final filtered =
          _productController.products.where(_matchesProductSearch).toList();
      if (filtered.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'No Products Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) {
          final product = filtered[i];
          return InkWell(
            onTap: () => _selectProduct(product, index),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            product.productCategory?.productCategory ?? 'N/A',
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
                            product.tax != null ? '${product.tax}%' : 'N/A',
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
      );
    });
  }

  bool _isTapOutside(Offset globalPosition) {
    final filterRenderBox =
        _filterSectionKey.currentContext?.findRenderObject() as RenderBox?;
    final productFilterRenderBox =
        _productFilterSectionKey.currentContext?.findRenderObject()
            as RenderBox?;
    final productCardRenderBox =
        _productCardKey.currentContext?.findRenderObject() as RenderBox?;

    if (filterRenderBox != null) {
      final filterPosition = filterRenderBox.localToGlobal(Offset.zero);
      final filterSize = filterRenderBox.size;
      final filterRect = Rect.fromLTWH(
        filterPosition.dx,
        filterPosition.dy,
        filterSize.width,
        filterSize.height,
      );
      if (filterRect.contains(globalPosition)) {
        return false;
      }
    }

    if (productFilterRenderBox != null) {
      final productFilterPosition = productFilterRenderBox.localToGlobal(
        Offset.zero,
      );
      final productFilterSize = productFilterRenderBox.size;
      final productFilterRect = Rect.fromLTWH(
        productFilterPosition.dx,
        productFilterPosition.dy,
        productFilterSize.width,
        productFilterSize.height,
      );
      if (productFilterRect.contains(globalPosition)) {
        return false;
      }
    }

    if (productCardRenderBox != null) {
      final productCardPosition = productCardRenderBox.localToGlobal(
        Offset.zero,
      );
      final productCardSize = productCardRenderBox.size;
      final productCardRect = Rect.fromLTWH(
        productCardPosition.dx,
        productCardPosition.dy,
        productCardSize.width,
        productCardSize.height,
      );
      if (productCardRect.contains(globalPosition)) {
        return false;
      }
    }

    return true;
  }

  Widget _buildVendorDetailsContainer() {
    final addressParts = [
      if (_vendorAddressCtrl.text.isNotEmpty) _vendorAddressCtrl.text,
      if (_vendorAddressCtrlTwo.text.isNotEmpty) _vendorAddressCtrlTwo.text,
      if (_vendorCityCtrl.text.isNotEmpty) _vendorCityCtrl.text,
      if (_vendorStateCtrl.text.isNotEmpty) _vendorStateCtrl.text,
      if (_vendorPincodeCtrl.text.isNotEmpty) _vendorPincodeCtrl.text,
    ];
    final address = addressParts.join(', ');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.black, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_vendorNameCtrl.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vendor Name: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _vendorNameCtrl.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            if (_vendorNameCtrl.text.isNotEmpty) const SizedBox(height: 8),
            if (address.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(address, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            if (address.isNotEmpty) const SizedBox(height: 8),
            if (_vendorContactCtrl.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _vendorContactCtrl.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            if (_vendorContactCtrl.text.isNotEmpty) const SizedBox(height: 8),
            if (_vendorAccountsCtrl.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accounts: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _vendorAccountsCtrl.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            if (_vendorAccountsCtrl.text.isNotEmpty) const SizedBox(height: 8),
            if (_vendorEmailCtrl.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _vendorEmailCtrl.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            if (_vendorEmailCtrl.text.isNotEmpty) const SizedBox(height: 8),
            if (_vendorGSTCtrl.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GSTIN: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _vendorGSTCtrl.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _addProduct() {
    final productIdCtrl = TextEditingController();
    final productIndex = _products.length;
    _productIdFocusNodes[productIndex] = FocusNode();
    _products.add({
      'name': TextEditingController(),
      'hsn': TextEditingController(),
      'rate': TextEditingController(),
      'description': TextEditingController(),
      'quantity': TextEditingController(text: '1'),
      'tax': TextEditingController(),
      'productId': productIdCtrl,
      'selectedProduct': null,
    });

    productIdCtrl.addListener(() {
      final productIdText = productIdCtrl.text.trim();
      final productId = int.tryParse(productIdText);
      if (productId != null) {
        _fetchProductDetails(productId, productIndex);
      } else {
        _clearProductFields(productIndex);
      }
    });
  }

  void _removeProduct(int index) {
    _products[index].forEach((key, value) {
      if (value is TextEditingController) value.dispose();
    });
    _productIdFocusNodes[index]?.dispose();
    _productIdFocusNodes.remove(index);
    _products.removeAt(index);
    final newFocusNodes = <int, FocusNode>{};
    _productIdFocusNodes.forEach((key, value) {
      if (key > index) {
        newFocusNodes[key - 1] = value;
      } else if (key < index) {
        newFocusNodes[key] = value;
      }
    });
    _productIdFocusNodes.clear();
    _productIdFocusNodes.addAll(newFocusNodes);
  }

  void _clearForm() {
    _vendorIdCtrl.text = 'GK';
    _vendorNameCtrl.clear();
    _vendorAddressCtrl.clear();
    _vendorAddressCtrlTwo.clear();
    _vendorCityCtrl.clear();
    _vendorPincodeCtrl.clear();
    _vendorGSTCtrl.clear();
    _vendorStateCtrl.clear();
    _vendorContactCtrl.clear();
    _vendorAccountsCtrl.clear();
    _vendorEmailCtrl.clear();
    _poNumberCtrl.clear();
    _createdByCtrl.clear();
    _transportChargeCtrl.text = '800.00';
    _selectedTax.value = 'IGST (18%)';
    _isVendorLoading.value = false;
    _showVendorDetails.value = false;
    _searchCtrl.clear();
    _productSearchCtrl.clear();
    _selectedState.value = '';
    _selectedCity.value = '';
    _selectedCategoryId.value = null;
    _showVendorList.value = false;
    _showProductList.value = false;
    for (var product in _products) {
      product.forEach((key, value) {
        if (value is TextEditingController) value.dispose();
      });
    }
    _productIdFocusNodes.forEach((_, node) => node.dispose());
    _productIdFocusNodes.clear();
    _products.clear();
    _addProduct();
  }

  Future<void> _fetchVendorDetails() async {
    final vendorIdText = _vendorIdCtrl.text.trim();
    if (vendorIdText.isEmpty ||
        !vendorIdText.startsWith('GK') ||
        vendorIdText == 'GK') {
      setState(() {
        _vendorNameCtrl.text = '';
        _vendorAddressCtrl.text = '';
        _vendorAddressCtrlTwo.text = '';
        _vendorCityCtrl.text = '';
        _vendorPincodeCtrl.text = '';
        _vendorGSTCtrl.text = '';
        _vendorStateCtrl.text = '';
        _vendorContactCtrl.text = '';
        _vendorEmailCtrl.text = '';
        _vendorAccountsCtrl.text = '';
        _showVendorDetails.value = false;
      });
      return;
    }

    _isVendorLoading.value = true;
    try {
      final vendor = await _vendorController.fetchVendorById(vendorIdText);
      if (vendor != null) {
        setState(() {
          _vendorNameCtrl.text = vendor.vendorName ?? '';
          _vendorAddressCtrl.text = vendor.addressOne ?? '';
          _vendorAddressCtrlTwo.text = vendor.addressTwo ?? '';
          _vendorCityCtrl.text = vendor.city ?? '';
          _vendorPincodeCtrl.text = vendor.pincode ?? '';
          _vendorGSTCtrl.text = vendor.vendorGSTIN ?? '';
          _vendorStateCtrl.text = vendor.state ?? '';
          _vendorContactCtrl.text = vendor.vendorPhone ?? '';
          _vendorAccountsCtrl.text = vendor.vendorCompany ?? '';
          _vendorEmailCtrl.text = vendor.vendorEmail ?? '';
          _showVendorDetails.value = true;
          _showVendorList.value = false;
        });
      } else {
        setState(() {
          _vendorNameCtrl.text = '';
          _vendorAddressCtrl.text = '';
          _vendorAddressCtrlTwo.text = '';
          _vendorCityCtrl.text = '';
          _vendorPincodeCtrl.text = '';
          _vendorGSTCtrl.text = '';
          _vendorStateCtrl.text = '';
          _vendorContactCtrl.text = '';
          _vendorEmailCtrl.text = '';
          _vendorAccountsCtrl.text = '';
          _showVendorDetails.value = false;
        });
        CustomAlert.error('No vendor found for ID: $vendorIdText');
      }
    } catch (e) {
      setState(() {
        _vendorNameCtrl.text = '';
        _vendorAddressCtrl.text = '';
        _vendorAddressCtrlTwo.text = '';
        _vendorCityCtrl.text = '';
        _vendorPincodeCtrl.text = '';
        _vendorGSTCtrl.text = '';
        _vendorStateCtrl.text = '';
        _vendorContactCtrl.text = '';
        _vendorEmailCtrl.text = '';
        _vendorAccountsCtrl.text = '';
        _showVendorDetails.value = false;
      });
      CustomAlert.error('Failed to fetch vendor: $e');
    } finally {
      _isVendorLoading.value = false;
    }
  }

  Future<void> _fetchProductDetails(int productId, int index) async {
    final hadFocus = _productIdFocusNodes[index]?.hasFocus ?? false;
    final selection =
        (_products[index]['productId'] as TextEditingController).selection;

    final product = await _productController.fetchProductById(productId);
    setState(() {
      if (product != null) {
        _products[index]['selectedProduct'] = product;
        (_products[index]['name'] as TextEditingController).text =
            product.productName ?? '';
        (_products[index]['hsn'] as TextEditingController).text =
            product.hsn ?? '';
        (_products[index]['rate'] as TextEditingController).text =
            product.rate?.toStringAsFixed(2) ?? '';
        (_products[index]['tax'] as TextEditingController).text =
            product.tax?.toString() ?? '';
        (_products[index]['description'] as TextEditingController).text =
            product.productCategory?.productCategory ?? '';
      } else {
        _clearProductFields(index);
      }
      _products.refresh();
    });

    if (hadFocus) {
      _productIdFocusNodes[index]?.requestFocus();
      (_products[index]['productId'] as TextEditingController).selection =
          selection;
    }
  }

  void _clearProductFields(int index) {
    setState(() {
      _products[index]['selectedProduct'] = null;
      (_products[index]['name'] as TextEditingController).text = '';
      (_products[index]['hsn'] as TextEditingController).text = '';
      (_products[index]['rate'] as TextEditingController).text = '';
      (_products[index]['tax'] as TextEditingController).text = '';
      (_products[index]['description'] as TextEditingController).text = '';
      (_products[index]['quantity'] as TextEditingController).text = '1';
      _products.refresh();
    });
  }

  Map<String, dynamic> _calculateTotal() {
    double subtotal = 0.0;
    for (var product in _products) {
      final rate =
          double.tryParse((product['rate'] as TextEditingController).text) ??
          0.0;
      final quantity =
          double.tryParse(
            (product['quantity'] as TextEditingController).text,
          ) ??
          0.0;
      subtotal += rate * quantity;
    }
    final taxRate = _selectedTax.value == 'GST (12%)' ? 0.12 : 0.18;
    final taxAmount = subtotal * taxRate;
    final transportCharge = double.tryParse(_transportChargeCtrl.text) ?? 0.0;
    return {
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'transportCharge': transportCharge,
      'total': subtotal + taxAmount + transportCharge,
    };
  }

  Future<void> _generateDeliveryChallan() async {
    for (var i = 0; i < _products.length; i++) {
      final product = _products[i];
      if ((product['productId'] as TextEditingController).text.isEmpty) {
        CustomAlert.error('Product ${i + 1}: Product ID is required');
        return;
      }
      if ((product['name'] as TextEditingController).text.isEmpty) {
        CustomAlert.error('Product ${i + 1}: Name is required');
        return;
      }
      if ((product['hsn'] as TextEditingController).text.isEmpty) {
        CustomAlert.error('Product ${i + 1}: HSN Code is required');
        return;
      }
      if ((product['rate'] as TextEditingController).text.isEmpty) {
        CustomAlert.error('Product ${i + 1}: Rate is required');
        return;
      }
      if ((product['description'] as TextEditingController).text.isEmpty) {
        CustomAlert.error('Product ${i + 1}: Description is required');
        return;
      }
      if ((product['quantity'] as TextEditingController).text.isEmpty) {
        CustomAlert.error('Product ${i + 1}: Quantity is required');
        return;
      }
      final double? rate = double.tryParse(
        (product['rate'] as TextEditingController).text,
      );
      final double? quantity = double.tryParse(
        (product['quantity'] as TextEditingController).text,
      );
      if (rate == null) {
        CustomAlert.error('Product ${i + 1}: Invalid rate');
        return;
      }
      if (quantity == null || quantity <= 0) {
        CustomAlert.error('Product ${i + 1}: Quantity must be greater than 0');
        return;
      }
    }

    if (_vendorNameCtrl.text.isEmpty) {
      CustomAlert.error('Vendor Name is required');
      return;
    }
    if (_vendorAddressCtrl.text.isEmpty) {
      CustomAlert.error('Vendor Address is required');
      return;
    }
    if (_vendorGSTCtrl.text.isEmpty) {
      CustomAlert.error('Vendor GSTIN is required');
      return;
    }
    if (_vendorStateCtrl.text.isEmpty) {
      CustomAlert.error('Vendor State Name is required');
      return;
    }
    if (_poNumberCtrl.text.isEmpty) {
      CustomAlert.error('PO Number is required');
      return;
    }
    if (_createdByCtrl.text.isEmpty) {
      CustomAlert.error('Created By is required');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delivery Challan'),
            content: const Text(
              'Are you sure you want to generate this Delivery Challan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Generate',
                  style: TextStyle(color: Color(0xFF1565C0)),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isGenerating = true);

    try {
      final products =
          _products.map((product) {
            return {
              'name': (product['name'] as TextEditingController).text,
              'description':
                  (product['description'] as TextEditingController).text,
              'hsn': (product['hsn'] as TextEditingController).text,
              'rate': double.parse(
                (product['rate'] as TextEditingController).text,
              ),
              'quantity': (product['quantity'] as TextEditingController).text,
              'tax': (product['tax'] as TextEditingController).text,
            };
          }).toList();

      await DeliveryChallanService.generateDeliveryChallan(
        vendorName: _vendorNameCtrl.text,
        vendorAddress: _vendorAddressCtrl.text,
        vendorGST: _vendorGSTCtrl.text,
        vendorState: _vendorStateCtrl.text,
        vendorContact:
            _vendorContactCtrl.text.isNotEmpty ? _vendorContactCtrl.text : null,
        vendorAccounts:
            _vendorAccountsCtrl.text.isNotEmpty
                ? _vendorAccountsCtrl.text
                : null,
        vendorEmail:
            _vendorEmailCtrl.text.isNotEmpty ? _vendorEmailCtrl.text : null,
        poNumber: _poNumberCtrl.text,
        products: products,
        transportCharge: double.parse(_transportChargeCtrl.text),
        selectedTax: _selectedTax.value,
        createdBy: _createdByCtrl.text,
      );
      CustomAlert.success('Delivery Challan generated successfully');
      _clearForm();
    } catch (e) {
      CustomAlert.error('Failed to generate Delivery Challan: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Widget _customTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    String? helperText,
    IconData? prefixIcon,
    bool readOnly = false,
    FocusNode? focusNode,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: isRequired ? '$label *' : label,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              helperText: helperText,
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.grey[600])
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1565C0),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorText: errorText,
            ),
            onChanged: (value) {
              if (label == 'Vendor ID' && value.isNotEmpty) {
                if (!value.startsWith('GK')) {
                  _vendorIdCtrl.text = 'GK${value.replaceAll('GK', '')}';
                  _vendorIdCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: _vendorIdCtrl.text.length),
                  );
                }
                _showVendorList.value =
                    false; // Close vendor list when typing Vendor ID
              }
              if (label != 'Product ID' && label != 'Vendor ID') {
                _products.refresh();
              }
            },
          ),
          if (_isVendorLoading.value && label == 'Vendor ID')
            const Positioned(
              right: 10,
              top: 20,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productInputField(int index) {
    return Stack(
      children: [
        _customTextField(
          'Product ID',
          _products[index]['productId'] as TextEditingController,
          helperText:
              _products[index]['selectedProduct'] == null &&
                      (_products[index]['productId'] as TextEditingController)
                          .text
                          .isNotEmpty
                  ? 'No product found'
                  : 'e.g., 123',
          prefixIcon: Icons.label,
          isRequired: true,
          keyboardType: TextInputType.number,
          focusNode: _productIdFocusNodes[index],
          errorText:
              _products[index]['selectedProduct'] == null &&
                      (_products[index]['productId'] as TextEditingController)
                          .text
                          .isNotEmpty
                  ? 'Invalid product ID'
                  : null,
        ),
        if (_productController.isLoading.value &&
            (_products[index]['productId'] as TextEditingController)
                .text
                .isNotEmpty)
          const Positioned(
            right: 10,
            top: 20,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _taxDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(
        () => DropdownButtonFormField<String>(
          initialValue: _selectedTax.value,
          decoration: InputDecoration(
            labelText: 'Tax Type *',
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items:
              _taxOptions.map((tax) {
                return DropdownMenuItem<String>(
                  value: tax,
                  child: Text(tax, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              _selectedTax.value = value;
            }
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productEntry(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productInputField(index),
        Obx(() {
          if (_products[index]['selectedProduct'] != null) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Product ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        if (_products.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeProduct(index),
                          ),
                      ],
                    ),
                    _customTextField(
                      'Product Name',
                      _products[index]['name'] as TextEditingController,
                      helperText: 'e.g., Medical Device',
                      readOnly:
                          (_products[index]['name'] as TextEditingController)
                              .text
                              .isNotEmpty,
                    ),
                    _customTextField(
                      'Description',
                      _products[index]['description'] as TextEditingController,
                      maxLines: 2,
                      helperText: 'e.g., Drum Color Blue, Capacity 5 Liter',
                      readOnly:
                          (_products[index]['description']
                                  as TextEditingController)
                              .text
                              .isNotEmpty,
                    ),
                    _customTextField(
                      'HSN Code',
                      _products[index]['hsn'] as TextEditingController,
                      helperText: 'e.g., 847330',
                      prefixIcon: Icons.code,
                      readOnly:
                          (_products[index]['hsn'] as TextEditingController)
                              .text
                              .isNotEmpty,
                    ),
                    _customTextField(
                      'Rate',
                      _products[index]['rate'] as TextEditingController,
                      keyboardType: TextInputType.number,
                      helperText: 'e.g., 46.00',
                      prefixIcon: Icons.currency_rupee,
                      readOnly:
                          (_products[index]['rate'] as TextEditingController)
                              .text
                              .isNotEmpty,
                    ),
                    _customTextField(
                      'Product Tax',
                      _products[index]['tax'] as TextEditingController,
                      helperText: 'e.g., 18%',
                      prefixIcon: Icons.percent,
                      readOnly:
                          (_products[index]['tax'] as TextEditingController)
                              .text
                              .isNotEmpty,
                    ),
                    _customTextField(
                      'Quantity',
                      _products[index]['quantity'] as TextEditingController,
                      keyboardType: TextInputType.number,
                      helperText: 'e.g., 300 NOs',
                      prefixIcon: Icons.numbers,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _totalPreview() {
    return Obx(() {
      final totals = _calculateTotal();
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1565C0)),
                  ),
                  Text(
                    '₹${totals['subtotal'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTax.value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  Text(
                    '₹${totals['taxAmount'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transportation Charge',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1565C0)),
                  ),
                  Text(
                    '₹${totals['transportCharge'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  Text(
                    '₹${totals['total'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (_showVendorList.value && _isTapOutside(details.globalPosition)) {
          setState(() {
            _showVendorList.value = false;
          });
        }
        if (_showProductList.value && _isTapOutside(details.globalPosition)) {
          setState(() {
            _showProductList.value = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(
          title: 'Create Delivery Challan',
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Form',
              onPressed: _clearForm,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addProduct,
          backgroundColor: const Color(0xFF1565C0),
          tooltip: 'Add Product',
          child: const Icon(Icons.add),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildFilterSection(),
                _sectionHeader('Vendor Details', Icons.person),
                _customTextField(
                  'Vendor ID',
                  _vendorIdCtrl,
                  helperText:
                      _vendorNameCtrl.text.isEmpty &&
                              _vendorIdCtrl.text.isNotEmpty &&
                              !_vendorIdCtrl.text.startsWith('GK')
                          ? 'Vendor ID must start with "GK"'
                          : _vendorNameCtrl.text.isEmpty &&
                              _vendorIdCtrl.text.length > 2
                          ? 'No vendor found'
                          : 'e.g., GK101',
                  prefixIcon: Icons.person_search,
                  isRequired: true,
                  keyboardType: TextInputType.text,
                  focusNode: _vendorIdFocusNode,
                  errorText:
                      _vendorNameCtrl.text.isEmpty &&
                              _vendorIdCtrl.text.isNotEmpty &&
                              !_vendorIdCtrl.text.startsWith('GK')
                          ? 'Invalid vendor ID (must start with GK)'
                          : _vendorNameCtrl.text.isEmpty &&
                              _vendorIdCtrl.text.length > 2
                          ? 'Invalid vendor ID'
                          : null,
                ),
                if (_showVendorList.value) const SizedBox(height: 570),
                Obx(() {
                  if (_showVendorDetails.value) {
                    return _buildVendorDetailsContainer();
                  }
                  return const SizedBox.shrink();
                }),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          'Delivery Challan Details',
                          Icons.description,
                        ),
                        _customTextField(
                          'PO Number',
                          _poNumberCtrl,
                          helperText: 'e.g., PO123',
                          prefixIcon: Icons.numbers,
                        ),
                        _customTextField(
                          'Created By',
                          _createdByCtrl,
                          prefixIcon: Icons.person,
                        ),
                      ],
                    ),
                  ),
                ),
                _sectionHeader('Product Details', Icons.inventory),
                _buildProductFilterSection(),
                if (_showProductList.value) const SizedBox(height: 370),
                Obx(() {
                  if (_productController.isLoading.value && _products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children:
                        _products
                            .asMap()
                            .entries
                            .map((entry) => _productEntry(entry.key))
                            .toList(),
                  );
                }),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          'Additional Charges',
                          Icons.attach_money,
                        ),
                        _customTextField(
                          'Transportation Charge',
                          _transportChargeCtrl,
                          keyboardType: TextInputType.number,
                          helperText: 'e.g., 800.00',
                          prefixIcon: Icons.currency_rupee,
                        ),
                        _taxDropdown(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _totalPreview(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateDeliveryChallan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child:
                      _isGenerating
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Generate Delivery Challan'),
                ),
              ],
            ),
            Obx(() {
              if (_showVendorList.value) {
                return Positioned(
                  top: 170,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 600,
                        maxWidth: 450,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Vendor',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _showVendorList.value = false,
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(child: _buildVendorList()),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Obx(() {
              if (_showProductList.value) {
                return Positioned(
                  key: _productCardKey,
                  top: 370,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 500,
                        maxWidth: 450,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Select Product',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: _buildProductList(_products.length - 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vendorIdCtrl.dispose();
    _vendorIdFocusNode.dispose();
    _vendorNameCtrl.dispose();
    _vendorAddressCtrl.dispose();
    _vendorAddressCtrlTwo.dispose();
    _vendorCityCtrl.dispose();
    _vendorPincodeCtrl.dispose();
    _vendorGSTCtrl.dispose();
    _vendorStateCtrl.dispose();
    _vendorContactCtrl.dispose();
    _vendorAccountsCtrl.dispose();
    _vendorEmailCtrl.dispose();
    _poNumberCtrl.dispose();
    _createdByCtrl.dispose();
    _transportChargeCtrl.dispose();
    _searchCtrl.dispose();
    _productSearchCtrl.dispose();
    _productIdFocusNodes.forEach((_, node) => node.dispose());
    for (var product in _products) {
      product.forEach((key, value) {
        if (value is TextEditingController) value.dispose();
      });
    }
    super.dispose();
  }
}

class DeliveryChallanService {
  static Future<void> generateDeliveryChallan({
    required String vendorName,
    required String vendorAddress,
    required String vendorGST,
    required String vendorState,
    String? vendorContact,
    String? vendorAccounts,
    String? vendorEmail,
    required String poNumber,
    required List<Map<String, dynamic>> products,
    required double transportCharge,
    required String selectedTax,
    required String createdBy,
  }) async {
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
  }
}
