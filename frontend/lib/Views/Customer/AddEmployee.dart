// lib/Screens/Customers/AddEmployeeScreen.dart

import 'package:flutter/material.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  final String id;
  const AddEmployeeScreen({super.key, required this.id});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  late List<Map<String, dynamic>> _employeeControllers;
  final CustomerController _customerController = Get.put(CustomerController());
  DateTime? selectedDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController =
      TextEditingController(); // New email controller
  String? selected;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _customerController.fetchCategories();
    });
  }

  Future<void> _pickDate(int idx) async {
    final ctrl = _employeeControllers[idx]['dob'] as TextEditingController;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Edit Employees')),
      body: Obx(() {
        if (_customerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomDropdownField(
                value: selected,
                items:
                    _customerController.categoryList
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.category ?? 'Unnamed'),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    selected = val;
                  });
                },
                hintText: 'Position',
                icon: Icons.list,
              ),
              CustomTextField(
                label: 'Name',
                hintText: 'Enter Employee Name',
                controller: nameController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.person,
                inputFormatters: [FirstLetterCapitalFormatter()],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone',
                hintText: 'Enter phone number',
                controller: phoneController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.call,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hintText: 'Enter email address',
                controller: emailController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              CustomDatePickerField(
                label: "Date of Joining",
                hintText: "Date of Birth",
                icon: Icons.calendar_today,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              const SizedBox(height: 40),
              CustomButton(
                onTap: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final email = emailController.text.trim();

                  if (name.isEmpty) {
                    Get.snackbar('Validation Error', 'Name is required');
                    return;
                  }
                  if (phone.isEmpty) {
                    Get.snackbar(
                      'Validation Error',
                      'Phone number is required',
                    );
                    return;
                  }
                  if (email.isEmpty) {
                    Get.snackbar('Validation Error', 'Email is required');
                    return;
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(email)) {
                    Get.snackbar('Validation Error', 'Invalid email format');
                    return;
                  }
                  if (selected == null) {
                    Get.snackbar(
                      'Validation Error',
                      'Please select a position',
                    );
                    return;
                  }

                  final employee = AddEmployeeModel(
                    customer: widget.id,
                    dob: selectedDate,
                    name: name,
                    phone: phone,
                    email: email, // Add email to the model
                    position: selected!,
                  );

                  _customerController.AddEmployee(employee);
                },
                buttonText: "Save",
              ),
            ],
          ),
        );
      }),
    );
  }
}
