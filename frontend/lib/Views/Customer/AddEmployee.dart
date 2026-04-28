// lib/Screens/Customers/AddEmployeeScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Views/Widgets/CustomSearchableDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/CustomerContact/CustomerContactModel.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:sales_grow/Utils/Appconstants.dart';

class AddEmployeeScreen extends StatefulWidget {
  final String id;
  const AddEmployeeScreen({super.key, required this.id});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final CustomerController _customerController = Get.put(CustomerController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController phoneController2 = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerController.fetchContactPositions();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    phoneController2.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _managePositions() {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Manage Positions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: _customerController.contactPositionList.length,
                    itemBuilder: (context, index) {
                      final pos = _customerController.contactPositionList[index];
                      return ListTile(
                        title: Text(pos.position ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditPositionDialog(pos.id!, pos.position!),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeletePosition(pos.id!, pos.position!),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
            CustomButton(
              onTap: _showAddPositionDialog,
              buttonText: "ADD NEW POSITION",
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPositionDialog() {
    final TextEditingController positionController = TextEditingController();
    Get.defaultDialog(
      title: "Add New Position",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomTextField(
          label: 'Position Name',
          hintText: 'e.g. Accountant',
          controller: positionController,
          icon: Icons.work,
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          final pos = positionController.text.trim();
          if (pos.isNotEmpty) {
            Get.back(); // close dialog
            await _customerController.addContactPosition(pos);
          } else {
            CustomAlert.error("Position name cannot be empty");
          }
        },
        child: const Text("ADD"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("CANCEL"),
      ),
    );
  }

  void _showEditPositionDialog(String id, String currentName) {
    final TextEditingController positionController = TextEditingController(text: currentName);
    Get.defaultDialog(
      title: "Edit Position",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomTextField(
          label: 'Position Name',
          hintText: 'e.g. Accountant',
          controller: positionController,
          icon: Icons.work,
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          final pos = positionController.text.trim();
          if (pos.isNotEmpty) {
            Get.back(); // close dialog
            await _customerController.updateContactPosition(id, pos);
          } else {
            CustomAlert.error("Position name cannot be empty");
          }
        },
        child: const Text("UPDATE"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("CANCEL"),
      ),
    );
  }

  void _confirmDeletePosition(String id, String name) {
    Get.defaultDialog(
      title: "Delete Position",
      middleText: "Are you sure you want to delete '$name'?",
      confirm: TextButton(
        onPressed: () async {
          Get.back();
          await _customerController.deleteContactPosition(id);
        },
        child: const Text("DELETE", style: TextStyle(color: Colors.red)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("CANCEL"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Contact'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _managePositions,
            icon: const Icon(Icons.settings),
            tooltip: "Manage positions",
          )
        ],
      ),
      body: Obx(() {
        if (_customerController.isPositionsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomSearchableDropDown<dynamic>(
                label: 'Position',
                hintText: 'Select Position',
                items: _customerController.contactPositionList,
                itemAsString: (pos) => pos.position ?? 'Unnamed',
                selectedItem: _customerController.contactPositionList.firstWhereOrNull((p) => p.id == selected),
                onChanged: (val) {
                  setState(() {
                    selected = val?.id;
                  });
                },
                isRequired: true,
                prefixIcon: Icons.list,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Name',
                hintText: 'Enter Contact Name',
                controller: nameController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.person,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone',
                hintText: 'Enter phone number',
                controller: phoneController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.call,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Alternative Phone',
                hintText: 'Optional secondary number',
                controller: phoneController2,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.call_merge,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hintText: 'Optional',
                controller: emailController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              CustomButton(
                onTap: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final phone2 = phoneController2.text.trim();
                  final email = emailController.text.trim();

                  if (name.isEmpty) {
                    CustomAlert.error('Name is required');
                    return;
                  }
                  if (phone.isEmpty) {
                    CustomAlert.error('Phone number is required');
                    return;
                  }
                  if (phone.length != 10) {
                    CustomAlert.error('Phone number must be exactly 10 digits');
                    return;
                  }
                  if (!RegExp(r'^[6-9]').hasMatch(phone)) {
                    CustomAlert.error('Phone number must start with 6, 7, 8, or 9');
                    return;
                  }
                  if (email.isNotEmpty &&
                      !RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(email)) {
                    CustomAlert.error('Invalid email format');
                    return;
                  }

                  if (phone2.isNotEmpty) {
                    if (phone2.length != 10) {
                      CustomAlert.error('Alternative phone must be 10 digits');
                      return;
                    }
                    if (!RegExp(r'^[6-9]').hasMatch(phone2)) {
                      CustomAlert.error('Alternative phone must start with 6, 7, 8, or 9');
                      return;
                    }
                  }

                  if (selected == null) {
                    CustomAlert.error('Please select a position');
                    return;
                  }

                  // Uniqueness check for Customer Contact Mobile Number
                  final isDuplicate = _customerController.hospitalContacts.any((c) => c.phone == phone);
                  if (isDuplicate) {
                    CustomAlert.error('This mobile number is already registered for this hospital');
                    return;
                  }

                  final contact = AddCustomerContactModel(
                    customer: widget.id,
                    name: name,
                    phone: phone,
                    phone2: phone2,
                    email: email,
                    position: selected!,
                  );

                  bool success = await _customerController.AddCustomerContact(
                    contact,
                  );
                  if (success) {
                    CustomAlert.success('Contact added successfully');
                    await Future.delayed(const Duration(seconds: 2));
                    Get.offAll(() => const CustomBottomNavBar());
                  }
                },
                buttonText: "SAVE",
              ),
            ],
          ),
        );
      }),
    );
  }
}
