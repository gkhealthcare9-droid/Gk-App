import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AddVendor/vendor_controller.dart';
import '../../Controllers/Location/Location_controller.dart';
import '../../Models/Vendor/Vendor.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomAlert.dart';
import '../Widgets/CustomSearchableDropDown.dart';
import '../Widgets/CustomBackButton.dart';

class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key});

  @override
  _AddVendorScreenState createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final VendorController _vendorController = Get.put(VendorController());
  final LocationController _locationController = Get.put(LocationController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController billingAddress1Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  dynamic selectedStateObj;
  dynamic selectedCityObj;

  @override
  void initState() {
    super.initState();
    _locationController.fetchStates();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    gstinController.dispose();
    companyController.dispose();
    billingAddress1Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final vendor = AddVendorModel(
        vendorName: nameController.text.trim(),
        vendorPhone: phoneController.text.trim(),
        vendorEmail: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        vendorGSTIN: gstinController.text.trim().isNotEmpty ? gstinController.text.trim() : null,
        vendorCompany: companyController.text.trim(),
        addressOne: billingAddress1Controller.text.trim().isNotEmpty ? billingAddress1Controller.text.trim() : null,
        city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : null,
        pincode: pincodeController.text.trim().isNotEmpty ? pincodeController.text.trim() : null,
      );

      _vendorController.addvendor(vendor);
    } else {
      CustomAlert.error("Required fields missing.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: CustomBackButton(onTap: () => Get.back()),
        title: const Text('NEW VENDOR PARTNER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (_vendorController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Vendor Identity', Icons.business_center_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          CustomTextField(
                            label: 'Company Name',
                            hintText: 'e.g. HealthCorp Industries',
                            controller: companyController,
                            icon: Icons.business_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            inputFormatters: [FirstLetterCapitalFormatter()],
                          ),
                          CustomTextField(
                            label: 'GSTIN (Tax ID)',
                            hintText: 'Enter registration number',
                            controller: gstinController,
                            icon: Icons.badge_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Contact Information', Icons.contact_phone_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          CustomTextField(
                            label: 'Contact Person',
                            hintText: 'Representative name',
                            controller: nameController,
                            icon: Icons.person_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            inputFormatters: [FirstLetterCapitalFormatter()],
                          ),
                          CustomTextField(
                            label: 'Mobile Number',
                            hintText: '10-digit number',
                            controller: phoneController,
                            icon: Icons.phone_android_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          CustomTextField(
                            label: 'Corporate Email',
                            hintText: 'vendor@company.com',
                            controller: emailController,
                            icon: Icons.alternate_email_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Operational Location', Icons.map_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          CustomTextField(
                            label: 'Office Address',
                            hintText: 'Locality, Street',
                            controller: billingAddress1Controller,
                            icon: Icons.home_work_rounded,
                            maxLines: 2,
                            inputFormatters: [FirstLetterCapitalFormatter()],
                          ),
                          CustomSearchableDropDown<dynamic>(
                            label: 'State',
                            hintText: 'Select operational state',
                            items: _locationController.states,
                            itemAsString: (s) => s['name'],
                            selectedItem: selectedStateObj,
                            prefixIcon: Icons.map_rounded,
                            isRequired: true,
                            onChanged: (val) {
                              setState(() {
                                selectedStateObj = val;
                                selectedCityObj = null;
                                stateController.text = val?['name'] ?? '';
                                cityController.text = '';
                              });
                              if (val != null) _locationController.fetchCitiesByState(val['id']);
                            },
                          ),
                          Obx(() => CustomSearchableDropDown<dynamic>(
                            label: 'City',
                            hintText: selectedStateObj == null ? 'Select State First' : 'Operational city',
                            items: _locationController.filteredCities.toList(),
                            itemAsString: (c) => c['name'],
                            selectedItem: selectedCityObj,
                            prefixIcon: Icons.location_city_rounded,
                            isRequired: true,
                            showAddButton: selectedStateObj != null,
                            onAddPressed: () => _showAddCityDialog(),
                            onChanged: (val) {
                              setState(() {
                                selectedCityObj = val;
                                cityController.text = val?['name'] ?? '';
                              });
                            },
                          )),
                          CustomTextField(
                            label: 'Postal Code',
                            hintText: 'Pincode',
                            controller: pincodeController,
                            icon: Icons.pin_drop_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          buttonText: 'REGISTER VENDOR PARTNER',
                          onTap: _submitForm,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey[800]),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildResponsiveLayout({required bool isDesktop, required List<Widget> children}) {
    if (isDesktop) {
      return Wrap(
        spacing: 20,
        runSpacing: 5,
        children: children.map((child) => SizedBox(width: 470, child: child)).toList(),
      );
    }
    return Column(children: children);
  }

  void _showAddCityDialog() {
    final newCityController = TextEditingController();
    Get.defaultDialog(
      title: 'Update Global Repository',
      content: Padding(
        padding: const EdgeInsets.all(10),
        child: CustomTextField(
          label: 'New City Name',
          hintText: 'Enter city name',
          controller: newCityController,
          icon: Icons.add_location_alt_rounded,
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800]),
        onPressed: () async {
          if (newCityController.text.isNotEmpty && selectedStateObj != null) {
            await _locationController.addCity(newCityController.text.trim(), selectedStateObj['id']);
            Get.back();
            CustomAlert.success('Geography updated.');
          }
        },
        child: const Text('Add to Database', style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }
}
