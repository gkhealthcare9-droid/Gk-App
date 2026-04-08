import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import '../../Controllers/Product/Product.dart';
import '../../Models/product/getproduct_model.dart';
import '../ReportDesign/quotationView.dart';

class ServiceQuotationScreen extends StatefulWidget {
  final String reportNumber;
  final String customerCode;
  final String? phoneNumber;


  const ServiceQuotationScreen({super.key, required this.reportNumber, required this.customerCode,  this.phoneNumber,});

  @override
  State<ServiceQuotationScreen> createState() => _ServiceQuotationScreenState();
}

class _ServiceQuotationScreenState extends State<ServiceQuotationScreen> {
  final TextEditingController _buyerNameCtrl = TextEditingController();
  final TextEditingController _buyerAddressCtrl = TextEditingController();
  final TextEditingController _buyerGSTCtrl = TextEditingController();
  final TextEditingController _buyerStateCtrl = TextEditingController();
  final TextEditingController _quotationNumberCtrl =
  TextEditingController(text: 'GK/NCP/${DateTime.now().year}/001');
  final RxList<Map<String, dynamic>> _products = <Map<String, dynamic>>[].obs;
  String _selectedTax = 'IGST (18%)';
  final List<String> _taxOptions = ['GST (5%)', 'IGST (18%)'];
  bool _isGenerating = false;
  final ProductController _productController = Get.put(ProductController());
  final CustomerController _customerController = Get.put(CustomerController());

  // Terms & Conditions state variables
  String _selectedPayment = '40% Advance';
  String _selectedDelivery = '15 Days';
  String _selectedFreight = 'Excluded';
  String _selectedValidity = '30 Days';
  String _selectedWarranty = '2 Years';

  final List<String> _paymentOptions = ['30% Advance', '40% Advance', '50% Advance', '60% Advance', '80% Advance', 'Custom'];
  final List<String> _deliveryOptions = ['5 Days', '10 Days', '15 Days', '20 Days', 'Custom'];
  final List<String> _freightOptions = ['Included', 'Excluded'];
  final List<String> _validityOptions = ['15 Days', '30 Days', '45 Days', '60 Days', 'Custom'];
  final List<String> _warrantyOptions = ['1 Year', '2 Years', '3 Years', '5 Years', 'Custom'];

  final TextEditingController _customPaymentCtrl = TextEditingController();
  final TextEditingController _customDeliveryCtrl = TextEditingController();
  final TextEditingController _customValidityCtrl = TextEditingController();
  final TextEditingController _customWarrantyCtrl = TextEditingController();

  // Bank Details state variables
  String _selectedBank = 'Yes Bank';
  final List<String> _bankOptions = ['Yes Bank', 'HDFC Bank'];
  final Map<String, String> _bankDetails = {
    'Yes Bank': 'Bank Name: Yes Bank\nA/C Number: 092463300000512\nIFSC: YESB0000924',
    'HDFC Bank': 'Bank Name: HDFC Bank\nA/C Number: 50100392847562\nIFSC: HDFC0000123',
  };

  @override
  void initState() {
    super.initState();
    _addProduct();
    Future.delayed(Duration.zero, () async {
      await _productController.fetchProducts();
      await fetchHospital(widget.customerCode);
    });
  }

  Future<void> fetchHospital(String unique) async {
    await _customerController.fetchCustomerByUnique(unique.toUpperCase());

    setState(() {
      _buyerNameCtrl.text = _customerController.customer.value.customerName ?? '';
      _buyerAddressCtrl.text = _customerController.customer.value.addressOne ?? '';
      _buyerGSTCtrl.text = _customerController.customer.value.customerGSTIN ?? '';
      _buyerStateCtrl.text = _customerController.customer.value.state ?? '';
    });

    if (_customerController.customer.value.id != null) {
      await _customerController.fetchEmployees(_customerController.customer.value.id!);
      await _productController.fetchCustomerProducts(_customerController.customer.value.id!);
    }
  }

  void _addProduct() {
    _products.add({
      'name': TextEditingController(),
      'hsn': TextEditingController(),
      'rate': TextEditingController(),
      'description': TextEditingController(),
      'quantity': TextEditingController(text: '1'),
      'tax': TextEditingController(),
      'selectedProduct': null,
    });
  }

  void _removeProduct(int index) {
    _products[index].forEach((key, value) {
      if (value is TextEditingController) value.dispose();
    });
    _products.removeAt(index);
  }

