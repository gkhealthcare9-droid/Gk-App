import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pinput/pinput.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Controllers/Report/Report_controller.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:sales_grow/Views/Widgets/CustomTextField.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:signature/signature.dart';
import '../ReportDesign/incidentReportView.dart';
import '../../Models/product/customer_product.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomDropDown.dart';
import '../Widgets/CustomSigntaure.dart';
import 'Service_Quotation.dart';

class IncidentReportscreen extends StatefulWidget {
  const IncidentReportscreen({super.key});

  @override
  State<IncidentReportscreen> createState() => _IncidentReportscreenState();
}

class _IncidentReportscreenState extends State<IncidentReportscreen> {
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
  final TextEditingController _meterReadingController = TextEditingController();
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
  String? selectedNatureComplaint;

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
        clearHospitalFields();
        fetchHospital(text);
      } else {
        clearHospitalFields();
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
    "Rat Bite",
    "Water spillage",
    "No Partition",
    "Raw Power Socket Problem",
    "Poor Electrical Connection",
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
  final List<String> natureComplaintOptions = [
    'Check Chemical',
    'No Water',
    'Tank Not Empty',
    'Add Chemical Code',
    'Machine Not Getting On',
  ];
  List<String> selectedNatureComplaints = [];

  // Checkboxes
  bool isAmc = false;
  bool isCmc = false;
  bool isOnCallService = false;
  bool isRental = false;
  bool isExtendedWarranty = false;

  // Spare parts with quantities
  Map<String, int> selectedSpares = {};
  String? _currentSpare;
  int? _currentQuantity;

  CustomerProduct? selectedProduct;
  String? selectedCategory;
  String? selectedManufacturer;
  String? selectedProductId;
  String? selected;
  List<String> selectedEmployees = [];
  String? selectedServiceType;

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

  void clearHospitalFields() {
    setState(() {
      _hospitalName.clear();
      _hospitalAddress1.clear();
      _hospitalAddress2.clear();
      _hospitalPhone.clear();
      _hospitalcity.clear();
      _hospitalpincode.clear();
      _hospitalState.clear();
      selectedProductId = null;
      _slNumberController.clear();
      _meterReadingController.clear();
      selectedProduct = null;
      selectedCategory = null;
      selectedManufacturer = null;
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
        // _productController.fetchCustomerProducts(customer.id!);
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
      _showCustomerList.value = false; // Hide list when customer is fetched
    });

    if (_customerController.customer.value.id != null) {
      await _customerController.fetchEmployees(
        _customerController.customer.value.id!,
      );
      // await _productController.fetchCustomerProducts(_customerController.customer.value.id!);
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

  Future<Uint8List> _generateAndSavePdf() async {
    final signatureBytes = await _controller.toPngBytes();
    final sparesReplaced =
        selectedSpares.isEmpty
            ? 'N/A'
            : selectedSpares.entries
                .map((e) => '${e.key} (${e.value})')
                .join(', ');

    return await IncidentReport.generateIncidentReport(
      hospitalName: _hospitalName.text,
      hospitalAddress:
          "${_hospitalAddress1.text}${_hospitalAddress2.text.isNotEmpty ? ', ${_hospitalAddress2.text}' : ''}",
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
      signatureBytes: signatureBytes,
      productCategory: selectedCategory ?? 'N/A',
      manufacturer: selectedManufacturer ?? 'N/A',
      natureOfComplaint: _natureOfComplaintController.text,
      sparesReplaced: sparesReplaced,
      serviceType: selectedServiceType ?? 'N/A',
      warrantyStartDate: warrantyStartDate,
      warrantyEndDate: warrantyEndDate,
      warrantyDuration: warrantyDuration,
      meterReading:
          _meterReadingController.text.isNotEmpty
              ? _meterReadingController.text
              : 'N/A',
      trainedEmployees: [],
    );
  }

  Future<void> _generatePdf() async {
    if (_hospitalName.text.isEmpty ||
        _slNumberController.text.isEmpty ||
        _signedByController.text.isEmpty) {
      CustomAlert.error(
        'Please fill in hospital details, serial number, and signature',
      );
      return;
    }

    try {
      final pdfBytes = await _generateAndSavePdf();

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'incidentReport.pdf',
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = io.File('${tempDir.path}/incidentReport.pdf');
        await tempFile.writeAsBytes(pdfBytes);

        final result = await OpenFile.open(tempFile.path);
        if (result.type == ResultType.done) {
          CustomAlert.success(
            'PDF generated and opened successfully',
          );
        } else {
          CustomAlert.error('Could not open PDF: ${result.message}');
        }
      }

      await Future.delayed(const Duration(seconds: 2));
      Get.to(
        () => ServiceQuotationScreen(
          customerCode: _uniqueCode.text,
          reportNumber: 'GKSRV01',
          phoneNumber: _hospitalPhone.text,
        ),
      );
    } catch (e) {
      CustomAlert.error('Failed to generate PDF: $e');
    }
  }

  Future<void> _saveAndProceed() async {
    if (_hospitalName.text.isEmpty ||
        _slNumberController.text.isEmpty ||
        _signedByController.text.isEmpty) {
      CustomAlert.error(
        'Please fill in hospital details, serial number, and signature',
      );
      return;
    }

    try {
      final pdfBytes = await _generateAndSavePdf();
      if (kIsWeb) {
        // Just proceed on web as we can't easily save to a specific local path
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = io.File('${tempDir.path}/incidentReport.pdf');
        await tempFile.writeAsBytes(pdfBytes);
      }

      CustomAlert.success(
        'PDF generated and saved successfully',
      );
      await Future.delayed(const Duration(seconds: 2));
      Get.to(
        () => ServiceQuotationScreen(
          customerCode: _uniqueCode.text,
          reportNumber: 'GKSRV01',
          phoneNumber: _hospitalPhone.text,
        ),
      );
    } catch (e) {
      CustomAlert.error('Failed to generate PDF: $e');
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
                        clearHospitalFields();
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
                        clearHospitalFields();
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
          title: 'Incident Report',
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Form',
              onPressed: () {
                setState(() {
                  _uniqueCode.text = 'GK';
                  clearHospitalFields();
                  _actiontaken.clear();
                  _remarkController.clear();
                  _signedByController.clear();
                  _natureOfComplaintController.clear();
                  _meterReadingController.clear();
                  selectedDate = DateTime.now();
                  warrantyStartDate = DateTime.now();
                  warrantyEndDate = null;
                  warrantyDuration = "";
                  selectedNatureComplaint = null;
                  selected = null;
                  selectedEmployees.clear();
                  selectedServiceType = null;
                  selectedSpares.clear();
                  _currentSpare = null;
                  _currentQuantity = null;
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
                        CustomDropdownField<String>(
                          value: selectedProductId,
                          items:
                              _productController.customerProducts
                                  .asMap()
                                  .entries
                                  .where((entry) => entry.value.id != null)
                                  .map((entry) {
                                    final product = entry.value;
                                    return DropdownMenuItem<String>(
                                      value: product.id,
                                      child: Text(
                                        '${product.productCategory?.productCategory ?? 'Unknown'} - ${product.slNumber ?? ''}',
                                      ),
                                    );
                                  })
                                  .toSet()
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedProductId = val;
                              selectedProduct = _productController
                                  .customerProducts
                                  .firstWhere((product) => product.id == val);
                              selectedCategory =
                                  selectedProduct
                                      ?.productCategory
                                      ?.productCategory;
                              selectedManufacturer =
                                  selectedProduct?.manufacturer?.manufacturer;
                              _slNumberController.text =
                                  selectedProduct?.slNumber ?? '';
                              _meterReadingController.clear();
                            });
                          },
                          hintText: 'Select Product',
                          icon: Icons.list,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
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
                              if (selectedProduct
                                      ?.productCategory
                                      ?.productCategory ==
                                  'dialysis machine') ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Running Hours:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Pinput(
                                              controller:
                                                  _meterReadingController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  8,
                                                ),
                                              ],
                                              defaultPinTheme: PinTheme(
                                                width: 40,
                                                height: 50,
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              length: 8,
                                              showCursor: true,
                                              onCompleted: (value) {},
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        CustomDropdownField(
                          value: selectedNatureComplaint,
                          items:
                              natureComplaintOptions.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedNatureComplaint = val;
                              _natureOfComplaintController.text = val ?? '';
                            });
                          },
                          hintText: 'Nature of Complaint/ Machine Alarm',
                          icon: Icons.warning_amber_rounded,
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
                                'Select Spare Parts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          hint: Text('Select Spare Part'),
                                          value: _currentSpare,
                                          items:
                                              sparesOptions.map((spare) {
                                                return DropdownMenuItem(
                                                  value: spare,
                                                  child: Text(spare),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _currentSpare = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    width: 100,
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
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        hint: Text('Qty'),
                                        value: _currentQuantity,
                                        items:
                                            List.generate(
                                              10,
                                              (index) => index + 1,
                                            ).map((qty) {
                                              return DropdownMenuItem(
                                                value: qty,
                                                child: Text(qty.toString()),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _currentQuantity = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              CustomButton(
                                onTap: () {
                                  if (_currentSpare != null &&
                                      _currentQuantity != null) {
                                    setState(() {
                                      selectedSpares[_currentSpare!] =
                                          _currentQuantity!;
                                      _currentSpare = null;
                                      _currentQuantity = null;
                                    });
                                  } else {
                                    CustomAlert.error(
                                      'Please select a spare part and quantity',
                                    );
                                  }
                                },
                                buttonText: 'Add Spare Part',
                              ),
                              if (selectedSpares.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      selectedSpares.entries.map((entry) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${entry.key} (${entry.value})',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedSpares.remove(
                                                      entry.key,
                                                    );
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        CustomTextField(
                          controller: _actiontaken,
                          label: "Action Taken",
                          hintText: "Enter Actions Taken",
                          icon: Icons.call_to_action_outlined,
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
                        CustomButton(
                          onTap: _generatePdf,
                          buttonText: 'Save and Share PDF',
                        ),
                        SizedBox(height: 10),
                        CustomButton(
                          onTap: _saveAndProceed,
                          buttonText: 'Save and Proceed Quotation',
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
    _meterReadingController.dispose();
    _searchCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }
}
