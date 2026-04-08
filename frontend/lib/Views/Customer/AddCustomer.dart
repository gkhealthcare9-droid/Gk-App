import 'package:flutter/material.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:get/get.dart';
import '../../Models/Customer/Customer.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomAlert.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomSearchableDropDown.dart';
import '../Widgets/CustomBackButton.dart';
import '../../Controllers/Location/Location_controller.dart';

class AddCustomerScreen extends StatefulWidget {
  final String? index;

  const AddCustomerScreen({super.key, this.index});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerController _customerController = Get.find<CustomerController>();
  final LocationController _locationController = Get.put(LocationController());
  
  final TextEditingController nameController               = TextEditingController();
  final TextEditingController phoneController              = TextEditingController();
  final TextEditingController phoneController2             = TextEditingController();
  final TextEditingController emailController              = TextEditingController();
  final TextEditingController gstinController              = TextEditingController();
  final TextEditingController companyController            = TextEditingController();
  final TextEditingController billingAddress1Controller    = TextEditingController();
  final TextEditingController billingAddress2Controller    = TextEditingController();
  final TextEditingController billingCityController        = TextEditingController();
  final TextEditingController billingStateController       = TextEditingController();
  final TextEditingController billingPincodeController     = TextEditingController();

  dynamic selectedState;
  dynamic selectedCity;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      final customer = _customerController.customers
          .firstWhereOrNull((c) => c.id == widget.index);
      if (customer == null) {
        CustomAlert.error('Customer identity not found in database.');
        Get.back();
        return;
      }
      nameController.text               = customer.customerName ?? '';
      phoneController.text              = customer.customerPhone ?? '';
      phoneController2.text             = customer.customerPhone2 ?? '';
      emailController.text              = customer.customerEmail ?? '';
      gstinController.text              = customer.customerGSTIN ?? '';
      companyController.text            = customer.customerCompany ?? '';
      billingAddress1Controller.text    = customer.addressOne ?? '';
      billingCityController.text        = customer.city ?? '';
      billingStateController.text       = customer.state ?? '';
      billingPincodeController.text     = customer.pincode ?? '';
      
      // Initialize dropdown selections
      _initializeSelections(customer.state, customer.city);

