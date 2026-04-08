// lib/Screens/Customers/AddvendorEmployee.dart

import 'package:flutter/material.dart';
import 'package:sales_grow/Controllers/AddVendor/vendor_controller.dart';
import 'package:sales_grow/Models/Employee/add_vendor_employee_model.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:get/get.dart';

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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
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

  String? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add / Edit Employees')),
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

                ), CustomTextField(
                  label: 'Email ',
                  hintText: 'Email ',
                  controller: nameController,
                  obscureText: false,
                  showSuffixIcon: false,
                  icon: Icons.person,
                  inputFormatters: [ FirstLetterCapitalFormatter() ],

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
                      Get.snackbar('Validation Error', 'Name is required');
                      return;
                    }
                    if (phone.isEmpty) {
                      Get.snackbar('Validation Error', 'Phone number is required');
                      return;
                    }
                    if (selected == null) {
                      Get.snackbar('Validation Error', 'Please select a position');
                      return;
                    }

                    // dob can remain null here
                    final employee = AddvendorEmployee(
                      position: selected!,
                      phone: phone,
                      name: name,
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
