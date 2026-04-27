import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import '../../Controllers/Product/Product.dart';
import '../../Models/product/getproduct_model.dart';
import '../Widgets/CustomAppBar.dart';
import '../../Utils/Colors.dart';
import '../ReportDesign/quotationView.dart';
import '../Widgets/CustomAlert.dart';

class _Constants {
  static const taxOptions = ['GST (5%)', 'IGST (18%)'];
  static const paymentOptions = [
    '30% Advance',
    '40% Advance',
    '50% Advance',
    '60% Advance',
    '80% Advance',
    'Custom',
  ];
  static const deliveryOptions = [
    '5 Days',
    '10 Days',
    '15 Days',
    '20 Days',
    'Custom',
  ];
  static const freightOptions = ['Included', 'Excluded'];
  static const validityOptions = [
    '15 Days',
    '30 Days',
    '45 Days',
    '60 Days',
    'Custom',
  ];
  static const warrantyOptions = [
    '1 Year',
    '2 Years',
    '3 Years',
    '5 Years',
    'Custom',
  ];
  static const bankOptions = ['Yes Bank', 'HDFC Bank'];
  static const bankDetails = {
    'Yes Bank':
        'Bank Name: Yes Bank\nA/C Number: 092463300000512\nIFSC: YESB0000924',
    'HDFC Bank':
        'Bank Name: HDFC Bank\nA/C Number: 50100392847562\nIFSC: HDFC0000123',
  };
  static const double spacing = 8.0;
  static const primaryColor = Color(0xFF1565C0);

