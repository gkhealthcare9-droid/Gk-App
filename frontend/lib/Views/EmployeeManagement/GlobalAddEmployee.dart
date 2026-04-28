import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Controllers/AuthController/Auth_controller.dart';
import 'package:sales_grow/Controllers/AuthController/ProfileController.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import '../../Utils/Colors.dart';

class GlobalAddEmployee extends StatefulWidget {
  const GlobalAddEmployee({super.key});

  @override
  State<GlobalAddEmployee> createState() => _GlobalAddEmployeeState();
}

class _GlobalAddEmployeeState extends State<GlobalAddEmployee> {
  final CustomerController _customerController = Get.find<CustomerController>();
  final SignupController _signupController = Get.put(SignupController());
  final ProfileController _profileController = Get.put(ProfileController());
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  String? selectedPositionId;

  @override
  void initState() {
    super.initState();
    // Load staff categories (positions) of type 'Employee'
    _customerController.fetchEmployeeCategories();
  }


  void _manageCategories() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
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
                  const Text("Manage Staff Positions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close)),
                ],
              ),
            const Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: _customerController.employeeCategories.length,
                    itemBuilder: (context, index) {
                      final cat = _customerController.employeeCategories[index];
                      return ListTile(
                        title: Text(cat.category ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditCategoryDialog(cat.id!, cat.category!),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteCategory(cat.id!, cat.category!),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
            CustomButton(
              onTap: _showAddCategoryDialog,
              buttonText: "ADD NEW POSITION",
            ),
          ],
        ),
      )),
      isScrollControlled: true,
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();
    Get.defaultDialog(
      title: "Add New Position",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomTextField(
          label: 'Position Name',
          hintText: 'e.g. Sales Manager',
          controller: categoryController,
          icon: Icons.work,
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          final cat = categoryController.text.trim();
          if (cat.isNotEmpty) {
            Get.back(); // close dialog
            await _customerController.addEmployeeCategory(cat);
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

  void _showEditCategoryDialog(String id, String currentName) {
    final TextEditingController categoryController = TextEditingController(text: currentName);
    Get.defaultDialog(
      title: "Edit Position",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomTextField(
          label: 'Position Name',
          hintText: 'e.g. Sales Manager',
          controller: categoryController,
          icon: Icons.work,
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          final cat = categoryController.text.trim();
          if (cat.isNotEmpty) {
            Get.back(); // close dialog
            await _customerController.updateEmployeeCategory(id, cat);
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

  void _confirmDeleteCategory(String id, String name) {
    Get.defaultDialog(
      title: "Delete Position",
      middleText: "Are you sure you want to delete '$name'?",
      confirm: TextButton(
        onPressed: () async {
          Get.back();
          await _customerController.deleteEmployeeCategory(id);
          CustomAlert.success("Position deleted successfully");
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
      appBar: CustomAppBar(
        title: 'Add Company Staff',
        actions: [
          IconButton(
            onPressed: _manageCategories,
            icon: const Icon(Icons.settings),
            tooltip: "Manage positions",
          )
        ],
      ),
      body: Obx(() {
        if (_customerController.isLoading.value || _signupController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Staff Details',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Name',
                hintText: 'Enter name',
                controller: nameController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Phone',
                hintText: 'Enter phone',
                controller: phoneController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Email',
                hintText: 'Enter email',
                controller: emailController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.email,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Password',
                hintText: 'Enter password',
                controller: passwordController,
                obscureText: true,
                showSuffixIcon: true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Position',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              CustomDropdownField(
                value: selectedPositionId,
                items: _customerController.employeeCategories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(cat.category ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedPositionId = val),
                hintText: 'Select Position',
                icon: Icons.work,
              ),
              const SizedBox(height: 40),
              CustomButton(
                onTap: _submit,
                buttonText: 'Save Staff Member',
              ),
            ],
          ),
        );
      }),
    );
  }

  void _submit() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      CustomAlert.error('Please fill all required fields');
      return;
    }
    
    if (phone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      CustomAlert.error('Mobile number must be exactly 10 digits and start with 6-9');
      return;
    }

    // Uniqueness check for Staff Mobile Number
    final isDuplicate = _profileController.users.any((user) => user.phone == phone);
    if (isDuplicate) {
      CustomAlert.error('This mobile number is already registered to another staff member');
      return;
    }

    if (selectedPositionId == null) {
      CustomAlert.error('Please select a position');
      return;
    }

    final success = await _signupController.signup(
      name,
      email,
      phone,
      password,
      selectedPositionId!,
      shouldNavigate: false,
    );
    
    if (success) {
      // If signup was successful, go back with result true to refresh the list
      Future.delayed(const Duration(seconds: 2), () {
        Get.back(result: true);
      });
    }
  }
}
