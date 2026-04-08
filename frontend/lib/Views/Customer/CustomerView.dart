import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';
// Import CustomerProduct
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';

import '../../Helpers/Helpers.dart';
import 'AddCustomer.dart';
import 'AddEmployee.dart';
import 'Addcustomer_product.dart';
import 'EditCustomerProductScreen.dart';
import 'EditEmployee.dart';

class CustomerView extends StatefulWidget {
  final CustomerModel customer;

  const CustomerView({super.key, required this.customer});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  final CustomerController _customerController = Get.put(CustomerController());
  final ProductController _productController = Get.put(ProductController());
  final Helpers _helpers = Helpers();

  String? _userType;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _userType = prefs.getString('userType');
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerController.fetchEmployees(widget.customer.id!);
      _productController.fetchCustomerProducts(widget.customer.id!);
    });
  }

  Future<void> _onAddProductPressed() async {
    await Get.to(() => AddCustomerProductScreen(id: widget.customer.id!));
    await _productController.fetchCustomerProducts(widget.customer.id!);
  }

  Future<void> _refresh() async {
    await _customerController.fetchEmployees(widget.customer.id!);
    await _productController.fetchCustomerProducts(widget.customer.id!);
  }

  Future<void> _openWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      Get.snackbar('Error', 'No phone number provided');
      return;
    }
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 10) {
      digitsOnly = '91$digitsOnly';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      // OK
    } else if (digitsOnly.length < 10) {
      Get.snackbar('Error', 'Invalid phone number format.');
      return;
    }
    final whatsappUrl = Uri.parse(
      'https://api.whatsapp.com/send?phone=$digitsOnly',
    );
    try {
      bool launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      try {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      } catch (e) {
        Get.snackbar('Error', 'Could not open WhatsApp or browser.');
      }
    }
  }

  void _showDeleteCustomerDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Customer?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              _customerController.deleteCustomer(widget.customer.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showDeleteEmployeeDialog(String employeeId, String employeeName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Employee?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "$employeeName"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              _customerController
                  .deleteEmployee(employeeId, widget.customer.id!)
                  .then((_) {
                    _customerController.fetchEmployees(widget.customer.id!);
                  });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      Get.snackbar('Error', 'No phone number provided');
      return;
    }
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
      Get.snackbar('Error', 'Invalid phone number format');
      return;
    }
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar('Error', 'Unable to make phone call');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate call: $e');
    }
  }

  Future<void> _pickEmployees(String id) async {
    final updated = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(builder: (_) => AddEmployeeScreen(id: id)),
    );
    if (updated != null) {
      print('Updated employees: $updated');
    }
  }

  void _showAddOutstandingPopup(String customerId) {
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController invoiceCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    final RxString selectedType = 'credit'.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.9,
                minHeight: 100,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add Customer Outstanding",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            Icons.email,
                            "Email",
                            widget.customer.customerEmail ?? "N/A",
                          ),
                          const SizedBox(height: 4),
                          _infoRow(
                            Icons.location_city,
                            "City",
                            widget.customer.city ?? "N/A",
                          ),
                          const SizedBox(height: 4),
                          _infoRow(
                            Icons.map,
                            "State",
                            widget.customer.state ?? "N/A",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    // Input Fields
                    _customTextField(
                      controller: amountCtrl,
                      label: "Amount",
                      icon: Icons.currency_rupee,
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: selectedType.value,
                        decoration: _inputDecoration("Type", Icons.swap_vert),
                        items:
                            ['credit', 'debit']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.toUpperCase()),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => selectedType.value = val!,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _customTextField(
                      controller: invoiceCtrl,
                      label: "Invoice Number",
                      icon: Icons.receipt,
                    ),
                    const SizedBox(height: 12),
                    _customTextField(
                      controller: descCtrl,
                      label: "Description",
                      icon: Icons.notes,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Add"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final int? amount = int.tryParse(
                              amountCtrl.text.trim(),
                            );
                            if (amount == null ||
                                invoiceCtrl.text.isEmpty ||
                                descCtrl.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please fill all fields correctly',
                              );
                              return;
                            }

                            _customerController
                                .addOutstaning(
                                  customerId,
                                  amount,
                                  selectedType.value,
                                  invoiceCtrl.text,
                                  descCtrl.text,
                                )
                                .then((_) => Get.back());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.teal),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Future<void> _shareCustomerDetails() async {
    final c = widget.customer;
    final pdf = pw.Document();

    // Compute address string
    final addressParts = [
      c.addressOne,
      c.addressTwo,
      c.city,
      c.state,
      c.pincode,
    ].where((s) => s != null && s.isNotEmpty).join(', ');
    final address = addressParts.isEmpty ? 'Not Available' : addressParts;

    // Create PDF content
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Customer Details',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Name: ${c.customerName ?? 'Not Available'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Phone: ${c.customerPhone ?? 'Not Available'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Email: ${c.customerEmail ?? 'Not Available'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Company: ${c.customerCompany ?? 'Not Available'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'GSTIN: ${c.customerGSTIN ?? 'Not Available'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Customer ID: ${c.customerQuniqueNumber ?? 'Not Available'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Address: $address',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This is an auto-generated document. Please do not modify.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
      ),
    );

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'customer_${c.customerQuniqueNumber ?? 'details'}.pdf',
      );
    } else {
      // Save PDF to temporary directory
      final dir = await getTemporaryDirectory();
      final file = io.File(
        '${dir.path}/customer_${c.customerQuniqueNumber ?? 'details'}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Customer Details: ${c.customerName ?? 'Customer'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.customerQuniqueNumber ?? 'Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Details',
            onPressed: _shareCustomerDetails,
          ),
          IconButton(
            icon: const Icon(Icons.add_card_rounded),
            tooltip: 'Add Outstanding',
            onPressed: () => _showAddOutstandingPopup(widget.customer.id!),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Obx(() {
          if (_customerController.isLoading.value ||
              _productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Customer Details',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_userType == 'admin') ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Get.to(
                              () =>
                                  AddCustomerScreen(index: widget.customer.id),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (widget.customer.id != null) {
                              _showDeleteCustomerDialog();
                            } else {
                              Get.snackbar('Error', 'Invalid customer ID');
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                _cardContainer(
                  children: [
                    _buildDetailRow(
                      Icons.person,
                      'Name',
                      c.customerName ?? 'N/A',
                    ),
                    _buildDetailRow(
                      Icons.call,
                      'Phone',
                      c.customerPhone ?? 'N/A',
                    ),
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      c.customerEmail ?? 'N/A',
                    ),
                    _buildDetailRow(
                      Icons.business,
                      'Company',
                      c.customerCompany ?? 'N/A',
                    ),
                    _buildDetailRow(
                      Icons.fingerprint,
                      'GSTIN',
                      c.customerGSTIN ?? 'N/A',
                    ),
                    _buildDetailRow(
                      Icons.badge,
                      'Customer ID',
                      c.customerQuniqueNumber ?? 'N/A',
                    ),
                    _buildDetailRow(
                      Icons.location_on,
                      'Address',
                      [
                        c.addressOne,
                        c.addressTwo,
                        c.city,
                        c.state,
                        c.pincode,
                      ].where((s) => s != null && s.isNotEmpty).join(', '),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle(
                  'Employees',
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      _pickEmployees(c.id!);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Employee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                if (_customerController.employees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No employees found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ..._customerController.employees.map((GetEmployeeModel e) {
                    return _cardContainer(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRowText(
                                Icons.person,
                                'Name',
                                e.name ?? 'N/A',
                              ),
                            ),
                            if (_userType == 'admin') ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Get.to(
                                    () => EditEmployeeScreen(
                                      employee: e,
                                      customerId: c.id!,
                                    ),
                                  );
                                },
                                tooltip: 'Edit ${e.name}',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showDeleteEmployeeDialog(
                                    e.id!,
                                    e.name ?? 'this employee',
                                  );
                                },
                                tooltip: 'Delete ${e.name}',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 20,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ph: ${e.phone ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _launchPhoneCall(e.phone),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.call,
                                    color: Colors.blueAccent,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => _openWhatsApp(e.phone),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.email, 'Email', e.email ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.cake,
                          'DOB',
                          e.dob != null
                              ? DateFormat('dd-MM-yyyy').format(e.dob!)
                              : 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.work,
                          'Position',
                          e.position?.category ?? 'N/A',
                        ),
                      ],
                    );
                  }),
                const SizedBox(height: 24),
                _sectionTitle(
                  'Customer Products',
                  trailing: ElevatedButton.icon(
                    onPressed: _onAddProductPressed,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final products = _productController.customerProducts;
                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No products added.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return Column(
                    children:
                        products.map((prod) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(
                              children: [
                                _cardContainer(
                                  children: [
                                    const SizedBox(height: 32),
                                    // spacing for buttons
                                    _buildDetailRow(
                                      Icons.category,
                                      'Category',
                                      prod.productCategory?.productCategory ??
                                          'N/A',
                                    ),
                                    _buildDetailRow(
                                      Icons.build,
                                      'Manufacturer',
                                      prod.manufacturer?.manufacturer ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      Icons.tag,
                                      'Serial No',
                                      prod.slNumber ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      Icons.date_range,
                                      'Sold Date',
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(prod.soldDate),
                                    ),
                                    _buildDetailRow(
                                      Icons.date_range,
                                      'Warranty Date',
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(prod.warranty),
                                    ),
                                    _buildDetailRow(
                                      Icons.date_range,
                                      'AMC Start Date',
                                      prod.amcStart != null
                                          ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(prod.amcStart!)
                                          : 'N/A',
                                    ),
                                    _buildDetailRow(
                                      Icons.date_range,
                                      'AMC End Date',
                                      prod.amcEnd != null
                                          ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(prod.amcEnd!)
                                          : 'N/A',
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        tooltip: 'Edit Product',
                                        onPressed: () {
                                          // Navigate to edit screen with product
                                          Get.to(
                                            () => EditCustomerProductScreen(
                                              product: prod,
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Delete Product',
                                        onPressed: () async {
                                          final confirm = await Get.dialog<
                                            bool
                                          >(
                                            AlertDialog(
                                              title: const Text(
                                                'Delete Product?',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this product?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Get.back(
                                                        result: false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Get.back(
                                                        result: true,
                                                      ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            final success =
                                                await _productController
                                                    .deleteCustomerProduct(
                                                      prod.id,
                                                    );
                                            if (success) {
                                              Get.snackbar(
                                                'Deleted',
                                                'Product deleted successfully',
                                              );
                                              _productController
                                                  .customerProducts
                                                  .removeWhere(
                                                    (p) => p.id == prod.id,
                                                  );
                                            } else {
                                              Get.snackbar(
                                                'Error',
                                                'Failed to delete product',
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowText(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _cardContainer({required List<Widget> children, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
