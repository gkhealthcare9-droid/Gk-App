import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/CustomAlert.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import '../../Controllers/AuthController/ProfileController.dart';
import '../../Controllers/Leads/Leads_Controller.dart';
import '../../Models/Leads/Leads_Model.dart';
import '../Widgets/CustomAppBar.dart';
import '../../Controllers/Location/Location_controller.dart';
import '../Widgets/CustomSearchableDropDown.dart';
import '../Widgets/CustomTextField.dart';
import 'All_Leads_Screen.dart';

class EditLeadScreen extends StatefulWidget {
  final LeadModel lead;

  const EditLeadScreen({super.key, required this.lead});

  @override
  State<EditLeadScreen> createState() => _EditLeadScreenState();
}

class _EditLeadScreenState extends State<EditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeadController _leadController = Get.find<LeadController>();
  final ProfileController _profileController = Get.put(ProfileController());
  final CustomerController _customerController = Get.put(CustomerController());
  final LocationController _locationController = Get.put(LocationController());

  // Text Controllers
  TextEditingController uniqueId = TextEditingController(text: 'GK');
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController positionCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController companyCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController sourceCtrl;
  late TextEditingController leadValueCtrl;
  TextEditingController assignedCtrl = TextEditingController();

  final FocusNode uniqueIdFocus = FocusNode();
  String? selectedCategoryId;
  String selectedLeadType = '';
  String selectedStatus = '';

  dynamic selectedStateObj;
  dynamic selectedCityObj;

  final List<String> _leadTypes = ['Hot', 'Cold', 'Warm'];
  final List<String> _statuses = ['New', 'Open', 'Closed'];

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;

    // Initialize controllers with lead data
    nameCtrl = TextEditingController(text: lead.name);
    emailCtrl = TextEditingController(text: lead.email);
    phoneCtrl = TextEditingController(text: lead.phone);
    addressCtrl = TextEditingController(text: lead.address);
    positionCtrl = TextEditingController(text: lead.position);
    cityCtrl = TextEditingController(text: lead.city);
    stateCtrl = TextEditingController(text: lead.state);
    companyCtrl = TextEditingController(text: lead.company);
    descriptionCtrl = TextEditingController(text: lead.description);
    sourceCtrl = TextEditingController(text: lead.source);
    leadValueCtrl = TextEditingController(
      text: lead.leadValue?.toString() ?? '',
    );
    assignedCtrl.text = lead.assigned?.id ?? '';

    // Initialize dropdowns
    selectedLeadType = lead.leadType ?? _leadTypes.first;
    if (!_leadTypes.contains(selectedLeadType)) {
      selectedLeadType = _leadTypes.first;
    }
    selectedStatus = (lead.status ?? 'New').toLowerCase();
    if (!_statuses.map((s) => s.toLowerCase()).contains(selectedStatus)) {
      selectedStatus = _statuses.first.toLowerCase();
    }

    // Set initial customer found state based on lead data
    _customerController.isCustomerFound.value =
        lead.name != null ||
        lead.email != null ||
        lead.phone != null ||
        lead.address != null ||
        lead.city != null ||
        lead.state != null ||
        lead.company != null;

    // Fetch categories and users
    _profileController.fetchUsers().then((_) {
      if (_profileController.users.isNotEmpty) {
        setState(() {
          if (assignedCtrl.text.isEmpty) {
            assignedCtrl.text = _profileController.users.first.id;
          }
        });
      }
    });
    _customerController.fetchCategories().then((_) {
      if (_customerController.categoryList.isNotEmpty) {
        setState(() {
          selectedCategoryId = _customerController.categoryList.first.id;
        });
      }
    });
    _locationController.fetchStates().then((_) {
      _matchLocationObjects(stateCtrl.text, cityCtrl.text);
    });

    // Add listener to uniqueId
    uniqueId.addListener(() {
      final text = uniqueId.text;
      final cursorPosition = uniqueId.selection.baseOffset;

      // Ensure text starts with 'GK'
      if (!text.startsWith('GK')) {
        String newText = 'GK${text.replaceFirst(RegExp(r'^[^GK]*'), '')}';
        uniqueId.text = newText;
        int newCursorPosition =
            cursorPosition < 2
                ? 2
                : cursorPosition + (newText.length - text.length);
        uniqueId.selection = TextSelection.fromPosition(
          TextPosition(offset: newCursorPosition.clamp(0, newText.length)),
        );
      }

      if (text.length > 2) {
        clearCustomerFields();
        fetchCustomer(text);
      }
    });
  }

  @override
  void dispose() {
    uniqueId.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    positionCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    companyCtrl.dispose();
    descriptionCtrl.dispose();
    sourceCtrl.dispose();
    leadValueCtrl.dispose();
    assignedCtrl.dispose();
    uniqueIdFocus.dispose();
    super.dispose();
  }

  void _showAddCityDialog() {
    final cityController = TextEditingController();
    Get.defaultDialog(
      title: 'Global Repository Update',
      content: Padding(
          padding: const EdgeInsets.all(10),
          child: CustomTextField(
              label: 'New City Name',
              hintText: 'Enter city name',
              controller: cityController,
              icon: Icons.add_location_alt_rounded)),
      confirm: ElevatedButton(
        onPressed: () async {
          if (cityController.text.isNotEmpty && selectedStateObj != null) {
            await _locationController.addCity(
                cityController.text.trim(), selectedStateObj['id']);
            Get.back();
            CustomAlert.success('Geography updated.');
          }
        },
        child: const Text('Register City'),
      ),
      cancel:
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedLead = PostLead(
        name: nameCtrl.text,
        email: emailCtrl.text,
        phone: phoneCtrl.text,
        address: addressCtrl.text,
        position: selectedCategoryId ?? positionCtrl.text,
        city: cityCtrl.text,
        assigned: assignedCtrl.text,
        state: stateCtrl.text,
        company: companyCtrl.text,
        description: descriptionCtrl.text,
        source: sourceCtrl.text,
        leadType: selectedLeadType,
        status: selectedStatus.toLowerCase(),
        leadValue:
            leadValueCtrl.text.isEmpty
                ? null
                : int.tryParse(leadValueCtrl.text), category: '',
      );

      final success = await _leadController.updateLead(
        widget.lead.id!,
        updatedLead,
      );
      if (success) {
        CustomAlert.success('Lead updated successfully');
        await Future.delayed(const Duration(seconds: 2));
        Get.off(() => const LeadsScreen());
      } else {
        CustomAlert.error('Update failed');
      }
    }
  }

  void _matchLocationObjects(String? stateName, String? cityName) {
    if (stateName != null && stateName.isNotEmpty) {
      final sm = _locationController.states
          .firstWhereOrNull((s) => s['name'] == stateName);
      if (sm != null) {
        setState(() => selectedStateObj = sm);
        _locationController.fetchCitiesByState(sm['id']).then((_) {
          if (cityName != null && cityName.isNotEmpty) {
            setState(() {
              selectedCityObj = _locationController.filteredCities
                  .firstWhereOrNull((c) => c['name'] == cityName);
            });
          }
        });
      }
    }
  }

  Future<void> fetchCustomer(String code) async {
    final hadFocus = uniqueIdFocus.hasFocus;
    final selection = uniqueId.selection;

    await _customerController.fetchCustomerByUnique(code.toUpperCase());
    setState(() {
      if (_customerController.customer.value.customerName != null &&
          _customerController.isCustomerFound.value) {
        final c = _customerController.customer.value;
        nameCtrl.text = c.customerName ?? '';
        emailCtrl.text = c.customerEmail ?? '';
        phoneCtrl.text = c.customerPhone ?? '';
        addressCtrl.text = c.addressOne ?? '';
        cityCtrl.text = c.city ?? '';
        stateCtrl.text = c.state ?? '';
        companyCtrl.text = c.customerCompany ?? '';

        _matchLocationObjects(c.state, c.city);
        _customerController.isCustomerFound.value = true;
      } else {
        clearCustomerFields();
        _customerController.isCustomerFound.value = false;
      }
    });

    if (hadFocus) {
      uniqueIdFocus.requestFocus();
      uniqueId.selection = selection;
    }
  }

  void clearCustomerFields() {
    setState(() {
      nameCtrl.clear();
      emailCtrl.clear();
      phoneCtrl.clear();
      addressCtrl.clear();
      cityCtrl.clear();
      stateCtrl.clear();
      companyCtrl.clear();
      selectedStateObj = null;
      selectedCityObj = null;
      _customerController.isCustomerFound.value = false;
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    FocusNode? focusNode,
    bool isMultiLine = false,
    bool floatLabel = false,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        maxLines: isMultiLine ? 3 : 1,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              prefixIcon != null
                  ? Icon(
                    prefixIcon,
                    color: Theme.of(context).colorScheme.primary,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          errorStyle: const TextStyle(fontSize: 12.0),
          floatingLabelBehavior:
              floatLabel
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.auto,
        ),
        validator:
            isRequired
                ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
                : validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Lead',
      ),
      body: Obx(() {
        return _leadController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead Details',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // 🆔 Unique ID
                      Obx(() {
                        return Stack(
                          children: [
                            _buildTextField(
                              label: 'Unique ID',
                              controller: uniqueId,
                              prefixIcon: Icons.code,
                              focusNode: uniqueIdFocus,
                              isRequired: false,
                            ),
                            if (_customerController.isLoading.value)
                              const Positioned(
                                right: 10,
                                top: 20,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),

                      // 🧾 Customer Details Card
                      Obx(() {
                        if (_customerController.isCustomerFound.value ||
                            nameCtrl.text.isNotEmpty ||
                            emailCtrl.text.isNotEmpty ||
                            phoneCtrl.text.isNotEmpty ||
                            addressCtrl.text.isNotEmpty ||
                            cityCtrl.text.isNotEmpty ||
                            stateCtrl.text.isNotEmpty ||
                            companyCtrl.text.isNotEmpty) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Company', companyCtrl.text),
                                  _buildInfoRow('Name', nameCtrl.text),
                                  _buildInfoRow('Email', emailCtrl.text),
                                  _buildInfoRow('Phone', phoneCtrl.text),
                                  _buildInfoRow('Address', addressCtrl.text),
                                  _buildInfoRow('City', cityCtrl.text),
                                  _buildInfoRow('State', stateCtrl.text),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      // 🎯 Position (Dropdown from category)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Obx(() {
                          return DropdownButtonFormField<String>(
                            value: selectedCategoryId,
                            items:
                                _customerController.categoryList.map((
                                  category,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Text(category.position ?? 'Unnamed'),
                                  );
                                }).toList(),
                            onChanged:
                                (value) =>
                                    setState(() => selectedCategoryId = value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Position',
                              prefixIcon: Icon(
                                Icons.work,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLowest,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 16.0,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          );
                        }),
                      ),

                      // 👤 Assigned To
                      Obx(() {
                        return _profileController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                              value:
                                  assignedCtrl.text.isNotEmpty
                                      ? assignedCtrl.text
                                      : null,
                              items:
                                  _profileController.users.map((user) {
                                    return DropdownMenuItem<String>(
                                      value: user.id,
                                      child: Text(user.name ?? 'Unnamed User'),
                                    );
                                  }).toList(),
                              onChanged:
                                  (value) => assignedCtrl.text = value ?? '',
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please assign a user'
                                          : null,
                              decoration: InputDecoration(
                                labelText: 'Assigned To',
                                prefixIcon: Icon(
                                  Icons.person_add,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLowest,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 16.0,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                            );
                      }),

                      // ℹ️ Status
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value:
                              selectedStatus.isNotEmpty ? selectedStatus : null,
                          items:
                              _statuses.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status.toLowerCase(),
                                  child: Text(status),
                                );
                              }).toList(),
                          onChanged:
                              (value) =>
                                  setState(() => selectedStatus = value ?? ''),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select a status'
                                      : null,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(
                              Icons.info,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),

                      // 💰 Lead Value
                      _buildTextField(
                        label: 'Lead Value',
                        controller: leadValueCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                        floatLabel: true,
                        isRequired: false,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),

                      // 📝 Location Selectors
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
                            stateCtrl.text = val?['name'] ?? '';
                            cityCtrl.text = '';
                          });
                          if (val != null) {
                            _locationController.fetchCitiesByState(val['id']);
                          }
                        },
                      ),
                      Obx(() => CustomSearchableDropDown<dynamic>(
                        label: 'City',
                        hintText: selectedStateObj == null
                            ? 'Select State First'
                            : 'Search City',
                        items: _locationController.filteredCities.toList(),
                        itemAsString: (c) => c['name'],
                        selectedItem: selectedCityObj,
                        prefixIcon: Icons.location_city_rounded,
                        isRequired: true,
                        onAddPressed: () => _showAddCityDialog(),
                        onChanged: (val) {
                          setState(() {
                            selectedCityObj = val;
                            cityCtrl.text = val?['name'] ?? '';
                          });
                        },
                      )),
                      _buildTextField(
                        label: 'Description',
                        controller: descriptionCtrl,
                        prefixIcon: Icons.description,
                        isMultiLine: true,
                        floatLabel: true,
                      ),

                      // 📡 Source
                      _buildTextField(
                        label: 'Source',
                        controller: sourceCtrl,
                        prefixIcon: Icons.source,
                        floatLabel: true,
                      ),

                      // 🔥 Lead Type
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value:
                              selectedLeadType.isNotEmpty
                                  ? selectedLeadType
                                  : null,
                          items:
                              _leadTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(
                                () => selectedLeadType = value ?? '',
                              ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select a lead type'
                                      : null,
                          decoration: InputDecoration(
                            labelText: 'Lead Type',
                            prefixIcon: Icon(
                              Icons.category,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // ✅ Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _leadController.isLoading.value ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            elevation: 2,
                          ),
                          child:
                              _leadController.isLoading.value
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                  : const Text(
                                    'Update Lead',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
      }),
    );
  }
}
