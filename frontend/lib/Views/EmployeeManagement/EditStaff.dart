import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import '../../Services/employee/employee_services.dart';
import '../../Views/Widgets/CustomButton.dart';
import '../../Views/Widgets/CustomDropDown.dart';
import '../../Views/Widgets/CustomTextField.dart';
import '../../Utils/Colors.dart';
import '../Widgets/CustomAlert.dart';

class EditStaffScreen extends StatefulWidget {
  final Map staff;
  const EditStaffScreen({super.key, required this.staff});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final CustomerController _customerController = Get.find<CustomerController>();
  final Employeeservices _employeeService = Employeeservices();
  
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  
  String? selectedPositionId;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.staff['name']?.toString());
    phoneController = TextEditingController(text: widget.staff['phone']?.toString());
    emailController = TextEditingController(text: widget.staff['email']?.toString());
    passwordController = TextEditingController();
    selectedPositionId = widget.staff['positionId']?.toString() ?? widget.staff['position']?['_id']?.toString();
    
    _customerController.fetchEmployeeCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Staff Member'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (_customerController.isLoading.value || isUpdating) {
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
                label: 'New Password (Optional)',
                hintText: 'Enter new password',
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
                onTap: _update,
                buttonText: 'Update Staff Member',
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _update() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      CustomAlert.error('Please fill all required fields');
      return;
    }

    if (phone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      CustomAlert.error('Mobile number must be exactly 10 digits and start with 6-9');
      return;
    }

    if (selectedPositionId == null) {
      CustomAlert.error('Please select a position');
      return;
    }

    try {
      setState(() => isUpdating = true);
      
      final Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone,
        'email': email,
        'positionId': selectedPositionId,
      };

      if (password.isNotEmpty) {
        updateData['password'] = password;
      }
      
      final success = await _employeeService.updateStaff(widget.staff['id']?.toString() ?? widget.staff['_id']?.toString() ?? '', updateData);

      if (success) {
        CustomAlert.success('Staff member updated successfully');
        await Future.delayed(const Duration(seconds: 2));
        Get.back(result: true); 
      } else {
        CustomAlert.error('Failed to update staff member');
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }
}