  void _clearForm() {
    _buyerNameCtrl.clear();
    _buyerAddressCtrl.clear();
    _buyerGSTCtrl.clear();
    _buyerStateCtrl.clear();
    _quotationNumberCtrl.text = 'GK/NCP/${DateTime.now().year}/001';
    _selectedTax = 'IGST (18%)';
    for (var product in _products) {
      product.forEach((key, value) {
        if (value is TextEditingController) value.dispose();
      });
    }
    _products.clear();
    _addProduct();
    // Clear Terms & Conditions and Bank Details
    setState(() {
      _selectedPayment = '40% Advance';
      _selectedDelivery = '15 Days';
      _selectedFreight = 'Excluded';
      _selectedValidity = '30 Days';
      _selectedWarranty = '2 Years';
      _customPaymentCtrl.clear();
      _customDeliveryCtrl.clear();
      _customValidityCtrl.clear();
      _customWarrantyCtrl.clear();
      _selectedBank = 'Yes Bank';
    });
  }

  Map<String, dynamic> _calculateTotal() {
    double subtotal = 0.0;
    for (var product in _products) {
      final rate = double.tryParse(product['rate']!.text) ?? 0.0;
      final quantity = double.tryParse(product['quantity']!.text) ?? 0.0;
      subtotal += rate * quantity;
    }
    final taxRate = _selectedTax == 'GST (5%)' ? 0.05 : 0.18;
    final taxAmount = subtotal * taxRate;
    return {
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'total': subtotal + taxAmount,
    };
  }

