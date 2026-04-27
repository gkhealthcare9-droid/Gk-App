import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import '../Widgets/CustomAppBar.dart';
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
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Customer' : 'Add Customer',
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
                    _buildSectionHeader('Customer Information', Icons.person_add_rounded),
                    CustomTextField(
                      label: 'Customer Name',
                      hintText: 'Enter customer name',
                      controller: nameController,
                      icon: Icons.person_rounded,
                      isRequired: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Phone',
                      hintText: 'Enter phone number',
                      controller: phoneController,
                      icon: Icons.call_rounded,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length != 10) return 'Must be 10 digits';
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Enter email address',
                      controller: emailController,
                      icon: Icons.email_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Hospital Name',
                      hintText: 'Enter hospital / clinic name',
                      controller: companyController,
                      icon: Icons.local_hospital_rounded,
                      isRequired: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'GSTIN',
                      hintText: 'Enter GST number',
                      controller: gstinController,
                      icon: Icons.badge_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Address',
                      hintText: 'Enter full address',
                      controller: billingAddress1Controller,
                      icon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: isEditing ? 'UPDATE CUSTOMER' : 'ADD CUSTOMER',
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
      CustomAlert.error("Please verify all mandatory corporate fields correctly.");
      return;
    }

    final phone2 = phoneController2.text.trim();
    if (phone2.isNotEmpty) {
       if (phone2.length != 10) {
        CustomAlert.error("Alternative contact must be 10 digits.");
        return;
      }
      if (!RegExp(r'^[6-9]').hasMatch(phone2)) {
        CustomAlert.error("Alternative contact must start with 6, 7, 8, or 9.");
        return;
      }
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
