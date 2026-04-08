import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Controllers/Report/Report_controller.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/report/Manufacturer.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:signature/signature.dart';
import '../ReportDesign/InspectionReportView.dart';
import '../../Models/Employee/AddEmployee_model.dart';
import '../../Models/product/product_category_model.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomDropDown.dart';
import '../Widgets/CustomSigntaure.dart';

class InspectionReportScreen extends StatefulWidget {
  const InspectionReportScreen({super.key});

  @override
  State<InspectionReportScreen> createState() => _InspectionReportScreenState();
}

class _InspectionReportScreenState extends State<InspectionReportScreen> {
  final CustomerController _customerController = Get.put(CustomerController());
  final ReportController _reportController = Get.put(ReportController());
  final ProductController _productController = Get.put(ProductController());

  // TextEditing Controllers
  final TextEditingController _uniqueCode = TextEditingController();
  final TextEditingController _slNumberController = TextEditingController();
  final TextEditingController _hospitalName = TextEditingController();
  final TextEditingController _hospitalPhone = TextEditingController();
  final TextEditingController _hospitalAddress1 = TextEditingController();
  final TextEditingController _hospitalAddress2 = TextEditingController();
  final TextEditingController _hospitalState = TextEditingController();
  final TextEditingController _hospitalcity = TextEditingController();
  final TextEditingController _hospitalpincode = TextEditingController();
  final TextEditingController _actiontaken = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _signedByController = TextEditingController();
  final TextEditingController _natureOfComplaintController =
      TextEditingController();
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

