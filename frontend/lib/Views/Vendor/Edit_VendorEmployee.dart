import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Models/Employee/add_vendor_employee_model.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import '../Widgets/CustomAlert.dart';

import '../../Controllers/AddVendor/vendor_controller.dart';

class EditVendorEmployeeScreen extends StatefulWidget {
  /// The full GetvendorEmployee instance (fetched from VendorController.employees).
  /// Must contain at least: id, name, phone, dob, position
  final GetvendorEmployee employee;

  /// The ID of the parent vendor (so we know which vendor this employee belongs to)
  final String vendorId;

  const EditVendorEmployeeScreen({
    super.key,
    required this.employee,
    required this.vendorId,
  });

  @override
  State<EditVendorEmployeeScreen> createState() =>
      _EditVendorEmployeeScreenState();
}

class _EditVendorEmployeeScreenState extends State<EditVendorEmployeeScreen> {
  final VendorController _vendorController = Get.find<VendorController>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  DateTime? selectedDob;
  String? selectedPositionId;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing employee data
    nameController = TextEditingController(text: widget.employee.name);
    phoneController = TextEditingController(text: widget.employee.phone);

    // Pre-select the DOB if it exists
    selectedDob = widget.employee.dob;

    // Pre-select the position ID (category) if it exists
    selectedPositionId = widget.employee.position?.id;

    // Ensure categories are loaded so the dropdown can show the correct text
    Future.delayed(Duration.zero, () {
      _vendorController.fetchCategories();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
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

  /// Validates inputs and calls the controller’s `editVendorEmployee` method
  void _onUpdatePressed() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      CustomAlert.showError(context: context, message: 'Name is required');
      return;
    }
    if (phone.isEmpty) {
      CustomAlert.showError(context: context, message: 'Phone number is required');
      return;
    }
    if (selectedDob == null) {
      CustomAlert.showError(context: context, message: 'Please select Date of Birth');
      return;
    }
    if (selectedPositionId == null) {
      CustomAlert.showError(context: context, message: 'Please select a position');
      return;
    }

    // Construct an updated AddvendorEmployee model
    final updatedEmployee = AddvendorEmployee(
      name: name,
      phone: phone,
      dob: selectedDob,
      position: selectedPositionId,
      vendor: widget.vendorId,
    );

    // Call the controller’s edit method
    _vendorController
        .editVendorEmployee(widget.employee.id!, updatedEmployee)
        .then((_) async {
          CustomAlert.showSuccess(context: context, message: 'Employee updated successfully');
          await Future.delayed(const Duration(seconds: 2));
          Get.back(); // Pop back to the previous screen
        })
        .catchError((e) {
          CustomAlert.showError(context: context, message: 'Failed to update employee: $e');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vendor Employee')),
      body: Obx(() {
        // Show a loading spinner while fetching position categories
        if (_vendorController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) Position Dropdown
              CustomDropdownField(
                value: selectedPositionId,
                items:
                    _vendorController.categoryList.map((category) {
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

              // 4) DOB Picker
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

              // 5) Update Button
              CustomButton(onTap: _onUpdatePressed, buttonText: "Update"),
            ],
          ),
        );
      }),
    );
  }
}
