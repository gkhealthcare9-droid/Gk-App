import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Controllers/AuthController/ProfileController.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Controllers/Report/Report_controller.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/report/GenerateReports/Installation_Report_Model.dart';
import 'package:sales_grow/Models/report/Manufacturer.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:sales_grow/Views/Widgets/CustomButton.dart';
import 'package:sales_grow/Views/Widgets/CustomDropDown.dart';
import 'package:sales_grow/Views/Widgets/CustomSigntaure.dart';
import 'package:signature/signature.dart';
import '../HomeScreen/ReportScreen.dart';
import '../ReportDesign/InstallationReportView.dart';
import '../../Models/CustomerContact/CustomerContactModel.dart';
import '../../Models/product/product_category_model.dart';
import '../../Utils/Colors.dart';
import '../Widgets/CustomAlert.dart';

class InstallationReport extends StatefulWidget {
  const InstallationReport({super.key});

  @override
  State<InstallationReport> createState() => _InstallationReportState();
}

class _InstallationReportState extends State<InstallationReport> {
  final CustomerController _customerController = Get.put(CustomerController());
  final ReportController _reportController = Get.put(ReportController());
  final ProductController _productController = Get.put(ProductController());
  final ProfileController _profileController = Get.put(ProfileController());

  // TextEditing Controllers
  final TextEditingController _uniqueCode = TextEditingController();
  final TextEditingController _slNumberController = TextEditingController();
  final TextEditingController _hospitalName = TextEditingController();
  final TextEditingController _hospitalid = TextEditingController();
  final TextEditingController _hospitalPhone = TextEditingController();
  final TextEditingController _hospitalAddress1 = TextEditingController();
  final TextEditingController _hospitalAddress2 = TextEditingController();
  final TextEditingController _hospitalState = TextEditingController();
  final TextEditingController _hospitalcity = TextEditingController();
  final TextEditingController _hospitalpincode = TextEditingController();
  final TextEditingController _actiontaken = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _signedByController = TextEditingController();
  final TextEditingController _othercontroller = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTime = DateTime.now();
  List<String> selectedRemarks = [];
  DateTime? warrantyEndDate;
  String warrantyDuration = "";
  DateTime warrantyStartDate = DateTime.now();
  String? selectedEmployeeName;

  // Filter-related variables
  final RxString _searchQuery = ''.obs;
  final RxString _selectedState = ''.obs;
  final RxString _selectedCity = ''.obs;
  final RxBool _isCustomerDataLoaded = false.obs;
  final RxBool _showCustomerList = false.obs;
  final GlobalKey _filterSectionKey = GlobalKey();
  final GlobalKey _customerCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _uniqueCode.text = 'GK';
    _fetchCustomers();

    _uniqueCode.addListener(() {
      final text = _uniqueCode.text;
      if (!text.startsWith('GK')) {
        _uniqueCode.text = 'GK';
        _uniqueCode.selection = TextSelection.fromPosition(
          TextPosition(offset: _uniqueCode.text.length),
        );
      }

      if (text.length > 2) {
        clear();
        fetchHospital(text);
      } else {
        clear();
      }
    });

    _searchCtrl.addListener(() {
      _searchQuery.value = _searchCtrl.text;
      _showCustomerList.value =
          _searchQuery.value.isNotEmpty ||
              _selectedState.value.isNotEmpty ||
              _selectedCity.value.isNotEmpty;
    });