  static InputDecoration inputDecoration(
    String label, {
    String? helperText,
    IconData? prefixIcon,
    bool isRequired = true,
  }) => InputDecoration(
    labelText: isRequired ? '$label *' : label,
    labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
    helperText: helperText,
    prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
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
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class AddQuotationScreen extends StatefulWidget {
  const AddQuotationScreen({super.key});

  @override
  State<AddQuotationScreen> createState() => _AddQuotationScreenState();
}

class _AddQuotationScreenState extends State<AddQuotationScreen> {
  final _buyerNameCtrl = TextEditingController();
  final _buyerAddressCtrl = TextEditingController();
  final _buyerGSTCtrl = TextEditingController();
  final _buyerStateCtrl = TextEditingController();
  final _buyerContactCtrl = TextEditingController();
  final _quotationNumberCtrl = TextEditingController(
    text: 'GK/NCP/${DateTime.now().year}/001',
  );
  final _products = <Map<String, dynamic>>[].obs;
  final _categories = <Map<String, dynamic>>[].obs;
  String _selectedTax = _Constants.taxOptions[1];
  bool _isGenerating = false;
  final _productController = Get.put(ProductController());
  final _customerController = Get.put(CustomerController());
  final _selectedState = ''.obs;
  final _selectedCity = ''.obs;
  String _selectedPayment = _Constants.paymentOptions[1];
  String _selectedDelivery = _Constants.deliveryOptions[2];
  String _selectedFreight = _Constants.freightOptions[1];
  String _selectedValidity = _Constants.validityOptions[1];
  String _selectedWarranty = _Constants.warrantyOptions[1];
  final _customPaymentCtrl = TextEditingController();
  final _customDeliveryCtrl = TextEditingController();
  final _customValidityCtrl = TextEditingController();
  final _customWarrantyCtrl = TextEditingController();
  String _selectedBank = _Constants.bankOptions[0];

  @override
  void initState() {
    super.initState();
    _addCategory();
    Future.delayed(Duration.zero, () async {
      await _productController.fetchProducts();
      await _customerController.fetchCustomers();
    });
  }

  void _addCategory() {
    _categories.add({'selectedCategory': ''.obs});
  }

  void _addProduct(GetProductModel product, String quantity) {
    _products.add({
      'name': TextEditingController(text: product.productName ?? ''),
      'hsn': TextEditingController(text: product.hsn ?? ''),
      'rate': TextEditingController(
        text: product.rate?.toStringAsFixed(2) ?? '',
      ),
      'description': TextEditingController(
        text: product.productCategory?.productCategory ?? '',
      ),
      'quantity': TextEditingController(text: quantity),
      'tax': TextEditingController(text: product.tax?.toString() ?? ''),
      'selectedProduct': product,
    });
  }

  List<String> get _allStates =>
      _customerController.customers
          .map((c) => c.state?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<String> get _allCities =>
      _customerController.customers
          .where(
            (c) =>
                _selectedState.value.isEmpty ||
                c.state?.toLowerCase() == _selectedState.value.toLowerCase(),
          )
          .map((c) => c.city?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<String> get _allCategories =>
      _productController.products
          .map((p) => p.productCategory?.productCategory?.trim() ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  void _removeCategory(int index) {
    _categories.removeAt(index);
  }

  void _removeProduct(int index) {
    _products[index].forEach(
      (key, value) => (value is TextEditingController) ? value.dispose() : null,
    );
    _products.removeAt(index);
  }

  void _clearForm() {
    for (var c in [
      _buyerNameCtrl,
      _buyerAddressCtrl,
      _buyerGSTCtrl,
      _buyerStateCtrl,
      _buyerContactCtrl,
    ]) {
      c.clear();
    }
    _quotationNumberCtrl.text = 'GK/NCP/${DateTime.now().year}/001';
    _selectedTax = _Constants.taxOptions[1];
    _selectedPayment = _Constants.paymentOptions[1];
    _selectedDelivery = _Constants.deliveryOptions[2];
    _selectedFreight = _Constants.freightOptions[1];
    _selectedValidity = _Constants.validityOptions[1];
    _selectedWarranty = _Constants.warrantyOptions[1];
    _customPaymentCtrl.clear();
    _customDeliveryCtrl.clear();
    _customValidityCtrl.clear();
    _customWarrantyCtrl.clear();
    _selectedBank = _Constants.bankOptions[0];
    _selectedState.value = '';
    _selectedCity.value = '';
    for (var p in _products) {
      p.forEach(
        (k, v) => (v is TextEditingController) ? v.dispose() : null,
      );
    }
    _products.clear();
    _categories.clear();
    _addCategory();
  }

  Map<String, dynamic> _calculateTotal() {
    double subtotal = 0.0;
    for (var product in _products) {
      final rate = double.tryParse(product['rate']!.text) ?? 0.0;
      final quantity = double.tryParse(product['quantity']!.text) ?? 0.0;
      subtotal += rate * quantity;
    }
    final taxRate = _selectedTax == 'GST (5%)' ? 0.05 : 0.18;
    return {
      'subtotal': subtotal,
      'taxAmount': subtotal * taxRate,
      'total': subtotal * (1 + taxRate),
    };
  }

  Future<void> _generateQuotation() async {
    for (var i = 0; i < _products.length; i++) {
      final p = _products[i];
      final fields = {
        'Name': p['name']!.text,
        'HSN Code': p['hsn']!.text,
        'Rate': p['rate']!.text,
        'Description': p['description']!.text,
        'Quantity': p['quantity']!.text,
      };
      for (var entry in fields.entries) {
        if (entry.value.isEmpty) {
          CustomAlert.error('Product ${i + 1}: ${entry.key} is required');
          return;
        }
      }
      final rate = double.tryParse(p['rate']!.text);
      final quantity = double.tryParse(p['quantity']!.text);
      if (rate == null) {
        CustomAlert.error('Product ${i + 1}: Invalid rate');
        return;
      }
      if (quantity == null || quantity <= 0) {
        CustomAlert.error('Product ${i + 1}: Quantity must be > 0');
        return;
      }
    }

    final requiredFields = {
      'Buyer Name': _buyerNameCtrl,
      'Buyer Address': _buyerAddressCtrl,
      'Buyer GSTIN/UIN': _buyerGSTCtrl,
      'Buyer State': _buyerStateCtrl,
      'Quotation Number': _quotationNumberCtrl,
    };
    for (var entry in requiredFields.entries) {
      if (entry.value.text.isEmpty) {
        CustomAlert.error('${entry.key} is required');
        return;
      }
    }

    final customFields = {
      if (_selectedPayment == 'Custom') 'Custom Payment': _customPaymentCtrl,
      if (_selectedDelivery == 'Custom') 'Custom Delivery': _customDeliveryCtrl,
      if (_selectedValidity == 'Custom') 'Custom Validity': _customValidityCtrl,
      if (_selectedWarranty == 'Custom') 'Custom Warranty': _customWarrantyCtrl,
    };
    for (var entry in customFields.entries) {
      if (entry.value.text.isEmpty) {
        CustomAlert.error('${entry.key} is required');
        return;
      }
    }

    if (!(await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Quotation'),
                content: const Text(
                  'Are you sure you want to generate this quotation?',
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
                      style: TextStyle(color: _Constants.primaryColor),
                    ),
                  ),
                ],
              ),
        ) ??
        false)) {
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final taxRate = _selectedTax == 'GST (5%)' ? 0.05 : 0.18;
      final taxLabel = _selectedTax == 'GST (5%)' ? 'GST @5%' : 'IGST PAYABLE';
      final products =
          _products
              .map(
                (p) => {
                  'name': p['name']!.text,
                  'description': p['description']!.text,
                  'hsn': p['hsn']!.text,
                  'quantity': p['quantity']!.text,
                  'rate': double.parse(p['rate']!.text),
                  'amount':
                      double.parse(p['rate']!.text) *
                      double.parse(p['quantity']!.text),
                },
              )
              .toList();
      final terms = [
        'Payment: ${_selectedPayment == 'Custom' ? _customPaymentCtrl.text : _selectedPayment}',
        'Delivery: ${_selectedDelivery == 'Custom' ? _customDeliveryCtrl.text : _selectedDelivery}',
        'Freight Charges: $_selectedFreight',
        'Validity: ${_selectedValidity == 'Custom' ? _customValidityCtrl.text : _selectedValidity}',
        taxLabel,
        'Warranty: ${_selectedWarranty == 'Custom' ? _customWarrantyCtrl.text : _selectedWarranty}',
        'Installation: Free of Cost',
        'AMC & CMC: Optional',
      ].join('\n');

      await QuotationService.generateQuotationFromProducts(
        products: products,
        buyerName: _buyerNameCtrl.text,
        buyerAddress: _buyerAddressCtrl.text,
        buyerGST: _buyerGSTCtrl.text,
        buyerState: _buyerStateCtrl.text,
        buyerContact:
            _buyerContactCtrl.text.isNotEmpty ? _buyerContactCtrl.text : null,
        quotationNumber: _quotationNumberCtrl.text,
        quotationDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        taxRate: taxRate,
        termsAndConditions: terms,
        bankDetails: _Constants.bankDetails[_selectedBank]!,
      );
      CustomAlert.success('Quotation generated successfully');
      _clearForm();
    } catch (e) {
      CustomAlert.error('Failed to generate quotation: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Widget _card({required Widget child, double elevation = 2}) => Card(
    elevation: elevation,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: _Constants.spacing),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: _Constants.spacing),
    child: Row(
      children: [
        Icon(icon, color: _Constants.primaryColor, size: 24),
        const SizedBox(width: _Constants.spacing),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _Constants.primaryColor,
          ),
        ),
      ],
    ),
  );

  Widget _customTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? helperText,
    IconData? prefixIcon,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: _Constants.spacing),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: _Constants.inputDecoration(
        label,
        helperText: helperText,
        prefixIcon: prefixIcon,
      ),
      onChanged: (_) => _products.refresh(),
    ),
  );

  Widget _dropdownField(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged, {
    String? helperText,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: _Constants.spacing),
    child: DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      decoration: _Constants.inputDecoration(label, helperText: helperText),
      items:
          options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              )
              .toList(),
      onChanged: onChanged,
    ),
  );

  Widget _categoryDropdown(int index, RxString selectedCategory) => Obx(
    () => Padding(
      padding: const EdgeInsets.symmetric(vertical: _Constants.spacing),
      child: DropdownButtonFormField<String>(
        initialValue:
            _allCategories.contains(selectedCategory.value)
                ? selectedCategory.value
                : null,
        decoration: _Constants.inputDecoration(
          'Category',
          helperText: 'Select a category',
          prefixIcon: Icons.category,
        ),
        items:
            _allCategories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category, style: const TextStyle(fontSize: 16)),
                  ),
                )
                .toList(),
        onChanged: (value) async {
          if (value != null && value.isNotEmpty) {
            selectedCategory.value = value;
            final selectedProducts = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductSelectionScreen(
                      category: value,
                      products:
                          _productController.products
                              .where(
                                (p) =>
                                    p.productCategory?.productCategory
                                        ?.toLowerCase() ==
                                    value.toLowerCase(),
                              )
                              .toList(),
                    ),
              ),
            );
            if (selectedProducts != null &&
                selectedProducts is List<Map<String, dynamic>>) {
              for (var product in selectedProducts) {
                _addProduct(product['product'], product['quantity']);
              }
            }
          }
        },
      ),
    ),
  );

  Widget _productEntry(int index) {
    final selectedCategory = _categories[index]['selectedCategory'] as RxString;
    return _card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _Constants.primaryColor,
                ),
              ),
              if (_categories.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _removeCategory(index),
                ),
            ],
          ),
          _categoryDropdown(index, selectedCategory),
        ],
      ),
    );
  }

  Widget _addedProductsList() => Obx(
    () =>
        _products.isEmpty
            ? const SizedBox.shrink()
            : _card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Added Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _Constants.primaryColor,
                    ),
                  ),
                  ..._products.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _Constants.spacing / 2,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value['name']!.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'HSN: ${entry.value['hsn']!.text} | Qty: ${entry.value['quantity']!.text} | Rate: ₹${entry.value['rate']!.text}',
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeProduct(entry.key),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _Constants.primaryColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );

  Widget _amountRow(String label, double amount, {bool isBold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: _Constants.primaryColor,
          fontWeight: isBold ? FontWeight.bold : null,
        ),
      ),
      Text(
        '₹${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          color: _Constants.primaryColor,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _totalPreview() => Obx(() {
    final totals = _calculateTotal();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _amountRow('Subtotal', totals['subtotal']),
          const SizedBox(height: _Constants.spacing),
          _amountRow(_selectedTax, totals['taxAmount']),
          const Divider(height: 16),
          _amountRow('Total', totals['total'], isBold: true),
        ],
      ),
    );
  });

  Widget _customerList() => Obx(() {
    if (_selectedState.value.isEmpty && _selectedCity.value.isEmpty) {
      return const SizedBox.shrink();
    }
    final customers =
        _customerController.customers
            .where(
              (c) =>
                  (_selectedState.value.isEmpty ||
                      c.state?.toLowerCase() ==
                          _selectedState.value.toLowerCase()) &&
                  (_selectedCity.value.isEmpty ||
                      c.city?.toLowerCase() ==
                          _selectedCity.value.toLowerCase()),
            )
            .toList();
    if (customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: _Constants.spacing),
        child: Text(
          'No customers found for the selected filters.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Filtered Customers', Icons.group),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final c = customers[index];
            return _card(
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  c.customerName ?? 'Unnamed Customer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _Constants.primaryColor,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unique ID: ${c.customerQuniqueNumber ?? '-'}'),
                    Text('Address: ${c.addressOne ?? '-'}'),
                    Text('GSTIN: ${c.customerGSTIN ?? '-'}'),
                    Text('Contact: ${c.customerPhone ?? '-'}'),
                    Text('State: ${c.state ?? '-'}, City: ${c.city ?? '-'}'),
                  ],
                ),
                onTap: () {
                  _buyerNameCtrl.text = c.customerName ?? '';
                  _buyerAddressCtrl.text = c.addressOne ?? '';
                  _buyerGSTCtrl.text = c.customerGSTIN ?? '';
                  _buyerStateCtrl.text = c.state ?? '';
                  _buyerContactCtrl.text = c.customerPhone ?? '';
                  _selectedState.value = '';
                  _selectedCity.value = '';
                  setState(() {});
                },
              ),
            );
          },
        ),
      ],
    );
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: CustomAppBar(
      title: 'Create Quotation',
      actions: [
        IconButton(
          icon: const Icon(Icons.clear_all, color: AppColors.primaryBlue),
          tooltip: 'Clear Form',
          onPressed: _clearForm,
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addCategory,
      backgroundColor: _Constants.primaryColor,
      tooltip: 'Add Category',
      child: const Icon(Icons.add),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Obx(
            () => _dropdownField(
              'Select State',
              _allStates.contains(_selectedState.value)
                  ? _selectedState.value
                  : null,
              _allStates,
              (value) {
                _selectedState.value = value ?? '';
                _selectedCity.value = '';
                _buyerNameCtrl.clear();
                _buyerAddressCtrl.clear();
                _buyerGSTCtrl.clear();
                _buyerStateCtrl.clear();
                _buyerContactCtrl.clear();
                setState(() {});
              },
            ),
          ),
          Obx(
            () => _dropdownField(
              'Select City',
              _allCities.contains(_selectedCity.value)
                  ? _selectedCity.value
                  : null,
              _allCities,
              (value) {
                _selectedCity.value = value ?? '';
                _buyerNameCtrl.clear();
                _buyerAddressCtrl.clear();
                _buyerGSTCtrl.clear();
                _buyerStateCtrl.clear();
                _buyerContactCtrl.clear();
                setState(() {});
              },
            ),
          ),
          _customerList(),
          _sectionHeader('Buyer Details', Icons.person),
          _card(
            child: Column(
              children: [
                _infoRow('Name', _buyerNameCtrl.text),
                const Divider(),
                _infoRow('Address', _buyerAddressCtrl.text),
                const Divider(),
                _infoRow('Contact', _buyerContactCtrl.text),
                const Divider(),
                _infoRow('GSTIN/UIN', _buyerGSTCtrl.text),
                const Divider(),
                _infoRow('State', _buyerStateCtrl.text),
              ],
            ),
          ),
          _sectionHeader('Quotation Details', Icons.description),
          _customTextField(
            'Quotation Number',
            _quotationNumberCtrl,
            helperText: 'e.g., GK/NCP/2025/001',
            prefixIcon: Icons.numbers,
          ),
          _sectionHeader('Product Details', Icons.inventory),
          Obx(
            () =>
                _productController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children:
                          _categories
                              .asMap()
                              .entries
                              .map((e) => _productEntry(e.key))
                              .toList(),
                    ),
          ),
          _addedProductsList(),
          _sectionHeader('Terms & Conditions', Icons.description),
          _dropdownField(
            'Payment',
            _selectedPayment,
            _Constants.paymentOptions,
            (v) => setState(() => _selectedPayment = v!),
            helperText: 'Select payment terms',
          ),
          if (_selectedPayment == 'Custom')
            _customTextField(
              'Custom Payment',
              _customPaymentCtrl,
              helperText: 'e.g., 70% Advance',
            ),
          _dropdownField(
            'Delivery',
            _selectedDelivery,
            _Constants.deliveryOptions,
            (v) => setState(() => _selectedDelivery = v!),
            helperText: 'Select delivery terms',
          ),
          if (_selectedDelivery == 'Custom')
            _customTextField(
              'Custom Delivery',
              _customDeliveryCtrl,
              helperText: 'e.g., 25 Days',
            ),
          _dropdownField(
            'Freight Charges',
            _selectedFreight,
            _Constants.freightOptions,
            (v) => setState(() => _selectedFreight = v!),
            helperText: 'Select freight charges',
          ),
          _dropdownField(
            'Validity',
            _selectedValidity,
            _Constants.validityOptions,
            (v) => setState(() => _selectedValidity = v!),
            helperText: 'Select validity period',
          ),
          if (_selectedValidity == 'Custom')
            _customTextField(
              'Custom Validity',
              _customValidityCtrl,
              helperText: 'e.g., 90 Days',
            ),
          _dropdownField(
            'Warranty',
            _selectedWarranty,
            _Constants.warrantyOptions,
            (v) => setState(() => _selectedWarranty = v!),
            helperText: 'Select warranty period',
          ),
          if (_selectedWarranty == 'Custom')
            _customTextField(
              'Custom Warranty',
              _customWarrantyCtrl,
              helperText: 'e.g., 4 Years',
            ),
          _sectionHeader('Bank Details', Icons.account_balance),
          _dropdownField(
            'Select Bank',
            _selectedBank,
            _Constants.bankOptions,
            (v) => setState(() => _selectedBank = v!),
            helperText: 'Select bank for payment',
          ),
          const SizedBox(height: _Constants.spacing * 2.5),
          _dropdownField(
            'Tax Type',
            _selectedTax,
            _Constants.taxOptions,
            (v) => setState(() => _selectedTax = v!),
          ),
          const SizedBox(height: _Constants.spacing * 3.75),
          _totalPreview(),
          const SizedBox(height: _Constants.spacing * 3.75),
          ElevatedButton(
            onPressed: _isGenerating ? null : _generateQuotation,
            style: ElevatedButton.styleFrom(
              backgroundColor: _Constants.primaryColor,
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
                    : const Text('Generate Quotation'),
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    for (var c in [
      _buyerNameCtrl,
      _buyerAddressCtrl,
      _buyerGSTCtrl,
      _buyerStateCtrl,
      _buyerContactCtrl,
      _quotationNumberCtrl,
      _customPaymentCtrl,
      _customDeliveryCtrl,
      _customValidityCtrl,
      _customWarrantyCtrl,
    ]) {
      c.dispose();
    }
    for (var p in _products) {
      p.forEach(
        (k, v) => (v is TextEditingController) ? v.dispose() : null,
      );
    }
    super.dispose();
  }
}

class ProductSelectionScreen extends StatefulWidget {
  final String category;
  final List<GetProductModel> products;

  const ProductSelectionScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final _selectedProducts = <Map<String, dynamic>>[].obs;

  void _addToSelected(GetProductModel product, String quantity) {
    final existingIndex = _selectedProducts.indexWhere(
      (p) => p['product'] == product,
    );
    if (existingIndex != -1) {
      _selectedProducts[existingIndex]['quantity'] = quantity;
    } else {
      _selectedProducts.add({'product': product, 'quantity': quantity});
    }
  }

  void _removeSelected(int index) {
    _selectedProducts.removeAt(index);
  }

  Widget _card({required Widget child, double elevation = 2}) => Card(
    elevation: elevation,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: _Constants.spacing),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: _Constants.spacing),
    child: Row(
      children: [
        Icon(icon, color: _Constants.primaryColor, size: 24),
        const SizedBox(width: _Constants.spacing),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _Constants.primaryColor,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Products - ${widget.category}',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _sectionHeader('Available Products', Icons.inventory),
                  if (widget.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _Constants.spacing,
                      ),
                      child: Text(
                        'No products found for this category.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  else
                    ...widget.products.map((product) {
                      final quantityCtrl = TextEditingController(text: '1');
                      return _card(
                        elevation: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName ?? 'Unnamed',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Rate: ₹${product.rate?.toStringAsFixed(2) ?? '0.00'}',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: quantityCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _Constants.inputDecoration(
                                  'Qty',
                                  helperText: 'e.g., 1',
                                  prefixIcon: Icons.numbers,
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) quantityCtrl.text = '1';
                                },
                              ),
                            ),
                            const SizedBox(width: _Constants.spacing),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                final qty =
                                    (double.tryParse(quantityCtrl.text) ??
                                        1.0) -
                                    1;
                                if (qty >= 1) {
                                  quantityCtrl.text = qty.toString();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: _Constants.primaryColor,
                              ),
                              onPressed: () {
                                final qty =
                                    (double.tryParse(quantityCtrl.text) ??
                                        1.0) +
                                    1;
                                quantityCtrl.text = qty.toString();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: _Constants.primaryColor,
                              ),
                              onPressed: () {
                                final qty =
                                    double.tryParse(quantityCtrl.text) ?? 1.0;
                                if (qty <= 0) {
                                  CustomAlert.error('Quantity must be > 0');
                                  return;
                                }
                                _addToSelected(product, qty.toString());
                                quantityCtrl.text = '1';
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  _sectionHeader('Selected Products', Icons.check_circle),
                  Obx(
                    () =>
                        _selectedProducts.isEmpty
                            ? const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: _Constants.spacing,
                              ),
                              child: Text(
                                'No products selected.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : _card(
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    _selectedProducts.asMap().entries.map((
                                      entry,
                                    ) {
                                      final product =
                                          entry.value['product']
                                              as GetProductModel;
                                      final quantity =
                                          entry.value['quantity'] as String;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: _Constants.spacing / 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.productName ??
                                                        'Unnamed',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rate: ₹${product.rate?.toStringAsFixed(2) ?? '0.00'} | Qty: $quantity',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed:
                                                  () => _removeSelected(
                                                    entry.key,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedProducts.toList());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _Constants.primaryColor,
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
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var product in _selectedProducts) {
      product['quantityCtrl']?.dispose();
    }
    super.dispose();
  }
}
