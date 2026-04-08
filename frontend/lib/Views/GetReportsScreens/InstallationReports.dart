import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/Report/Report_controller.dart';
import 'package:sales_grow/Views/GetReportsScreens/ViewPdf.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import '../../Models/report/GenerateReports/Installation_Report_Model.dart';

class GetInstallationReports extends StatefulWidget {
  const GetInstallationReports({super.key});

  @override
  State<GetInstallationReports> createState() => _GetInstallationReportsState();
}

class _GetInstallationReportsState extends State<GetInstallationReports> {
  final ReportController _reportController = Get.put(ReportController());
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _selectedState = ''.obs;
  final RxString _selectedCity = ''.obs;
  Timer? _debounce;

  List<String> get _allStates {
    final rawStates = _reportController.installationReports
        .map((r) => r.customer.state ?? 'null')
        .toList();
    print('Raw States: $rawStates'); // Debug: Print raw state values
    final all = rawStates
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    all.sort();
    return all;
  }

  List<String> get _allCities {
    final rawCities = _reportController.installationReports
        .where((r) => _selectedState.value.isEmpty
        ? true
        : (r.customer.state.toLowerCase() == _selectedState.value.toLowerCase()))
        .map((r) => r.customer.city ?? 'null')
        .toList();
    print('Raw Cities: $rawCities'); // Debug: Print raw city values
    final list = rawCities
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _searchQuery.value = _searchCtrl.text;
        print('Updated Search Query: ${_searchQuery.value}'); // Debug
      });
    });
    Future.delayed(Duration.zero, () async {
      await _reportController.fetchInstallationReports();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesSearch(FetchInstallationReport r) {
    final query = _searchQuery.value.toLowerCase().trim();
    print('Search Query: "$query"'); // Debug: Log the search query
    if (query.isEmpty) return true;

    // Process "Report X" format
    String processedQuery = query;
    if (query.startsWith('report') || query.startsWith('rep') || query.startsWith('rpt')) {
      processedQuery = query.replaceAll(RegExp(r'report|rep|rpt', caseSensitive: false), '').trim();
      print('Processed Query: "$processedQuery"'); // Debug: Log processed query
    }

    // Log fields for debugging
    print('Checking Report #${r.reportNumber}:');
    print('  Report Number: ${r.reportNumber.toString()}');
    print('  SL Number: ${r.slNumber}');
    print('  Customer Name: ${r.customer.customerName}');
    print('  Status: ${r.status}');
    print('  Hospital Name: ${r.hospitalName}');
    print('  Hospital City: ${r.hospitalCity}');
    print('  Hospital State: ${r.hospitalState}');
    print('  Serial Number: ${r.serialNumber}');
    print('  Machine Status: ${r.machineStatus}');
    print('  Remarks: ${r.remarks}');
    print('  Engineer Name: ${r.engineerName}');
    print('  Complaint From: ${r.complaintFrom}');

    // Search all relevant fields
    return r.reportNumber.toString().contains(processedQuery) ||
        r.slNumber.toLowerCase().contains(query) ||
        r.customer.customerName.toLowerCase().contains(query) ||
        r.status.toLowerCase().contains(query) ||
        r.hospitalName.toLowerCase().contains(query) ||
        r.hospitalCity.toLowerCase().contains(query) ||
        r.hospitalState.toLowerCase().contains(query) ||
        r.serialNumber.toLowerCase().contains(query) ||
        r.machineStatus.toLowerCase().contains(query) ||
        r.remarks.toLowerCase().contains(query) ||
        r.engineerName.toLowerCase().contains(query) ||
        r.complaintFrom.toLowerCase().contains(query) ||
        r.customer.city.toLowerCase().contains(query) ||
        r.customer.state.toLowerCase().contains(query) ||
        r.productCategory.productCategory.toLowerCase().contains(query) ||
        r.manufacturer.manufacturer.toLowerCase().contains(query) ||
        r.engineer.name.toLowerCase().contains(query) ||
        r.clientName.name.toLowerCase().contains(query) ||
        r.signedBy.name.toLowerCase().contains(query) ||
        r.trainedEmployees.any((e) => e.toLowerCase().contains(query)) ||
        r.trainedFor.any((c) => c.name.toLowerCase().contains(query));
  }

  Widget _highlight(String text) {
    final query = _searchQuery.value;
    if (query.isEmpty) return Text(text);

    final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
    final matches = pattern.allMatches(text);
    if (matches.isEmpty) return Text(text);

    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final m in matches) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, m.start)));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: const TextStyle(backgroundColor: Colors.yellow),
      ));
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(style: const TextStyle(color: Colors.black), children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Installation Reports'),
      body: Obx(() {
        if (_reportController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = _reportController.installationReports;
        print('All Reports: ${all.length}'); // Debug: Check number of reports
        print('All States: $_allStates'); // Debug: Check available states
        print('All Cities: $_allCities'); // Debug: Check available cities

        if (all.isEmpty) {
          return const Center(child: Text('No Reports Found'));
        }

        final filtered = all.where((r) {
          final matchesSearch = _matchesSearch(r);
          final matchesState = _selectedState.value.isEmpty
              ? true
              : (r.customer.state.toLowerCase() == _selectedState.value.toLowerCase());
          final matchesCity = _selectedCity.value.isEmpty
              ? true
              : (r.customer.city.toLowerCase() == _selectedCity.value.toLowerCase());
          return matchesSearch && matchesState && matchesCity;
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort newest first

        return Column(
          children: [
            // Search bar and dropdowns
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search bar
                  Obx(() => TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search reports...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      suffixIcon: _searchQuery.value.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _searchQuery.value = '';
                        },
                      )
                          : const SizedBox.shrink(),
                    ),
                  )),
                  const SizedBox(height: 8),
                  // State and City dropdowns
                  Obx(() => Row(
                    children: [
                      // State dropdown
                      Expanded(
                        child: _allStates.isEmpty
                            ? const Text('No states available')
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedState.value.isEmpty ? null : _selectedState.value,
                          decoration: InputDecoration(
                            hintText: 'Filter by State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('All States')),
                            ..._allStates.map((st) => DropdownMenuItem(value: st, child: Text(st))),
                          ],
                          onChanged: (v) {
                            _selectedState.value = v ?? '';
                            _selectedCity.value = ''; // Reset city when state changes
                            print('Selected State: ${_selectedState.value}'); // Debug
                            print('Updated Cities: $_allCities'); // Debug
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // City dropdown
                      Expanded(
                        child: _allCities.isEmpty
                            ? const Text('No cities available')
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedCity.value.isEmpty ? null : _selectedCity.value,
                          decoration: InputDecoration(
                            hintText: 'Filter by City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('All Cities')),
                            ..._allCities.map((ct) => DropdownMenuItem(value: ct, child: Text(ct))),
                          ],
                          onChanged: (v) {
                            _selectedCity.value = v ?? '';
                            print('Selected City: ${_selectedCity.value}'); // Debug
                          },
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            // List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No matching reports'))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final r = filtered[i];
                  final dateStr = r.soldDate.toLocal().toString().split(' ')[0];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Row(
                        children: [
                          const Text('Report #'),
                          _highlight(r.reportNumber.toString()),
                          const Text(' - '),
                          _highlight(r.slNumber),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Customer: '),
                              Expanded(
                                child: _highlight(r.customer.customerName),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Date: '),
                              _highlight(dateStr),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Status: '),
                              _highlight(r.status),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => PDFViewerScreen(
                            pdfUrl: r.pdf!,
                            reportNumber: r.reportNumber.toString(),
                          ));
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text("PDF", style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}