      Future.delayed(Duration.zero, () {
        _customerController.fetchEmployees(customer.id!);
      });
    }
  }

  void _initializeSelections(String? stateName, String? cityName) {
    if (stateName != null) {
      // Find state object
      Future.delayed(Duration.zero, () async {
        if (_locationController.states.isEmpty) await _locationController.fetchStates();
        final state = _locationController.states.firstWhereOrNull((s) => s['name'] == stateName);
        if (state != null) {
          setState(() => selectedState = state);
          await _locationController.fetchCitiesByState(state['id']);
          if (cityName != null) {
            final city = _locationController.filteredCities.firstWhereOrNull((c) => c['name'] == cityName);
            setState(() => selectedCity = city);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    phoneController2.dispose();
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
    final isEditing = widget.index != null;
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: CustomBackButton(onTap: () => Get.back()),
        title: Text(isEditing ? 'MODIFY CUSTOMER PROFILE' : 'NEW CUSTOMER REGISTRATION', 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (_customerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('General Information', Icons.business_rounded),
                    _buildResponsiveLayout(
                      isDesktop: isDesktop,
                      children: [
                        CustomTextField(
                          label: 'Corporate Identity',
                          hintText: 'Enter company / clinic name',
                          controller: companyController,
                          icon: Icons.business_rounded,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        CustomTextField(
                          label: 'Lead Contact Name',
                          hintText: 'Enter primary representative',
                          controller: nameController,
                          icon: Icons.person_rounded,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        CustomTextField(
                          label: 'Official Email',
                          hintText: 'communications@customer.com',
                          controller: emailController,
                          icon: Icons.email_rounded,
                        ),
                        CustomTextField(
                          label: 'Taxation ID (GSTIN)',
                          hintText: 'Business registration ID',
                          controller: gstinController,
                          icon: Icons.badge_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Connectivity Details', Icons.contact_phone_rounded),
                    _buildResponsiveLayout(
                      isDesktop: isDesktop,
                      children: [
                        CustomTextField(
                          label: 'Mobile Connectivity',
                          hintText: 'Enter 10-digit number',
                          controller: phoneController,
                          icon: Icons.call_rounded,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        CustomTextField(
                          label: 'Alternative Contact',
                          hintText: 'Secondary number (Optional)',
                          controller: phoneController2,
                          icon: Icons.call_merge_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Operational HQ & Zonal Data', Icons.location_on_rounded),
                    _buildResponsiveLayout(
                      isDesktop: isDesktop,
                      children: [
                        CustomTextField(
                          label: 'Operational Address',
                          hintText: 'Building, floor, locality',
                          controller: billingAddress1Controller,
                          icon: Icons.location_on_rounded,
                        ),
                        CustomSearchableDropDown<dynamic>(
                          label: 'Zonal State',
                          hintText: 'Select India State',
                          items: _locationController.states,
                          itemAsString: (s) => s['name'],
                          selectedItem: selectedState,
                          prefixIcon: Icons.map_rounded,
                          isRequired: true,
                          onChanged: (val) {
                            setState(() {
                              selectedState = val;
                              selectedCity = null;
                              billingStateController.text = val?['name'] ?? '';
                              billingCityController.text = '';
                            });
                            if (val != null) {
                              _locationController.fetchCitiesByState(val['id']);
                            }
                          },
                        ),
                        Obx(() => CustomSearchableDropDown<dynamic>(
                          label: 'Operational City',
                          hintText: selectedState == null ? 'Select State First' : 'Search City',
                          items: _locationController.filteredCities.toList(),
                          itemAsString: (c) => c['name'],
                          selectedItem: selectedCity,
                          prefixIcon: Icons.location_city_rounded,
                          isRequired: true,
                          showAddButton: selectedState != null,
                          onAddPressed: () => _showAddCityDialog(),
                          onChanged: (val) {
                            setState(() {
                              selectedCity = val;
                              billingCityController.text = val?['name'] ?? '';
                            });
                          },
                        )),
                        CustomTextField(
                          label: 'Postal Pincode',
                          hintText: 'Enter region code',
                          controller: billingPincodeController,
                          icon: Icons.pin_drop_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: isEditing ? 'UPDATE PARTNERSHIP' : 'ENROLL CUSTOMER',
                        onTap: _submitForm,
                      ),
                    ),
                  ],
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
          Icon(icon, size: 20, color: Colors.blue[800]),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
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
    final cityController = TextEditingController();
    Get.defaultDialog(
      title: 'Add New City',
      content: Padding(
        padding: const EdgeInsets.all(10),
        child: CustomTextField(
          label: 'City Name',
          controller: cityController,
          hintText: 'Enter city name',
          icon: Icons.location_city,
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (cityController.text.isNotEmpty && selectedState != null) {
            await _locationController.addCity(cityController.text.trim(), selectedState['id']);
            Get.back();
            CustomAlert.success('City added to global repository.');
          }
        },
        child: const Text('Add'),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      CustomAlert.error("Please verify all mandatory corporate fields.");
      return;
    }

    final customer = AddCustomerModel(
      customerName:     nameController.text.trim(),
      customerCompany:  companyController.text.trim(),
      customerPhone:    phoneController.text.trim(),
      customerPhone2:   phoneController2.text.trim().isNotEmpty ? phoneController2.text.trim() : null,
      customerEmail:    emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
      customerGSTIN:    gstinController.text.trim().isNotEmpty ? gstinController.text.trim() : null,
      addressOne:       billingAddress1Controller.text.trim().isNotEmpty ? billingAddress1Controller.text.trim() : null,
      city:             billingCityController.text.trim(),
      state:            billingStateController.text.trim(),
      pincode:          billingPincodeController.text.trim().isNotEmpty ? billingPincodeController.text.trim() : null,
    );

    if (widget.index != null) {
      _customerController.editCustomer(widget.index!, customer);
    } else {
      _customerController.addCustomer(customer);
    }
  }
}
