// lib/Screens/Customers/EditEmployeeScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';

class EditEmployeeScreen extends StatefulWidget {
  final GetEmployeeModel employee;
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
  late TextEditingController emailController; // New email controller
  DateTime? selectedDob;
  String? selectedPositionId;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing employee data
    nameController = TextEditingController(text: widget.employee.name);
    phoneController = TextEditingController(text: widget.employee.phone);
    emailController = TextEditingController(text: widget.employee.email); // Initialize email
    selectedDob = widget.employee.dob;
    selectedPositionId = widget.employee.position?.id;

    // Ensure categories are loaded
    Future.delayed(Duration.zero, () {
      _customerController.fetchCategories();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose(); // Dispose email controller
    super.dispose();
  }

  /// Opens the date picker and updates `selectedDob`
  Future<void> _pickDob() async {
    final initial = selectedDob ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDob = picked;
      });
    }
  }

  /// Validates inputs and calls the controller’s `updateEmployee` method
  void _onUpdatePressed() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Validation Error', 'Name is required');
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar('Validation Error', 'Phone number is required');
      return;
    }
    if (email.isEmpty) {
      Get.snackbar('Validation Error', 'Email is required');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      Get.snackbar('Validation Error', 'Invalid email format');
      return;
    }
    if (selectedDob == null) {
      Get.snackbar('Validation Error', 'Please select Date of Birth');
      return;
    }
    if (selectedPositionId == null) {
      Get.snackbar('Validation Error', 'Please select a position');
      return;
    }

    // Construct an updated AddEmployeeModel
    final updatedEmployee = AddEmployeeModel(
      name: name,
      phone: phone,
      email: email, // Include email
      dob: selectedDob,
      position: selectedPositionId,
      customer: widget.customerId,
    );

    // Call update method
    _customerController
        .updateEmployee(widget.employee.id!, updatedEmployee)
        .then((success) {
      if (success) {
        Get.back();
      } else {
        Get.snackbar('Error', 'Failed to update employee');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Employee'),
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
                items: _customerController.categoryList.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.category ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedPositionId = val;
                  });
                },
                hintText: 'Position',
                icon: Icons.list,
              ),
              const SizedBox(height: 16),
              // 2) Name Field
              CustomTextField(
                label: 'Name',
                hintText: 'Enter Employee Name',
                controller: nameController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.person,
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
              const SizedBox(height: 16),
              // 5) DOB Picker
              InkWell(
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDob != null
                            ? DateFormat('dd-MM-yyyy').format(selectedDob!)
                            : 'Select date',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
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