  Future<void> _generateQuotation() async {
    // Validate inputs
    for (var i = 0; i < _products.length; i++) {
      final product = _products[i];
      if (product['name']!.text.isEmpty) {
        Get.snackbar("Error", "Product ${i + 1}: Name is required", backgroundColor: Colors.redAccent);
        return;
      }
      if (product['hsn']!.text.isEmpty) {
        Get.snackbar("Error", "Product ${i + 1}: HSN Code is required", backgroundColor: Colors.redAccent);
        return;
      }
      if (product['rate']!.text.isEmpty) {
        Get.snackbar("Error", "Product ${i + 1}: Rate is required", backgroundColor: Colors.redAccent);
        return;
      }
      if (product['description']!.text.isEmpty) {
        Get.snackbar("Error", "Product ${i + 1}: Description is required", backgroundColor: Colors.redAccent);
        return;
      }
      if (product['quantity']!.text.isEmpty) {
        Get.snackbar("Error", "Product ${i + 1}: Quantity is required", backgroundColor: Colors.redAccent);
        return;
      }
      final double? rate = double.tryParse(product['rate']!.text);
      final double? quantity = double.tryParse(product['quantity']!.text);
      if (rate == null) {
        Get.snackbar("Error", "Product ${i + 1}: Invalid rate", backgroundColor: Colors.redAccent);
        return;
      }
      if (quantity == null || quantity <= 0) {
        Get.snackbar("Error", "Product ${i + 1}: Quantity must be greater than 0", backgroundColor: Colors.redAccent);
        return;
      }
    }

    if (_buyerNameCtrl.text.isEmpty) {
      Get.snackbar("Error", "Buyer Name is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_buyerAddressCtrl.text.isEmpty) {
      Get.snackbar("Error", "Buyer Address is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_buyerGSTCtrl.text.isEmpty) {
      Get.snackbar("Error", "Buyer GSTIN/UIN is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_buyerStateCtrl.text.isEmpty) {
      Get.snackbar("Error", "Buyer State Name is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_quotationNumberCtrl.text.isEmpty) {
      Get.snackbar("Error", "Quotation Number is required", backgroundColor: Colors.redAccent);
      return;
    }

    // Validate custom fields in Terms & Conditions
    if (_selectedPayment == 'Custom' && _customPaymentCtrl.text.isEmpty) {
      Get.snackbar("Error", "Custom Payment value is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_selectedDelivery == 'Custom' && _customDeliveryCtrl.text.isEmpty) {
      Get.snackbar("Error", "Custom Delivery value is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_selectedValidity == 'Custom' && _customValidityCtrl.text.isEmpty) {
      Get.snackbar("Error", "Custom Validity value is required", backgroundColor: Colors.redAccent);
      return;
    }
    if (_selectedWarranty == 'Custom' && _customWarrantyCtrl.text.isEmpty) {
      Get.snackbar("Error", "Custom Warranty value is required", backgroundColor: Colors.redAccent);
      return;
    }

    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Quotation'),
        content: const Text('Are you sure you want to generate this quotation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate', style: TextStyle(color: Color(0xFF1565C0))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isGenerating = true);

    // Calculate tax rate and taxLabel
    final taxRate = _selectedTax == 'GST (5%)' ? 0.05 : 0.18;
    final taxLabel = _selectedTax == 'GST (5%)' ? 'GST @5%' : 'IGST PAYABLE';

    // Prepare products list
    final products = _products.map((product) {
      final rate = double.parse(product['rate']!.text);
      final quantity = double.parse(product['quantity']!.text);
      final amount = rate * quantity;
      return {
        'name': product['name']!.text,
        'description': product['description']!.text,
        'hsn': product['hsn']!.text,
        'quantity': quantity.toString(),
        'rate': rate,
        'amount': amount,
      };
    }).toList();

    // Get Terms & Conditions and Bank Details
    final payment = _selectedPayment == 'Custom' ? _customPaymentCtrl.text : _selectedPayment;
    final delivery = _selectedDelivery == 'Custom' ? _customDeliveryCtrl.text : _selectedDelivery;
    final freight = _selectedFreight;
    final validity = _selectedValidity == 'Custom' ? _customValidityCtrl.text : _selectedValidity;
    final warranty = _selectedWarranty == 'Custom' ? _customWarrantyCtrl.text : _selectedWarranty;
    final termsAndConditions = 'Payment: $payment\nDelivery: $delivery\nFreight Charges: $freight\nValidity: $validity\n$taxLabel\nWarranty: $warranty\nInstallation: Free of Cost\nAMC & CMC: Optional';
    final bankDetails = _bankDetails[_selectedBank]!;

    // Generate quotation
    try {
      await QuotationService.generateQuotationFromProducts(
        products: products,
        buyerName: _buyerNameCtrl.text,
        buyerAddress: _buyerAddressCtrl.text,
        buyerGST: _buyerGSTCtrl.text,
        buyerState: _buyerStateCtrl.text,
        quotationNumber: _quotationNumberCtrl.text,
        quotationDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        taxRate: taxRate,
        termsAndConditions: termsAndConditions,
        bankDetails: bankDetails,
        buyerContact: widget.phoneNumber ?? '', // add this line

      );
      Get.snackbar("Success", "Quotation generated successfully", backgroundColor: Colors.green);
      _clearForm();
    } catch (e) {
      Get.snackbar("Error", "Failed to generate quotation: $e", backgroundColor: Colors.redAccent);
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
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
          helperText: helperText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => _products.refresh(),
      ),
    );
  }

  Widget _dropdownField(String label, String value, List<String> options, Function(String?) onChanged, {String? helperText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
          helperText: helperText,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _productDropdown(int index) {
    return Obx(() {
      final products = _productController.products;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<GetProductModel>(
          initialValue: _products[index]['selectedProduct'],
          decoration: InputDecoration(
            labelText: 'Product Name *',
            labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
            helperText: 'Select a product',
            prefixIcon: const Icon(Icons.label, color: Colors.grey),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: products.map((product) {
            return DropdownMenuItem<GetProductModel>(
              value: product,
              child: Text(product.productName ?? 'Unnamed', style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: (value) {
            _products[index]['selectedProduct'] = value;
            _products[index]['name']!.text = value?.productName ?? '';
            _products[index]['hsn']!.text = value?.hsn ?? '';
            _products[index]['rate']!.text = value?.rate?.toStringAsFixed(2) ?? '';
            _products[index]['tax']!.text = value?.tax?.toString() ?? '';
            _products[index]['description']!.text = value?.productCategory?.productCategory ?? '';
            _products.refresh();
          },
        ),
      );
    });
  }

  Widget _taxDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTax,
        decoration: InputDecoration(
          labelText: 'Tax Type *',
          labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: _taxOptions.map((tax) {
          return DropdownMenuItem<String>(
            value: tax,
            child: Text(tax, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTax = value!;
          });
        },
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
    return Card(
      elevation: 4,
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
                Text(
                  'Product ${index + 1}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                ),
                if (_products.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeProduct(index),
                  ),
              ],
            ),
            _productDropdown(index),
            _customTextField(
              "Description",
              _products[index]['description']!,
              maxLines: 2,
              helperText: "e.g., High-quality medical device",
            ),
            _customTextField(
              "HSN Code",
              _products[index]['hsn']!,
              helperText: "e.g., 9018",
              prefixIcon: Icons.code,
              readOnly: true,
            ),
            _customTextField(
              "Quantity",
              _products[index]['quantity']!,
              keyboardType: TextInputType.number,
              helperText: "e.g., 1",
              prefixIcon: Icons.numbers,
            ),
            _customTextField(
              "Rate",
              _products[index]['rate']!,
              keyboardType: TextInputType.number,
              helperText: "e.g., 1000.00",
              prefixIcon: Icons.currency_rupee,
              readOnly: true,
            ),
            _customTextField(
              "Product Tax",
              _products[index]['tax']!,
              helperText: "Tax rate from product",
              prefixIcon: Icons.percent,
              readOnly: true,
            ),
          ],
        ),
      ),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTax,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF1565C0)),
                  ),
                  Text(
                    '₹${totals['taxAmount'].toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                  Text(
                    '₹${totals['total'].toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _termsAndConditionsSection() {
    return Column(
      children: [
        _sectionHeader("Terms & Conditions", Icons.description),
        _dropdownField(
          "Payment *",
          _selectedPayment,
          _paymentOptions,
              (value) => setState(() => _selectedPayment = value!),
          helperText: "Select payment terms",
        ),
        if (_selectedPayment == 'Custom')
          _customTextField(
            "Custom Payment",
            _customPaymentCtrl,
            helperText: "e.g., 70% Advance",
          ),
        _dropdownField(
          "Delivery *",
          _selectedDelivery,
          _deliveryOptions,
              (value) => setState(() => _selectedDelivery = value!),
          helperText: "Select delivery terms",
        ),
        if (_selectedDelivery == 'Custom')
          _customTextField(
            "Custom Delivery",
            _customDeliveryCtrl,
            helperText: "e.g., 25 Days",
          ),
        _dropdownField(
          "Freight Charges *",
          _selectedFreight,
          _freightOptions,
              (value) => setState(() => _selectedFreight = value!),
          helperText: "Select freight charges",
        ),
        _dropdownField(
          "Validity *",
          _selectedValidity,
          _validityOptions,
              (value) => setState(() => _selectedValidity = value!),
          helperText: "Select validity period",
        ),
        if (_selectedValidity == 'Custom')
          _customTextField(
            "Custom Validity",
            _customValidityCtrl,
            helperText: "e.g., 90 Days",
          ),
        _dropdownField(
          "Warranty *",
          _selectedWarranty,
          _warrantyOptions,
              (value) => setState(() => _selectedWarranty = value!),
          helperText: "Select warranty period",
        ),
        if (_selectedWarranty == 'Custom')
          _customTextField(
            "Custom Warranty",
            _customWarrantyCtrl,
            helperText: "e.g., 4 Years",
          ),
      ],
    );
  }

  Widget _bankDetailsSection() {
    return Column(
      children: [
        _sectionHeader("Bank Details", Icons.account_balance),
        _dropdownField(
          "Select Bank *",
          _selectedBank,
          _bankOptions,
              (value) => setState(() => _selectedBank = value!),
          helperText: "Select bank for payment",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Create Quotation"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _sectionHeader("Product Details", Icons.inventory),
            Obx(() {
              if (_productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: _products.asMap().entries.map((entry) => _productEntry(entry.key)).toList(),
              );
            }),
            const SizedBox(height: 20),
            _sectionHeader("Buyer Details", Icons.person),
            _customTextField(
              "Buyer Name",
              _buyerNameCtrl,
              helperText: "e.g., ABC Hospital",
              prefixIcon: Icons.person_outline,
            ),
            _customTextField(
              "Buyer Address",
              _buyerAddressCtrl,
              maxLines: 3,
              helperText: "e.g., 123 Main St, City",
              prefixIcon: Icons.location_on,
            ),
            _customTextField(
              "Buyer Phone Number",
              TextEditingController(text: widget.phoneNumber ?? ''),
              readOnly: true,
              prefixIcon: Icons.phone,
              isRequired: false,
            ),


            _customTextField(
              "Buyer GSTIN/UIN",
              _buyerGSTCtrl,
              helperText: "e.g., 29ALZPC8787G1Z3",
              prefixIcon: Icons.receipt,
            ),
            _customTextField(
              "Buyer State Name",
              _buyerStateCtrl,
              helperText: "e.g., Karnataka",
              prefixIcon: Icons.map,
            ),
            _sectionHeader("Quotation Details", Icons.description),
            _customTextField(
              "Quotation Number",
              _quotationNumberCtrl,
              helperText: "e.g., GK/NCP/2025/001",
              prefixIcon: Icons.numbers,
            ),
            _termsAndConditionsSection(),
            _bankDetailsSection(),

            const SizedBox(height: 20),
            _taxDropdown(),
            const SizedBox(height: 30),
            _totalPreview(),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateQuotation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: _isGenerating
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Generate Quotation"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _buyerNameCtrl.dispose();
    _buyerAddressCtrl.dispose();
    _buyerGSTCtrl.dispose();
    _buyerStateCtrl.dispose();
    _quotationNumberCtrl.dispose();
    _customPaymentCtrl.dispose();
    _customDeliveryCtrl.dispose();
    _customValidityCtrl.dispose();
    _customWarrantyCtrl.dispose();
    for (var product in _products) {
      product.forEach((key, value) {
        if (value is TextEditingController) value.dispose();
      });
    }
    super.dispose();
  }
}