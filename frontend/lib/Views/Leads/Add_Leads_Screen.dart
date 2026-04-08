import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import '../../Controllers/AuthController/ProfileController.dart';
import '../../Controllers/Leads/Leads_Controller.dart';
import '../../Controllers/Product/Product.dart';
import '../../Models/Leads/Leads_Model.dart';
import '../Widgets/CustomSearchableDropDown.dart';
import 'All_Leads_Screen.dart';
import '../../Controllers/Location/Location_controller.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomAlert.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomBackButton.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  String? selectedCategoryId;
  final _formKey = GlobalKey<FormState>();
  final LeadController _leadController = Get.put(LeadController());
  final ProfileController _profileController = Get.put(ProfileController());
  final ProductController _productController = Get.put(ProductController());
  final CustomerController _customerController = Get.put(CustomerController());
  final LocationController _locationController = Get.put(LocationController());

  // Text Controllers
  final TextEditingController uniqueId = TextEditingController(text: 'GK');
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController position = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController company = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController source = TextEditingController();
  final TextEditingController leadType = TextEditingController();
  final TextEditingController leadValue = TextEditingController(text: '0');
  final TextEditingController assigned = TextEditingController();
  final TextEditingController status = TextEditingController();
  String? selectedCategory;

  final FocusNode uniqueIdFocus = FocusNode();

  dynamic selectedStateObj;
  dynamic selectedCityObj;

  // List of lead types and statuses for dropdowns
  final List<String> _leadTypes = ['Hot', 'Cold', 'Warm'];
  final List<String> _statuses = ['New', 'Open', 'Closed'];

  @override
  void initState() {
    super.initState();
    _profileController.fetchUsers();
    _productController.fetchCategories();
    _locationController.fetchStates();

    // Set default values
    if (_leadTypes.isNotEmpty) leadType.text = _leadTypes.first;
    if (_statuses.isNotEmpty) status.text = _statuses.first;

    _profileController.fetchUsers().then((_) {
      if (_profileController.users.isNotEmpty) {
        setState(() => assigned.text = _profileController.users.first.id);
      }
    });
    _customerController.fetchCategories().then((_) {
      if (_customerController.categoryList.isNotEmpty) {
        setState(() => selectedCategoryId = _customerController.categoryList.first.id);
      }
    });

    uniqueId.addListener(() {
      final text = uniqueId.text.toUpperCase();
      if (!text.startsWith('GK')) {
        uniqueId.text = 'GK';
        uniqueId.selection = TextSelection.fromPosition(TextPosition(offset: uniqueId.text.length));
      }
      if (text.length > 2) {
        fetchCustomer(text);
      } else {
        clearCustomerFields();
      }
    });
  }

  @override
  void dispose() {
    uniqueId.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    position.dispose();
    city.dispose();
    state.dispose();
    country.dispose();
    pincode.dispose();
    company.dispose();
    description.dispose();
    source.dispose();
    leadType.dispose();
    leadValue.dispose();
    assigned.dispose();
    status.dispose();
    uniqueIdFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final leadValueInt = int.tryParse(leadValue.text);

      final postLead = PostLead(
        name: name.text,
        category: selectedCategory ?? '',
        email: email.text,
        phone: phone.text,
        address: address.text,
        position: selectedCategoryId ?? '',
        city: city.text,
        assigned: assigned.text,
        state: state.text,
        country: country.text,
        pincode: pincode.text,
        company: company.text,
        description: description.text,
        source: source.text,
        leadType: leadType.text,
        status: status.text.toLowerCase(),
        leadValue: leadValueInt,
      );

      _leadController.addLead(postLead).then((_) {
        if (_leadController.errorMessage.value.isEmpty) {
          Get.off(() => const LeadsScreen());
          CustomAlert.success('Lead recorded successfully.');
        }
      });
    }
  }

  Future<void> fetchCustomer(String code) async {
    final selection = uniqueId.selection;
    await _customerController.fetchCustomerByUnique(code);
    
    if (_customerController.customer.value.customerName != null &&
        _customerController.isCustomerFound.value) {
      final c = _customerController.customer.value;
      setState(() {
        name.text = c.customerName ?? '';
        email.text = c.customerEmail ?? '';
        phone.text = c.customerPhone ?? '';
        address.text = c.addressOne ?? '';
        city.text = c.city ?? '';
        state.text = c.state ?? '';
        pincode.text = c.pincode ?? '';
        company.text = c.customerCompany ?? '';
        
        // Match selection objects for dropdowns
        _matchLocationObjects(c.state, c.city);
      });
    } else {
      clearCustomerFields();
    }
    uniqueId.selection = selection;
  }

  void _matchLocationObjects(String? stateName, String? cityName) {
    if (stateName != null) {
      final sm = _locationController.states.firstWhereOrNull((s) => s['name'] == stateName);
      if (sm != null) {
        setState(() => selectedStateObj = sm);
        _locationController.fetchCitiesByState(sm['id']).then((_) {
          if (cityName != null) {
            setState(() {
              selectedCityObj = _locationController.filteredCities.firstWhereOrNull((c) => c['name'] == cityName);
            });
          }
        });
      }
    }
  }

  void clearCustomerFields() {
    setState(() {
      name.clear();
      email.clear();
      phone.clear();
      address.clear();
      city.clear();
      state.clear();
      pincode.clear();
      company.clear();
      selectedStateObj = null;
      selectedCityObj = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: CustomBackButton(onTap: () => Get.back()),
        title: const Text('NEW BUSINESS LEAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (_leadController.isLoading.value) {
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
                      _buildSectionHeader('Customer Identification', Icons.fingerprint_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          _buildUniqueIdField(),
                          CustomTextField(
                            label: 'Corporate Entity',
                            hintText: 'Enter company / clinic name',
                            controller: company,
                            icon: Icons.business_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      _buildSectionHeader('Contact Information', Icons.contact_mail_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          CustomTextField(label: 'Contact Person', hintText: 'Primary representative', controller: name, icon: Icons.person_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                          CustomTextField(label: 'Mobile Number', hintText: '10-digit number', controller: phone, icon: Icons.phone_android_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                          CustomTextField(label: 'Email Address', hintText: 'reports@customer.com', controller: email, icon: Icons.alternate_email_rounded),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Lead Classification & Value', Icons.analytics_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          _buildCategoryDropdown(),
                          _buildProfileDropdown(),
                          CustomTextField(label: 'Estimated Value', hintText: 'Ex: 50000', controller: leadValue, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                          _buildLeadTypeDropdown(),
                          _buildAssignedDropdown(),
                          _buildStatusDropdown(),
                          CustomTextField(label: 'Lead Source', hintText: 'Ex: Referral, Web', controller: source, icon: Icons.campaign_rounded),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionHeader('Location & Logistics', Icons.map_rounded),
                      _buildResponsiveLayout(
                        isDesktop: isDesktop,
                        children: [
                          CustomTextField(label: 'Full Address', hintText: 'Locality, Street', controller: address, icon: Icons.home_work_rounded, maxLines: 2),
                          CustomSearchableDropDown<dynamic>(
                            label: 'State',
                            hintText: 'Select India State',
                            items: _locationController.states,
                            itemAsString: (s) => s['name'],
                            selectedItem: selectedStateObj,
                            prefixIcon: Icons.map_rounded,
                            isRequired: true,
                            onChanged: (val) {
                              setState(() {
                                selectedStateObj = val;
                                selectedCityObj = null;
                                state.text = val?['name'] ?? '';
                                city.text = '';
                              });
                              if (val != null) _locationController.fetchCitiesByState(val['id']);
                            },
                          ),
                          Obx(() => CustomSearchableDropDown<dynamic>(
                            label: 'City',
                            hintText: selectedStateObj == null ? 'Select State First' : 'Search City',
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
                                city.text = val?['name'] ?? '';
                              });
                            },
                          )),
                          CustomTextField(label: 'Zip Code', hintText: '6-digit code', controller: pincode, icon: Icons.pin_drop_rounded),
                        ],
                      ),

                      const SizedBox(height: 20),
                      CustomTextField(label: 'Requirement Details', hintText: 'Specify needs...', controller: description, icon: Icons.description_rounded, maxLines: 3),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          buttonText: 'SUBMIT BUSINESS LEAD',
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
          Icon(icon, size: 20, color: Colors.lightBlue[800]),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.lightBlue[900])),
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

  Widget _buildUniqueIdField() {
    return Obx(() => Stack(
      children: [
        CustomTextField(
          label: 'Client ID / Unique Code',
          hintText: 'Ex: GK101',
          controller: uniqueId,
          icon: Icons.qr_code_scanner_rounded,
          focusNode: uniqueIdFocus,
        ),
        if (_customerController.isLoading.value)
          const Positioned(right: 15, top: 35, child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      ],
    ));
  }

  Widget _buildCategoryDropdown() {
    return Obx(() => CustomSearchableDropDown<dynamic>(
      label: 'Product Category',
      hintText: 'Select category',
      items: _productController.categories.toList(),
      itemAsString: (c) => c.productCategory ?? 'Unnamed',
      selectedItem: _productController.categories.firstWhereOrNull((c) => c.id == selectedCategory),
      prefixIcon: Icons.shopping_basket_rounded,
      isRequired: true,
      onChanged: (val) => setState(() => selectedCategory = val?.id),
    ));
  }

  Widget _buildProfileDropdown() {
    return Obx(() => CustomSearchableDropDown<dynamic>(
      label: 'Designation / Profile',
      hintText: 'Select designation',
      items: _customerController.categoryList.toList(),
      itemAsString: (c) => c.category ?? 'Unnamed',
      selectedItem: _customerController.categoryList.firstWhereOrNull((c) => c.id == selectedCategoryId),
      prefixIcon: Icons.badge_rounded,
      isRequired: true,
      onChanged: (val) => setState(() => selectedCategoryId = val?.id),
    ));
  }

  Widget _buildLeadTypeDropdown() {
    return CustomSearchableDropDown<String>(
      label: 'Engagement Intensity',
      hintText: 'Select intensity',
      items: _leadTypes,
      itemAsString: (s) => s,
      selectedItem: leadType.text,
      prefixIcon: Icons.whatshot_rounded,
      onChanged: (val) => setState(() => leadType.text = val ?? ''),
    );
  }

  Widget _buildStatusDropdown() {
    return CustomSearchableDropDown<String>(
      label: 'Current Status',
      hintText: 'Select status',
      items: _statuses,
      itemAsString: (s) => s,
      selectedItem: status.text,
      prefixIcon: Icons.info_outline_rounded,
      onChanged: (val) => setState(() => status.text = val ?? ''),
    );
  }

  Widget _buildAssignedDropdown() {
    return Obx(() => CustomSearchableDropDown<dynamic>(
      label: 'Account Manager',
      hintText: 'Select manager',
      items: _profileController.users.toList(),
      itemAsString: (u) => u.name ?? 'Unnamed',
      selectedItem: _profileController.users.firstWhereOrNull((u) => u.id == assigned.text),
      prefixIcon: Icons.person_pin_rounded,
      onChanged: (val) => setState(() => assigned.text = val?.id ?? ''),
    ));
  }

  void _showAddCityDialog() {
    final cityController = TextEditingController();
    Get.defaultDialog(
      title: 'Global Repository Update',
      content: Padding(padding: const EdgeInsets.all(10), child: CustomTextField(label: 'New City Name', hintText: 'Enter city name', controller: cityController, icon: Icons.add_location_alt_rounded)),
      confirm: ElevatedButton(
        onPressed: () async {
          if (cityController.text.isNotEmpty && selectedStateObj != null) {
            await _locationController.addCity(cityController.text.trim(), selectedStateObj['id']);
            Get.back();
            CustomAlert.success('Geography updated.');
          }
        },
        child: const Text('Register City'),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }
}