    Future.delayed(Duration.zero, () async {
      _productController.fetchCategories();
      _reportController.fetchManufacturer();
      _profileController.fetchProfile();
      _reportController.fetchInstallationReports();
    });
  }

  Future<void> _fetchCustomers() async {
    try {
      await _customerController.fetchCustomers();
      _isCustomerDataLoaded.value = true;
    } catch (e) {
      _isCustomerDataLoaded.value = false;
      CustomAlert.error('Failed to fetch customers: $e');
    }
  }

  List<String> remarks = [
    "Sturdy Table Required",
    "UPS power recommended",
    "Maintain pressure between 25-30 PSI",
  ];

  Future<void> fetchHospital(String unique) async {
    await _customerController.fetchCustomerByUnique(unique.toUpperCase());

    setState(() {
      _hospitalName.text =
          _customerController.customer.value.customerName ?? '';
      _hospitalAddress1.text =
          _customerController.customer.value.addressOne ?? '';
      _hospitalAddress2.text =
          _customerController.customer.value.addressTwo ?? '';
      _hospitalPhone.text =
          _customerController.customer.value.customerPhone ?? '';
      _hospitalcity.text = _customerController.customer.value.city ?? '';
      _hospitalpincode.text = _customerController.customer.value.pincode ?? '';
      _hospitalState.text = _customerController.customer.value.state ?? '';
      _hospitalid.text = _customerController.customer.value.id ?? '';
      _showCustomerList.value = false; // Hide list when customer is fetched
    });

    if (_customerController.customer.value.id != null) {
      await _customerController.fetchEmployees(
        _customerController.customer.value.id!,
      );
    }
  }

  void _showSignaturePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomSignaturePopup(
        controller: _controller,
        onSigned: (signatureBytes, signedByName) {
          if (signatureBytes != null) {
            _signedByController.text = signedByName;
            setState(() {});
          }
        },
      ),
    );
  }

  int _generateReportNumber(int? lastReportNumber) {
    return (lastReportNumber ?? 0) + 1;
  }

  void calculateWarrantyDuration() {
    if (warrantyEndDate != null) {
      final duration = warrantyEndDate!.difference(warrantyStartDate);
      final totalDays = duration.inDays;

      if (totalDays >= 365) {
        final years = (totalDays / 365).floor();
        warrantyDuration = "$years year(s)";
      } else if (totalDays >= 30) {
        final months = (totalDays / 30).floor();
        warrantyDuration = "$months month(s)";
      } else {
        warrantyDuration = "$totalDays day(s)";
      }
    } else {
      warrantyDuration = "";
    }
  }

  void clear() {
    setState(() {
      _hospitalName.clear();
      _hospitalAddress1.clear();
      _hospitalAddress2.clear();
      _hospitalPhone.clear();
      _hospitalcity.clear();
      _hospitalpincode.clear();
      _hospitalState.clear();
      _hospitalid.clear();
      _searchCtrl.clear();
      _selectedState.value = '';
      _selectedCity.value = '';
      _showCustomerList.value = false;
    });
  }

  String? selectedManufacturer;
  String? selectedCategory;
  String? selected;
  List<String> selectedEmployees = [];

  void _askEmployeeName(BuildContext context) {
    String? selectedEmployeeId;

    if (_customerController.employees.isNotEmpty) {
      selectedEmployeeId = _customerController.employees.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Signed Employee"),
          content: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: selectedEmployeeId,
            decoration: InputDecoration(
              hintText: "Select Employee",
              border: OutlineInputBorder(),
            ),
            items: _customerController.employees.map((e) {
              return DropdownMenuItem<String>(
                value: e.id,
                child: Text(e.name ?? 'Unnamed'),
              );
            }).toList(),
            onChanged: (val) {
              selectedEmployeeId = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedEmployeeId != null) {
                  final selectedEmployee = _customerController.employees
                      .firstWhere((e) => e.id == selectedEmployeeId);
                  _signedByController.text = selectedEmployee.name ?? '';
                  setState(() {});
                  Navigator.of(context).pop();
                } else {
                  CustomAlert.error('Please select an employee');
                }
              },
              child: Text("Done"),
            ),
          ],
        );
      },
    );
  }

  List<String> get _allCities {
    final list = _customerController.customers
        .where((c) => _selectedState.value.isEmpty
        ? true
        : (c.state?.toLowerCase() == _selectedState.value.toLowerCase()))
        .map((c) => c.city?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<String> get _allStates {
    final list = _customerController.customers
        .map((c) => c.state?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  bool _matchesSearch(CustomerModel c) {
    final q = _searchQuery.value.toLowerCase();
    return (c.customerQuniqueNumber?.toLowerCase().contains(q) ?? false) ||
        (c.customerName?.toLowerCase().contains(q) ?? false) ||
        (c.customerCompany?.toLowerCase().contains(q) ?? false) ||
        (c.customerEmail?.toLowerCase().contains(q) ?? false) ||
        (c.customerPhone?.toLowerCase().contains(q) ?? false) ||
        (c.customerGSTIN?.toLowerCase().contains(q) ?? false) ||
        (c.addressOne?.toLowerCase().contains(q) ?? false) ||
        (c.addressTwo?.toLowerCase().contains(q) ?? false) ||
        (c.city?.toLowerCase().contains(q) ?? false) ||
        (c.state?.toLowerCase().contains(q) ?? false) ||
        (c.pincode?.toLowerCase().contains(q) ?? false);
  }

  void _selectCustomer(CustomerModel customer) {
    setState(() {
      _uniqueCode.text = customer.customerQuniqueNumber ?? 'GK';
      _hospitalName.text = customer.customerName ?? '';
      _hospitalAddress1.text = customer.addressOne ?? '';
      _hospitalAddress2.text = customer.addressTwo ?? '';
      _hospitalPhone.text = customer.customerPhone ?? '';
      _hospitalcity.text = customer.city ?? '';
      _hospitalpincode.text = customer.pincode ?? '';
      _hospitalState.text = customer.state ?? '';
      _hospitalid.text = customer.id ?? '';
      _showCustomerList.value = false;
      if (customer.id != null) {
        _customerController.fetchEmployees(customer.id!);
      }
    });
  }

  Widget _highlight(String? text) {
    if (text == null || text.isEmpty) return const Text('N/A');
    final query = _searchQuery.value;
    if (query.isEmpty) return Text(text);

    final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) return Text(text);

    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: spans,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      key: _filterSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
                () => Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedState.value.isEmpty ? null : _selectedState.value,
                    decoration: InputDecoration(
                      hintText: 'Filter by State',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All States'),
                      ),
                      ..._allStates.map(
                            (st) => DropdownMenuItem(value: st, child: Text(st)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedState.value = v ?? '';
                        _selectedCity.value = '';
                        _showCustomerList.value =
                            _selectedState.value.isNotEmpty ||
                                _selectedCity.value.isNotEmpty ||
                                _searchQuery.value.isNotEmpty;
                        clear();
                        _uniqueCode.text = 'GK';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCity.value.isEmpty ? null : _selectedCity.value,
                    decoration: InputDecoration(
                      hintText: 'Filter by City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All Cities'),
                      ),
                      ..._allCities.map(
                            (ct) => DropdownMenuItem(value: ct, child: Text(ct)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedCity.value = v ?? '';
                        _showCustomerList.value =
                            _selectedState.value.isNotEmpty ||
                                _selectedCity.value.isNotEmpty ||
                                _searchQuery.value.isNotEmpty;
                        clear();
                        _uniqueCode.text = 'GK';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              prefixIcon: const Icon(Icons.search, size: 22),
              hintText: 'Search customers…',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return Obx(() {
      final filteredCustomers = _customerController.customers.where((c) {
        final matchesSearch = _matchesSearch(c);
        final matchesState = _selectedState.value.isEmpty
            ? true
            : (c.state?.toLowerCase() == _selectedState.value.toLowerCase());
        final matchesCity = _selectedCity.value.isEmpty
            ? true
            : (c.city?.toLowerCase() == _selectedCity.value.toLowerCase());
        return matchesSearch && matchesState && matchesCity;
      }).toList();

      if (_customerController.isLoading.value || !_isCustomerDataLoaded.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.black));
      }
      if (filteredCustomers.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'No Customers Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: filteredCustomers.length,
        itemBuilder: (ctx, i) {
          final c = filteredCustomers[i];
          return InkWell(
            onTap: () => _selectCustomer(c),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    c.customerName?.isNotEmpty ?? false
                        ? c.customerName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: _highlight(c.customerCompany),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildDetailRow(
                    Icons.person,
                    'Name',
                    _highlight(c.customerName),
                  ),
                  _buildDetailRow(
                    Icons.business,
                    'Company Name',
                    _highlight(c.customerCompany),
                  ),
                  _buildDetailRow(
                    Icons.call,
                    'Phone',
                    _highlight(c.customerPhone),
                  ),
                  _buildDetailRow(
                    Icons.email,
                    'Email',
                    _highlight(c.customerEmail),
                  ),
                  _buildDetailRow(
                    Icons.fingerprint,
                    'GSTIN',
                    _highlight(c.customerGSTIN),
                  ),
                  _buildDetailRow(
                    Icons.fingerprint,
                    'Customer ID',
                    _highlight(c.customerQuniqueNumber),
                  ),
                  _buildDetailRow(
                    Icons.home,
                    'Address',
                    _highlight(
                      '${c.addressOne ?? ''}, ${c.addressTwo ?? ''}, ${c.city ?? ''}, ${c.state ?? ''} - ${c.pincode ?? ''}',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildHospitalDetailsContainer() {
    final addressParts = [
      if (_hospitalAddress1.text.isNotEmpty) _hospitalAddress1.text,
      if (_hospitalAddress2.text.isNotEmpty) _hospitalAddress2.text,
      if (_hospitalcity.text.isNotEmpty) _hospitalcity.text,
      if (_hospitalState.text.isNotEmpty) _hospitalState.text,
      if (_hospitalpincode.text.isNotEmpty) _hospitalpincode.text,
    ];
    final address = addressParts.join(', ');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: Offset(2, 2),
            ),
          ],
          border: Border.all(color: Colors.black, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hospitalName.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Name: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _hospitalName.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            if (_hospitalName.text.isNotEmpty) SizedBox(height: 8),
            if (address.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(address, style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            if (address.isNotEmpty) SizedBox(height: 8),
            if (_hospitalPhone.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      _hospitalPhone.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _isTapOutside(TapDownDetails details) {
    final tapPosition = details.globalPosition;
    final filterRenderBox = _filterSectionKey.currentContext?.findRenderObject() as RenderBox?;
    final customerCardRenderBox = _customerCardKey.currentContext?.findRenderObject() as RenderBox?;

    if (filterRenderBox != null) {
      final filterPosition = filterRenderBox.localToGlobal(Offset.zero);
      final filterSize = filterRenderBox.size;
      final filterRect = Rect.fromLTWH(
        filterPosition.dx,
        filterPosition.dy,
        filterSize.width,
        filterSize.height,
      );
      if (filterRect.contains(tapPosition)) {
        return false;
      }
    }

    if (customerCardRenderBox != null) {
      final cardPosition = customerCardRenderBox.localToGlobal(Offset.zero);
      final cardSize = customerCardRenderBox.size;
      final cardRect = Rect.fromLTWH(
        cardPosition.dx,
        cardPosition.dy,
        cardSize.width,
        cardSize.height,
      );
      if (cardRect.contains(tapPosition)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _sendReport() async {
    await _reportController.fetchInstallationReports();
    if (_hospitalName.text.isEmpty) {
      CustomAlert.error('Hospital name is required', title: 'Validation Error');
      return;
    }
    if (_slNumberController.text.isEmpty) {
      CustomAlert.error('Serial number is required', title: 'Validation Error');
      return;
    }
    if (_signedByController.text.isEmpty) {
      CustomAlert.error(
        'Client signature (Signed By) is required',
        title: 'Validation Error',
      );
      return;
    }
    if (selected == 'others' && _othercontroller.text.isEmpty) {
      CustomAlert.error('Please specify the machine status', title: 'Validation Error');
      return;
    }
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      CustomAlert.error('Please select a product category', title: 'Validation Error');
      return;
    }
    if (selectedManufacturer == null || selectedManufacturer!.isEmpty) {
      CustomAlert.error('Please select a manufacturer', title: 'Validation Error');
      return;
    }
    if (_actiontaken.text.isEmpty) {
      CustomAlert.error('Please select action taken', title: 'Validation Error');
      return;
    }
    if (warrantyEndDate == null) {
      CustomAlert.error('Please select warranty end date', title: 'Validation Error');
      return;
    }
    if (selectedEmployees.isEmpty) {
      CustomAlert.error(
        'Please select at least one trained employee',
        title: 'Validation Error',
      );
      return;
    }

    final signatureBytes = await _controller.toPngBytes();
    if (signatureBytes == null) {
      CustomAlert.error('Signature not captured properly', title: 'Validation Error');
      return;
    }

    final int lastReportNumber =
    _reportController.installationReports.isNotEmpty
        ? _reportController.installationReports.last.reportNumber
        : 0;

    final int number = _generateReportNumber(lastReportNumber);
    
    dynamic signatureData;
    dynamic pdfData;

    final pdfBytes = await InstallationRepotView.generateInstallationRepotView(
      hospitalName: _hospitalName.text,
      hospitalAddress:
      "${_hospitalAddress1.text}${_hospitalAddress2.text.isNotEmpty ? ', ${_hospitalAddress2.text}' : ''}",
      hospitalPhone: _hospitalPhone.text,
      hospitalCity: _hospitalcity.text,
      hospitalState: _hospitalState.text,
      serialNumber: _slNumberController.text,
      actionTaken: _actiontaken.text,
      machineStatus:
      selected == 'others' ? _othercontroller.text : selected ?? 'N/A',
      remarks: _remarkController.text,
      engineerName: _profileController.userProfile.value.name ?? '',
      clientName: _signedByController.text,
      warrantyStartDate: warrantyStartDate,
      warrantyEndDate: warrantyEndDate!,
      warrantyDuration: warrantyDuration,
      signatureBytes: signatureBytes,
      reportNumber: number,
      productCategory:
      _productController.categories
          .firstWhere(
            (cat) => cat.id == selectedCategory,
        orElse: () => ProductCategoryModel(productCategory: 'N/A'),
      )
          .productCategory ??
          'N/A',
      manufacturer:
      _reportController.maufacturer
          .firstWhere(
            (m) => m.id == selectedManufacturer,
        orElse: () => GetManufacturerModel(manufacturer: 'N/A'),
      )
          .manufacturer ??
          'N/A',
      trainedEmployees:
      selectedEmployees
          .map(
            (id) =>
        _customerController.employees
            .firstWhere(
              (e) => e.id == id,
          orElse: () => GetCustomerContactModel(),
        )
            .name ??
            '',
      )
          .toList(),
      complaintFrom: selectedEmployeeName ?? 'N/A',
    );

    if (kIsWeb) {
      signatureData = signatureBytes;
      pdfData = pdfBytes;
    } else {
      final tempDir = await getTemporaryDirectory();
      final signatureFile = io.File('${tempDir.path}/signature.png');
      await signatureFile.writeAsBytes(signatureBytes);
      final pdfFile = io.File('${tempDir.path}/report.pdf');
      await pdfFile.writeAsBytes(pdfBytes);
      signatureData = signatureFile;
      pdfData = pdfFile;
    }

    final newReport = PostInstallationReport(
      reportNumber: number,
      customer: _hospitalid.text,
      productCategory: selectedCategory!,
      manufacturer: selectedManufacturer!,
      slNumber: _slNumberController.text,
      soldDate: selectedDate,
      warranty: warrantyEndDate!,
      status: selected ?? 'working',
      actionTaken: _actiontaken.text,
      noteByEngineer: _remarkController.text,
      clientName: selectedEmployees.isNotEmpty ? selectedEmployees.first : 'N/A',
      trainedFor: selectedEmployees,
      signedBy: selectedEmployees.isNotEmpty ? selectedEmployees.first : _signedByController.text,
      clientSignature: signatureData,
      pdf: pdfData,
    );

    try {
      await _reportController.addInstallation(newReport);
      // Success alert is handled in Controller with delay and navigation
    } catch (e) {
      CustomAlert.error('Failed to submit report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Installation Report',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Obx(() {
                  final filteredCount = _customerController.customers.where((c) {
                    final matchesSearch = _matchesSearch(c);
                    final matchesState = _selectedState.value.isEmpty
                        ? true
                        : (c.state?.toLowerCase() == _selectedState.value.toLowerCase());
                    final matchesCity = _selectedCity.value.isEmpty
                        ? true
                        : (c.city?.toLowerCase() == _selectedCity.value.toLowerCase());
                    return matchesSearch && matchesState && matchesCity;
                  }).length;
                  return Text(
                    '$filteredCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  );
                }),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Form',
              onPressed: () {
                setState(() {
                  _uniqueCode.text = 'GK';
                  clear();
                  _actiontaken.clear();
                  _remarkController.clear();
                  _signedByController.clear();
                  _othercontroller.clear();
                  _slNumberController.clear();
                  selectedDate = DateTime.now();
                  warrantyStartDate = DateTime.now();
                  warrantyEndDate = null;
                  warrantyDuration = "";
                  selected = null;
                  selectedEmployees.clear();
                  selectedCategory = null;
                  selectedManufacturer = null;
                  selectedEmployeeName = null;
                  _controller.clear();
                });
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTapDown: (details) {
            if (_showCustomerList.value && _isTapOutside(details)) {
              setState(() {
                _showCustomerList.value = false;
              });
            }
          },
          child: Obx(() {
            if (_reportController.isLoading.value || _productController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFilterSection(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.code, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _uniqueCode,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Hospital Unique Code',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showCustomerList.value) const SizedBox(height: 570),
                      if (_hospitalName.text.isNotEmpty) ...[
                        _buildHospitalDetailsContainer(),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 12,
                            bottom: 12,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(2, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 24),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        CustomDropdownField(
                          value: selectedCategory,
                          items: _productController.categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(
                                category.productCategory ?? 'Unnamed',
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCategory = val;
                            });
                          },
                          hintText: 'Select Product',
                          icon: Icons.list,
                        ),
                        CustomDropdownField(
                          value: selectedManufacturer,
                          items: _reportController.maufacturer
                              .map(
                                (manufacturer) => DropdownMenuItem<String>(
                              value: manufacturer.id,
                              child: Text(
                                manufacturer.manufacturer ?? 'Unnamed',
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedManufacturer = val;
                            });
                          },
                          hintText: 'Select Manufacturer',
                          icon: Icons.list,
                        ),
                        CustomTextField(
                          controller: _slNumberController,
                          label: "Serial No",
                          hintText: "Enter Serial No",
                          icon: Icons.numbers,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _actiontaken.text.isNotEmpty ? _actiontaken.text : null,
                              decoration: InputDecoration.collapsed(
                                hintText: '',
                              ),
                              hint: Text(
                                'Select Action Taken',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'Installation Successful',
                                  child: Text('Installation Successful'),
                                ),
                                DropdownMenuItem(
                                  value: 'Partially Installation Successful',
                                  child: Text(
                                    'Partially Installation Successful',
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _actiontaken.text = val ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: warrantyStartDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  warrantyStartDate = picked;
                                  calculateWarrantyDuration();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.date_range),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Start Warranty Date: ${DateFormat('dd-MM-yyyy').format(warrantyStartDate)}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: warrantyStartDate,
                                firstDate: warrantyStartDate,
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  warrantyEndDate = picked;
                                  calculateWarrantyDuration();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.date_range),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      warrantyEndDate != null
                                          ? "End Warranty Date: ${DateFormat('dd-MM-yyyy').format(warrantyEndDate!)}"
                                          : "End Warranty Date",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (warrantyDuration.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Warranty Duration: $warrantyDuration",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        CustomDropdownField(
                          value: selected,
                          items: [
                            DropdownMenuItem(
                              value: 'working',
                              child: Text('Working'),
                            ),
                            DropdownMenuItem(
                              value: 'not working',
                              child: Text('Not Working'),
                            ),
                            DropdownMenuItem(
                              value: 'partial working',
                              child: Text('Partial Working'),
                            ),
                            DropdownMenuItem(
                              value: 'others',
                              child: Text('Others'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              selected = val;
                              if (val != 'others') {
                                _othercontroller.text = '';
                              }
                            });
                          },
                          hintText: 'Status of Machine',
                          icon: Icons.list,
                        ),
                        if (selected == 'others')
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: CustomTextField(
                              controller: _othercontroller,
                              label: 'Enter Machine Status',
                              hintText: 'Type custom machine status',
                              icon: Icons.edit,
                            ),
                          ),
                        CustomTextField(
                          controller: _remarkController,
                          label: "Remark",
                          hintText: "Note By Engineer (Remarks)",
                          icon: Icons.comment,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: remarks.map((remark) {
                              final isSelected = selectedRemarks.contains(remark);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedRemarks.remove(remark);
                                    } else {
                                      selectedRemarks.add(remark);
                                    }
                                    _remarkController.text = selectedRemarks.join(', ');
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    remark,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 12,
                          ),
                          child: Obx(() {
                            if (_customerController.employees.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No employees found.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Trained Employees",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.black),
                                      color: Colors.white,
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      decoration: const InputDecoration.collapsed(
                                        hintText: '',
                                      ),
                                      hint: Text('Select Trained Employees'),
                                      items: _customerController.employees.map((e) {
                                        return DropdownMenuItem<String>(
                                          value: e.id ?? '',
                                          child: Text(e.name ?? 'Unnamed'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null && !selectedEmployees.contains(val)) {
                                          setState(() {
                                            selectedEmployees.add(val);
                                            final selectedEmployee = _customerController.employees
                                                .firstWhere(
                                                  (e) => e.id == val,
                                              orElse: () => GetCustomerContactModel(),
                                            );
                                            _customerController.selectedEngineerName.value =
                                                selectedEmployee.name ?? '';
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    children: selectedEmployees.map((empId) {
                                      final employee = _customerController.employees
                                          .firstWhere(
                                            (e) => e.id == empId,
                                        orElse: () => GetCustomerContactModel(),
                                      );
                                      return Chip(
                                        label: Text(
                                          employee.name ?? 'Unnamed',
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            selectedEmployees.remove(empId);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            }
                          }),
                        ),
                        CustomButton(
                          onTap: () => _showSignaturePopup(context),
                          buttonText: 'Client Signature',
                        ),
                        if (_signedByController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Signed By: ${_signedByController.text}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Obx(() {
                          if (_reportController.isLoading.value) {
                            return CircularProgressIndicator();
                          }
                          return CustomButton(
                            onTap: _sendReport,
                            buttonText: 'Save',
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                if (_showCustomerList.value)
                  Positioned(
                    key: _customerCardKey,
                    top: 170,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 600,
                          maxWidth: 450,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Customer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const Divider(),
                            Expanded(child: _buildCustomerList()),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uniqueCode.dispose();
    _slNumberController.dispose();
    _hospitalName.dispose();
    _hospitalid.dispose();
    _hospitalPhone.dispose();
    _hospitalAddress1.dispose();
    _hospitalAddress2.dispose();
    _hospitalState.dispose();
    _hospitalcity.dispose();
    _hospitalpincode.dispose();
    _actiontaken.dispose();
    _remarkController.dispose();
    _signedByController.dispose();
    _othercontroller.dispose();
    _searchCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }
}