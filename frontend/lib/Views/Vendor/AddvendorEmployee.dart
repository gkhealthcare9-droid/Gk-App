// lib/Screens/Customers/AddvendorEmployee.dart

import 'package:flutter/material.dart';
import 'package:sales_grow/Controllers/AddVendor/vendor_controller.dart';
import 'package:sales_grow/Models/Employee/add_vendor_employee_model.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:get/get.dart';
import '../Widgets/CustomAlert.dart';

class AddvendorEmployeeScreen extends StatefulWidget {
  final String id;
  const AddvendorEmployeeScreen({
    super.key, required this.id,
  });

  @override
  State<AddvendorEmployeeScreen> createState() => _AddvendorEmployeeScreenState();
}


class _AddvendorEmployeeScreenState extends State<AddvendorEmployeeScreen> {
  late List<Map<String, dynamic>> _employeeControllers;
  final VendorController _customerController = Get.put(VendorController());
  DateTime? selectedDate;
  String? selected;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,()async{
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
      '${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
      setState(() {});
    }
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
                    itemCount: _customerController.categoryList.length,
                    itemBuilder: (context, index) {
                      final cat = _customerController.categoryList[index];
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
          hintText: 'e.g. Technician',
          controller: categoryController,
          icon: Icons.work,
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          final cat = categoryController.text.trim();
          if (cat.isNotEmpty) {
            Get.back(); // close dialog
            await _customerController.addCategory(cat);
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
          hintText: 'e.g. Technician',
          controller: categoryController,
          icon: Icons.work,
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          final cat = categoryController.text.trim();
          if (cat.isNotEmpty) {
            Get.back(); // close dialog
            await _customerController.updateCategory(id, cat);
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
          await _customerController.deleteCategory(id);
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
        appBar: AppBar(
          title: const Text('Add / Edit Employees'),
          actions: [
            IconButton(
              onPressed: _manageCategories,
              icon: const Icon(Icons.settings),
              tooltip: "Manage positions",
            )
          ],
        ),
        body: Obx((){
          if(_customerController.isLoading.value){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomDropdownField(value:selected ,items: _customerController.categoryList
                    .map((category) => DropdownMenuItem<String>(
                  value: category.id, // or category.categoryName
                  child: Text(category.category ?? 'Unnamed'),
                ))
                    .toList() ,
                    onChanged: (val){
                      setState(() {
                        selected=val;
                      });
                    },
                    hintText: 'Position',
                    icon: Icons.list),

                CustomTextField(
                  label: 'Name',
                  hintText: 'Enter Employee Name',
                  controller: nameController,
                  obscureText: false,
                  showSuffixIcon: false,
                  icon: Icons.person,
                  inputFormatters: [ FirstLetterCapitalFormatter() ],
                ),
                CustomTextField(
                  label: 'Email ',
                  hintText: 'Email ',
                  controller: emailController,
                  obscureText: false,
                  showSuffixIcon: false,
                  icon: Icons.email,
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
                SizedBox(height: 40,),
                CustomButton(
                  onTap: () {
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
                    if (selected == null) {
                      CustomAlert.showError(context: context, message: 'Please select a position');
                      return;
                    }

                    // dob can remain null here
                    final employee = AddvendorEmployee(
                      position: selected!,
                      phone: phone,
                      name: name,
                      email: emailController.text.trim(),
                      dob: selectedDate, // nullable
                      vendor: widget.id,
                    );
                    _customerController.AddEmployee(employee);
                  },
                  buttonText: "Save",
                )


              ],
            ),
          );
        })
    );
  }
}
