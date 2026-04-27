// lib/Screens/Vendors/AddVendorScreen.dart


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AddVendor/vendor_controller.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';

import '../../Models/Vendor/Vendor.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomTextField.dart';

class EditvendorScreen extends StatefulWidget {
  final VendorModel vendor;

  const EditvendorScreen({super.key, required this.vendor});

  @override
  _EditvendorScreenState createState() => _EditvendorScreenState();
}

class _EditvendorScreenState extends State<EditvendorScreen> {
  final VendorController _vendorController = Get.put(VendorController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController billingAddress1Controller =
      TextEditingController();
  final TextEditingController billingAddress2Controller =
      TextEditingController();
  final TextEditingController billingCityController = TextEditingController();
  final TextEditingController billingStateController = TextEditingController();
  final TextEditingController billingPincodeController =
      TextEditingController();
  RxBool isDistributor = false.obs;

  @override
  void initState() {
    super.initState();
    String name = widget.vendor.vendorName ?? '';
    isDistributor.value = name.contains('(Distributor)');
    nameController.text = name.replaceAll(' (Distributor)', '');
    // Populate controllers with existing vendor data
    nameController.text = widget.vendor.vendorName ?? '';
    phoneController.text = widget.vendor.vendorPhone ?? '';
    emailController.text = widget.vendor.vendorEmail ?? '';
    gstinController.text = widget.vendor.vendorGSTIN ?? '';
    companyController.text = widget.vendor.vendorCompany ?? '';
    billingAddress1Controller.text = widget.vendor.addressOne ?? '';
    billingAddress2Controller.text = widget.vendor.addressTwo ?? '';
    billingCityController.text = widget.vendor.city ?? '';
    billingStateController.text = widget.vendor.state ?? '';
    billingPincodeController.text = widget.vendor.pincode ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    gstinController.dispose();
    companyController.dispose();
    billingAddress1Controller.dispose();
    billingAddress2Controller.dispose();
    billingCityController.dispose();
    billingStateController.dispose();
    billingPincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Vendor')),

      body: Obx(() {
        if (_vendorController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Obx(
                () => CheckboxListTile(
                  title: const Text("Is Distributor?"),
                  value: isDistributor.value,
                  onChanged: (val) {
                    isDistributor.value = val ?? false;

                    if (isDistributor.value &&
                        !nameController.text.contains('(Distributor)')) {
                      nameController.text =
                          "${nameController.text.trim()} (Distributor)";
                    } else if (!isDistributor.value &&
                        nameController.text.contains('(Distributor)')) {
                      nameController.text =
                          nameController.text
                              .replaceAll(' (Distributor)', '')
                              .trim();
                    }

                    // Move cursor to the end
                    nameController.selection = TextSelection.fromPosition(
                      TextPosition(offset: nameController.text.length),
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Name',
                hintText: 'Enter vendor name',
                controller: nameController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.person,
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
                hintText: 'Enter email',
                controller: emailController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'GSTIN',
                hintText: 'Enter GSTIN',
                controller: gstinController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Company',
                hintText: 'Enter company name',
                controller: companyController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Billing Address 1',
                hintText: 'Enter address line 1',
                controller: billingAddress1Controller,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.location_pin,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Billing Address 2',
                hintText: 'Enter address line 2',
                controller: billingAddress2Controller,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.location_pin,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Billing City',
                hintText: 'Enter city',
                controller: billingCityController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Billing State',
                hintText: 'Enter state',
                controller: billingStateController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.map,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Billing Pincode',
                hintText: 'Enter pincode',
                controller: billingPincodeController,
                obscureText: false,
                showSuffixIcon: false,
                icon: Icons.pin_drop,
              ),
              const SizedBox(height: 24),
              CustomButton(
                buttonText: 'Update Vendor',
                onTap: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final email = emailController.text.trim();
                  final gstin = gstinController.text.trim();
                  final company = companyController.text.trim();
                  final address1 = billingAddress1Controller.text.trim();
                  final address2 = billingAddress2Controller.text.trim();
                  final city = billingCityController.text.trim();
                  final state = billingStateController.text.trim();
                  final pincode = billingPincodeController.text.trim();

                  if (name.isEmpty) {
                    CustomAlert.error('Name is required');
                  } else if (phone.isEmpty) {
                    CustomAlert.error('Phone number is required');
                  } else if (email.isEmpty) {
                    CustomAlert.error('Email is required');
                    // } else if (gstin.isEmpty) {
                    //   CustomAlert.error('GSTIN is required');
                  } else if (company.isEmpty) {
                    CustomAlert.error('Company name is required');
                  } else if (address1.isEmpty) {
                    CustomAlert.error('Address Line 1 is required');
                  } else if (address2.isEmpty) {
                    CustomAlert.error('Address Line 2 is required');
                  } else if (city.isEmpty) {
                    CustomAlert.error('City is required');
                  } else if (state.isEmpty) {
                    CustomAlert.error('State is required');
                  } else if (pincode.isEmpty) {
                    CustomAlert.error('Pincode is required');
                  } else {
                    // Create customer model
                    final vendor = AddVendorModel(
                      vendorName: name,
                      vendorPhone: phone,
                      vendorEmail: email,
                      vendorGSTIN: gstin,
                      vendorCompany: company,
                      addressOne: address1,
                      addressTwo: address2,
                      city: city,
                      state: state,
                      pincode: pincode,
                    );
                    _vendorController.editVendor(widget.vendor.id!, vendor);
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
