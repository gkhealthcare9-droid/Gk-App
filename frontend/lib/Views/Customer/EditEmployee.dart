// lib/Screens/Customers/EditEmployeeScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Models/CustomerContact/CustomerContactModel.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart'; // Add this import

class EditEmployeeScreen extends StatefulWidget {
  final GetCustomerContactModel employee;
  final String customerId;

  const EditEmployeeScreen({
    super.key,
    required this.employee,
    required this.customerId,
  });

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final CustomerController _customerController = Get.find<CustomerController>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController phoneController2;
  late TextEditingController emailController; // New email controller
  String? selectedPositionId;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing employee data
    nameController = TextEditingController(text: widget.employee.name);
    phoneController = TextEditingController(text: widget.employee.phone);
    phoneController2 = TextEditingController(text: widget.employee.phone2);
    emailController = TextEditingController(text: widget.employee.email); // Initialize email
    selectedPositionId = widget.employee.position?.id;

    // Ensure positions are loaded
    Future.delayed(Duration.zero, () {
      _customerController.fetchContactPositions();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    phoneController2.dispose();
    emailController.dispose(); // Dispose email controller
    super.dispose();
  }


  /// Validates inputs and calls the controller’s `updateEmployee` method
  void _onUpdatePressed() {
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
    if (email.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
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
    if (selectedPositionId == null) {
      CustomAlert.error('Please select a position');
      return;
    }

    // Uniqueness check for Customer Contact Mobile Number (excluding current record)
    final isDuplicate = _customerController.hospitalContacts.any((c) => c.phone == phone && c.id != widget.employee.id);
    if (isDuplicate) {
      CustomAlert.error('This mobile number is already registered for this hospital');
      return;
    }

    // Construct an updated AddCustomerContactModel
    final updatedContact = AddCustomerContactModel(
      name: name,
      phone: phone,
      phone2: phone2,
      email: email, // Include email
      position: selectedPositionId,
      customer: widget.customerId,
    );

    // Call update method
    _customerController
        .updateCustomerContact(widget.employee.id!, updatedContact)
        .then((success) async {
      if (success) {
        CustomAlert.success('Contact updated successfully');
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        CustomAlert.error('Failed to update contact');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: Obx(() {
        if (_customerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) Position Dropdown
              CustomDropdownField(
                value: selectedPositionId,
                items: _customerController.contactPositionList.map((pos) {
                  return DropdownMenuItem<String>(
                    value: pos.id,
                    child: Text(pos.position ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedPositionId = val;
                  });
                },
                hintText: 'Position',
                icon: Icons.list,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              // 2) Name Field
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
              // 3) Phone Field
              CustomTextField(
                label: 'Phone',
                hintText: 'Enter phone number',
                controller: phoneController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.call,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              ),
              const SizedBox(height: 16),
              // 4) Email Field
              CustomTextField(
                label: 'Email',
                hintText: 'Enter email address',
                controller: emailController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.email,
              ),
              const SizedBox(height: 40),
              // 6) Update Button
              CustomButton(
                onTap: _onUpdatePressed,
                buttonText: "Update",
              ),
            ],
          ),
        );
      }),
    );
  }
}