  // Filter-related variables
  final RxString _searchQuery = ''.obs;
  final RxString _selectedState = ''.obs;
  final RxString _selectedCity = ''.obs;
  final RxBool _showCustomerList = false.obs;
  final GlobalKey _filterSectionKey = GlobalKey();
  final GlobalKey _customerCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _uniqueCode.text = 'GK';
    _customerController.fetchCustomers();

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
    });
  }

  List<String> remarks = [
    "Sturdy Table Required",
    "UPS power recommended",
    "Maintain pressure between 25-30 PSI",
  ];
  final List<String> sparesOptions = [
    'Compressor',
    'Filter',
    'Sensor',
    'PCB',
    'Motor',
    'Pump',
    'Relay',
  ];

  // Checkboxes
  bool isAmc = false;
  bool isCmc = false;
  bool isOnCallService = false;
  bool isRental = false;
  bool isExtendedWarranty = false;

  String? selectedManufacturer;
  String? selectedCategory;
  String? selected;
  List<String> selectedEmployees = [];
  String? selectedServiceType;
  String? selectedSpare;

  List<String> get _allCities {
    final list =
        _customerController.customers
            .where(
              (c) =>
                  _selectedState.value.isEmpty
                      ? true
                      : (c.state?.toLowerCase() ==
                          _selectedState.value.toLowerCase()),
            )
            .map((c) => c.city?.trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    list.sort();
    return list;
  }

  List<String> get _allStates {
    final list =
        _customerController.customers
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

  void clear() {
    setState(() {
      _hospitalName.clear();
      _hospitalAddress1.clear();
      _hospitalAddress2.clear();
      _hospitalPhone.clear();
      _hospitalcity.clear();
      _hospitalpincode.clear();
      _hospitalState.clear();
    });
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
      _showCustomerList.value = false;
      if (customer.id != null) {
        _customerController.fetchEmployees(customer.id!);
      }
    });
  }

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
      _showCustomerList.value = false;
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
      builder:
          (context) => CustomSignaturePopup(
            controller: _controller,
            onSigned: (signatureBytes, signedByName) {
              if (signatureBytes != null) {
                _signedByController.text = signedByName;
                setState(() {});
                print('Signature and Signed By: $signedByName');
              } else {
                print('No signature captured');
              }
            },
          ),
    );
  }

  void calculateWarrantyDuration() {
    if (warrantyEndDate != null) {
      final duration = warrantyEndDate!.difference(warrantyStartDate);
      final totalDays = duration.inDays;

      if (totalDays >= 365) {
        final years = (totalDays / 365).floor();
        final extraMonths = ((totalDays % 365) / 30).floor();
        warrantyDuration = "$years year(s) ";
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

  Future<void> _generatePdf() async {
    if (_hospitalName.text.isEmpty ||
        _slNumberController.text.isEmpty ||
        _signedByController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in hospital details, serial number, and signature',
      );
      return;
    }

    try {
      final signatureBytes = await _controller.toPngBytes();
      final pdfBytes = await InspectionReport.generateInspectionReport(
        hospitalName: _hospitalName.text,
        hospitalAddress:
            "${_hospitalAddress1.text}${_hospitalAddress2.text.isNotEmpty ? ', ${_hospitalAddress2.text}' : ''}${_hospitalcity.text.isNotEmpty ? ', ${_hospitalcity.text}' : ''}${_hospitalState.text.isNotEmpty ? ', ${_hospitalState.text}' : ''}${_hospitalpincode.text.isNotEmpty ? ' - ${_hospitalpincode.text}' : ''}",
        hospitalPhone: _hospitalPhone.text,
        hospitalCity: _hospitalcity.text,
        hospitalState: _hospitalState.text,
        serialNumber: _slNumberController.text,
        actionTaken: _actiontaken.text.isNotEmpty ? _actiontaken.text : 'N/A',
        machineStatus: selected ?? 'N/A',
        remarks:
            _remarkController.text.isNotEmpty ? _remarkController.text : 'N/A',
        engineerName: _customerController.selectedEngineerName.value,
        clientName: _signedByController.text,
        warrantyStartDate: warrantyStartDate,
        warrantyEndDate: warrantyEndDate,
        warrantyDuration: warrantyDuration,
        signatureBytes: signatureBytes,
        productCategory:
            _productController.categories
                .firstWhere(
                  (category) => category.id == selectedCategory,
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
            selectedEmployees.map((empId) {
              final employee = _customerController.employees.firstWhere(
                (e) => e.id == empId,
                orElse: () => GetEmployeeModel(),
              );
              return employee.name ?? '';
            }).toList(),
        natureOfComplaint: _natureOfComplaintController.text,
        sparesReplaced: selectedSpare ?? 'N/A',
        serviceType: selectedServiceType ?? 'N/A',
      );

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'inspectionReport.pdf',
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = io.File('${tempDir.path}/inspectionReport.pdf');
        await tempFile.writeAsBytes(pdfBytes);

        final result = await OpenFile.open(tempFile.path);
        if (result.type != ResultType.done) {
          Get.snackbar('Error', 'Could not open PDF: ${result.message}');
        } else {
          Get.snackbar(
            'Success',
            'PDF generated and opened successfully',
            backgroundColor: Colors.white,
            icon: Icon(Icons.verified, color: Colors.green),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e');
    }
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
                    initialValue:
                        _selectedState.value.isEmpty
                            ? null
                            : _selectedState.value,
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
                    initialValue:
                        _selectedCity.value.isEmpty
                            ? null
                            : _selectedCity.value,
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
          CustomTextField(
            controller: _searchCtrl,
            label: "Search Customers",
            hintText: "Search customers…",
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return Obx(() {
      final filteredCustomers =
          _customerController.customers.where((c) {
            final matchesSearch = _matchesSearch(c);
            final matchesState =
                _selectedState.value.isEmpty
                    ? true
                    : (c.state?.toLowerCase() ==
                        _selectedState.value.toLowerCase());
            final matchesCity =
                _selectedCity.value.isEmpty
                    ? true
                    : (c.city?.toLowerCase() ==
                        _selectedCity.value.toLowerCase());
            return matchesSearch && matchesState && matchesCity;
          }).toList();

      if (_customerController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
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

  bool _isTapOutside(Offset globalPosition) {
    final filterRenderBox =
        _filterSectionKey.currentContext?.findRenderObject() as RenderBox?;

    if (filterRenderBox != null) {
      final filterPosition = filterRenderBox.localToGlobal(Offset.zero);
      final filterSize = filterRenderBox.size;
      final filterRect = Rect.fromLTWH(
        filterPosition.dx,
        filterPosition.dy,
        filterSize.width,
        filterSize.height,
      );
      if (filterRect.contains(globalPosition)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Inspection Report',
          actions: [
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
                  _natureOfComplaintController.clear();
                  _slNumberController.clear();
                  selectedDate = DateTime.now();
                  warrantyStartDate = DateTime.now();
                  warrantyEndDate = null;
                  warrantyDuration = "";
                  selected = null;
                  selectedEmployees.clear();
                  selectedServiceType = null;
                  selectedSpare = null;
                  selectedCategory = null;
                  selectedManufacturer = null;
                  _searchCtrl.clear();
                  _selectedState.value = '';
                  _selectedCity.value = '';
                  _showCustomerList.value = false;
                  _controller.clear();
                });
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            final tapPosition =
                (context.findRenderObject() as RenderBox?)?.localToGlobal(
                  Offset.zero,
                ) ??
                Offset.zero;
            if (_showCustomerList.value && _isTapOutside(tapPosition)) {
              setState(() {
                _showCustomerList.value = false;
              });
            }
          },
          child: Obx(() {
            if (_reportController.isLoading.value ||
                _productController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFilterSection(),
                      CustomDropdownField(
                        value: selectedCategory,
                        items:
                            _productController.categories
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
                        items:
                            _reportController.maufacturer
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
                        CustomTextField(
                          controller: _slNumberController,
                          label: "Serial No",
                          hintText: "Enter Serial No",
                          icon: Icons.numbers,
                        ),
                        CustomTextField(
                          controller: _actiontaken,
                          label: "Action Taken",
                          hintText: "Enter Actions Taken",
                          icon: Icons.call_to_action_outlined,
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
                                          : "Pick End Warranty Date",
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Service Type',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildServiceOption('AMC'),
                                    _buildServiceOption('CMC'),
                                    _buildServiceOption('On Call Service'),
                                    _buildServiceOption('Rental'),
                                    _buildServiceOption('Extended Warranty'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nature of Complaint:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: _natureOfComplaintController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: 'Describe the complaint here...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spares Replaced:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedSpare,
                                    hint: Text('Select Spare Part'),
                                    items:
                                        sparesOptions.map((spare) {
                                          return DropdownMenuItem(
                                            value: spare,
                                            child: Text(spare),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSpare = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
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
                            });
                          },
                          hintText: 'Status of Machine',
                          icon: Icons.list,
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
                            children:
                                remarks.map((remark) {
                                  final isSelected = selectedRemarks.contains(
                                    remark,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedRemarks.remove(remark);
                                        } else {
                                          selectedRemarks.add(remark);
                                        }
                                        _remarkController.text = selectedRemarks
                                            .join(', ');
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        remark,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        CustomButton(
                          onTap: () => _showSignaturePopup(context),
                          buttonText: 'Signature',
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
                        CustomButton(
                          onTap: _generatePdf,
                          buttonText: 'Save and View PDF',
                        ),
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

  Widget _buildServiceOption(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: selectedServiceType == title,
          onChanged: (bool? value) {
            setState(() {
              if (selectedServiceType == title) {
                selectedServiceType = null;
              } else {
                selectedServiceType = title;
              }
            });
          },
        ),
        Text(title, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  void dispose() {
    _uniqueCode.dispose();
    _slNumberController.dispose();
    _hospitalName.dispose();
    _hospitalPhone.dispose();
    _hospitalAddress1.dispose();
    _hospitalAddress2.dispose();
    _hospitalState.dispose();
    _hospitalcity.dispose();
    _hospitalpincode.dispose();
    _actiontaken.dispose();
    _remarkController.dispose();
    _signedByController.dispose();
    _natureOfComplaintController.dispose();
    _searchCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }
}
