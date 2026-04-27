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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Company Staff',
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
