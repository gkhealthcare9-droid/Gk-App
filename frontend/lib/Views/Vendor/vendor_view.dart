import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Controllers/AddVendor/vendor_controller.dart';
import 'package:sales_grow/Models/Vendor/Vendor.dart';
import 'package:sales_grow/Views/Vendor/AddVendor_Product_Screen.dart';
import 'package:sales_grow/Views/Vendor/AddvendorEmployee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Controllers/Product/Product.dart';
import 'Edit_VendorEmployee.dart';
import 'editvendor.dart';

class vendorview extends StatefulWidget {
  final VendorModel vendor;
  const vendorview({super.key, required this.vendor});

  @override
  State<vendorview> createState() => _vendorviewState();
}

class _vendorviewState extends State<vendorview> {
  final VendorController _vendorController = Get.put(VendorController());
  String? _userType; // ← Will hold "admin" or something else

  final ProductController _productController = Get.put(ProductController());
  final List<Map<String, String>> _addedProducts = [];
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _userType = prefs.getString('userType');
      });
    });
    Future.delayed(Duration.zero, () async {
      _vendorController.fetchEmployees(widget.vendor.id!);
    });
  }

  Future<void> _onAddProductPressed() async {
    final Map<String, String>? result = await Get.to<Map<String, String>>(
          () => AddVendorProductScreen(id: widget.vendor.id!),
    );

    if (result != null) {
      setState(() {
        // Simply add all keys/values that came back:
        _addedProducts.add(Map<String, String>.from(result));
      });
    }
  }

  Future<void> _openWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      Get.snackbar('Error', 'No phone number provided');
      return;
    }

    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Support only Indian numbers here, customize if you need more
    if (digitsOnly.length == 10) {
      digitsOnly = '91$digitsOnly';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      // OK
    } else if (digitsOnly.length < 10) {
      Get.snackbar('Error', 'Invalid phone number format.');
      return;
    }

    final whatsappUrl = Uri.parse('https://api.whatsapp.com/send?phone=$digitsOnly');

    try {
      // Try opening with WhatsApp/external app
      bool launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // If not launched (app not installed), open in browser
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.platformDefault, // Browser
        );
      }
    } catch (e) {
      // If any error, try browser as last fallback
      try {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.platformDefault,
        );
      } catch (e) {
        Get.snackbar('Error', 'Could not open WhatsApp or browser.');
      }
    }
  }

  void showDeleteDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back(); // close dialog first
              onConfirm(); // then call action
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      _vendorController.fetchEmployees(widget.vendor.id!);
      await _productController.fetchCustomerProducts(widget.vendor.id!);

    });
  }

  Future<void> _pickEmployees(String id) async {
    final updated = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddvendorEmployeeScreen(id: id),
      ),
    );

    if (updated != null) {
      print('Updated employees: $updated');
    }
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



  @override
  Widget build(BuildContext context) {
    final c = widget.vendor;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.vendorCompany ?? c.vendorName ?? 'Vendor'),

      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Obx(() {
          if (_vendorController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Vendor Details',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_userType == 'admin') ...[

            IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Get.to(() => EditvendorScreen(
                            vendor: widget.vendor,
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (widget.vendor.id != null) {
                            showDeleteDialog(
                              title: 'Delete Vendor?',
                              message: 'Are you sure you want to delete this vendor?',
                              onConfirm: () {
                                _vendorController.deletevendor(widget.vendor.id!);
                              },
                            );
                          } else {
                            Get.snackbar('Error', 'Invalid vendor ID');
                          }
                        },
                      ),
          ]
                    ],
                  ),
                ),
                _cardContainer(
                  children: [
                    _buildDetailRow(Icons.person, 'Name', c.vendorName ?? 'N/A'),
                    _buildDetailRow(Icons.person, 'Company Website', c.vendorName ?? 'N/A'),
                    _buildDetailRow(Icons.call, 'Phone', c.vendorPhone ?? 'N/A'),
                    _buildDetailRow(Icons.email, 'Email', c.vendorEmail ?? 'N/A'),
                    _buildDetailRow(Icons.business, 'Company', c.vendorCompany ?? 'N/A'),
                    _buildDetailRow(Icons.fingerprint, 'GSTIN', c.vendorGSTIN ?? 'N/A'),
                    _buildDetailRow(Icons.fingerprint, 'unique id', c.vendorQuniqeNumber ?? 'N/A'),
                    _buildDetailRow(
                      Icons.location_on,
                      'Address',
                      '${c.addressOne ?? ''}, ${c.addressTwo ?? ''}, ${c.city ?? ''}, ${c.state ?? ''} - ${c.pincode ?? ''}',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      elevation: 0,
                    ),
                  ),
                ),
                if (_vendorController.employees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No employees found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ..._vendorController.employees.map((e) => _cardContainer(
                    children: [
                      _buildDetailRowWithEdit(
                        icon: Icons.person,
                        label: 'Name',
                        value: e.name ?? '',
                        onEdit: () {
                          Get.to(() => EditVendorEmployeeScreen(
                            employee: e,
                            vendorId: widget.vendor.id!,
                          ));
                        },
                        onDelete: () {
                          if (e.id != null) {
                            showDeleteDialog(
                              title: 'Delete Employee?',
                              message: 'Are you sure you want to delete this employee?',
                              onConfirm: () {
                                _vendorController.deleteVendorEmployee(e.id!, widget.vendor.id!);
                              },
                            );
                          } else {
                            Get.snackbar('Error', 'Invalid employee ID');
                          }
                        },
                      ),
                      _buildPhoneRow(
                        icon: Icons.phone,
                        label: 'Ph',
                        value: e.phone ?? '',
                        onCall: () => _launchPhoneCall(e.phone),
                      ),
                      _buildDetailRow(
                        Icons.business,
                        'email',
                        c.vendorEmail ?? 'N/A',
                      ),
                      _buildDetailRow(
                        Icons.cake,
                        'DOB',
                        e.dob != null ? DateFormat('dd-MM-yyyy').format(e.dob!) : '',
                      ),
                      _buildDetailRow(Icons.work, 'Position', e.position?.category ?? ''),
                    ],
                  )),
                const SizedBox(height: 24),

                // _sectionTitle(
                //   'Customer Products',
                //   trailing: ElevatedButton.icon(
                //     onPressed: _onAddProductPressed,
                //     icon: const Icon(Icons.add, size: 18),
                //     label: const Text('Add Product'),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 12,
                //         vertical: 8,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       textStyle: const TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w600,
                //       ),
                //       elevation: 0,
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 12),
                //
                // if (_addedProducts.isEmpty)
                //   const Padding(
                //     padding: EdgeInsets.symmetric(vertical: 12),
                //     child: Text(
                //       'No products added.',
                //       style: TextStyle(color: Colors.grey),
                //     ),
                //   )
                // else
                //   ..._addedProducts.map((prod) {
                //     return Padding(
                //       padding: const EdgeInsets.only(bottom: 12),
                //       child: _cardContainer(
                //         children: [
                //           // 1) Category (always present)
                //           _buildDetailRow(
                //             Icons.category,
                //             'Category',
                //             prod['category'] ?? 'N/A',
                //           ),
                //
                //           // 2) Dialysis Machine subfields (only if category = “Dialysis Machine”)
                //           if (prod['category'] == 'Dialysis Machine') ...[
                //             const SizedBox(height: 8),
                //             const Divider(),
                //             const SizedBox(height: 8),
                //
                //             _buildDetailRow(
                //               Icons.build,
                //               'Make',
                //               prod['make'] ?? 'N/A',
                //             ),
                //             _buildDetailRow(
                //               Icons.settings,
                //               'Model',
                //               prod['model'] ?? 'N/A',
                //             ),
                //             _buildDetailRow(
                //               Icons.confirmation_num,
                //               'Qty',
                //               prod['qty'] ?? 'N/A',
                //             ),
                //             _buildDetailRow(
                //               Icons.tag,
                //               'Serial No',
                //               prod['serialNo'] ?? 'N/A',
                //             ),
                //             _buildDetailRow(
                //               Icons.date_range,
                //               'AMC Start Date',
                //               prod['amcStart'] != null
                //                   ? DateFormat('dd/MM/yyyy').format(
                //                 DateTime.parse(prod['amcStart']!),
                //               )
                //                   : 'N/A',
                //             ),
                //             _buildDetailRow(
                //               Icons.date_range,
                //               'AMC End Date',
                //               prod['amcEnd'] != null
                //                   ? DateFormat('dd/MM/yyyy').format(
                //                 DateTime.parse(prod['amcEnd']!),
                //               )
                //                   : 'N/A',
                //             ),
                //           ],
                //
                //           // 3) Telle Response (always present)
                //           _buildDetailRow(
                //             Icons.call_to_action,
                //             'Telle Response',
                //             prod['telleResponse'] ?? 'N/A',
                //           ),
                //
                //           // 4) Communication (always present)
                //           _buildDetailRow(
                //             Icons.message,
                //             'Communication',
                //             prod['communication'] ?? 'N/A',
                //           ),
                //
                //           // 5) Follow‐Up Date (always present)
                //           _buildDetailRow(
                //             Icons.event,
                //             'Follow-Up Date',
                //             prod['followUpDate'] != null
                //                 ? DateFormat('dd/MM/yyyy').format(
                //               DateTime.parse(prod['followUpDate']!),
                //             )
                //                 : 'N/A',
                //           ),
                //         ],
                //       ),
                //     );
                //   }).toList(),
              ],
            ),

          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithEdit({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        if (_userType == 'admin') ...[

    IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: onDelete,
          ),
        ],
    ]
      ),
    );
  }

  Widget _buildPhoneRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCall,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1) Leading phone‐type icon inside a light‐blue circle
          Container(

            child: Icon(icon, size: 20, color: Colors.blue),
          ),

          const SizedBox(width: 12),

          // 2) Label and phone number text
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(value)),

          // 3) Spacing before action icons
          const SizedBox(width: 8),

          // 4) Phone‐call button inside a light‐green circle
          GestureDetector(
            onTap: onCall,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.call, color: Colors.blueAccent, size: 27),
            ),
          ),

          const SizedBox(width: 20),

          // 5) WhatsApp button inside a light‐green circle
          GestureDetector(
            onTap: () => _openWhatsApp(value),
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

    );

  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _cardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}