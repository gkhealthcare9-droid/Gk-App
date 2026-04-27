import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Utils/Colors.dart';
import 'package:sales_grow/Views/Customer/CustomerView.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:get/get.dart';

class SearchCustomer extends StatefulWidget {
  const SearchCustomer({super.key});

  @override
  State<SearchCustomer> createState() => _SearchCustomerState();
}

class _SearchCustomerState extends State<SearchCustomer> {
  late final CustomerController _customerController;
  final RxString _searchQuery = ''.obs;
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _selectedState = ''.obs;
  final RxString _selectedCity = ''.obs;

  @override
  void initState() {
    super.initState();
    try {
      _customerController = Get.find<CustomerController>();
    } catch (e) {
      CustomAlert.error('CustomerController not found. Please try again.');
      Get.back();
      return;
    }
    _load();
    _searchCtrl.addListener(() {
      _searchQuery.value = _searchCtrl.text;
    });
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
    final all = _customerController.customers
        .map((c) => c.state?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    all.sort();
    return all;
  }

  Future<void> _load() async {
    await _customerController.fetchCustomers();
  }

  bool _matchesSearch(CustomerModel c) {
    final q = _searchQuery.value.toLowerCase();
    return (c.customerQuniqueNumber?.toLowerCase().contains(q) ?? false) ||
        (c.customerCompany?.toLowerCase().contains(q) ?? false) ||
        (c.customerGSTIN?.toLowerCase().contains(q) ?? false) ||
        (c.customerEmail?.toLowerCase().contains(q) ?? false) ||
        (c.customerPhone?.toLowerCase().contains(q) ?? false) ||
        (c.customerName?.toLowerCase().contains(q) ?? false) ||
        (c.addressOne?.toLowerCase().contains(q) ?? false) ||
        (c.addressTwo?.toLowerCase().contains(q) ?? false) ||
        (c.city?.toLowerCase().contains(q) ?? false) ||
        (c.state?.toLowerCase().contains(q) ?? false) ||
        (c.pincode?.toLowerCase().contains(q) ?? false);
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
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(backgroundColor: Colors.yellow),
      ));
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

  Widget _buildDetailRow(IconData icon, String label, Widget value, {String? copyText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Expanded(child: value),
          if (copyText != null)
            IconButton(
              icon: Icon(Icons.copy, size: 20, color: Colors.grey[600]),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyText));
                CustomAlert.success('$label copied to clipboard');
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
    _customerController.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search Customers',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Obx(() {
                final filteredCount = _customerController.customers.where((c) {
                  final matchesSearch = _matchesSearch(c);
                  final matchesState = _selectedState.value.isEmpty
                      ? true
                      : (c.state?.toLowerCase() ==
                      _selectedState.value.toLowerCase());
                  final matchesCity = _selectedCity.value.isEmpty
                      ? true
                      : (c.city?.toLowerCase() ==
                      _selectedCity.value.toLowerCase());
                  return matchesSearch && matchesState && matchesCity;
                }).length;
                return Text(
                  '$filteredCount',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                );
              }),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedState.value.isEmpty
                            ? null
                            : _selectedState.value,
                        decoration: InputDecoration(
                          hintText: 'Filter by State',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('All States')),
                          ..._allStates.map(
                                  (st) => DropdownMenuItem(value: st, child: Text(st))),
                        ],
                        onChanged: (v) {
                          _selectedState.value = v ?? '';
                          _selectedCity.value = '';
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCity.value.isEmpty
                            ? null
                            : _selectedCity.value,
                        decoration: InputDecoration(
                          hintText: 'Filter by City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('All Cities')),
                          ..._allCities.map(
                                  (ct) => DropdownMenuItem(value: ct, child: Text(ct))),
                        ],
                        onChanged: (v) => _selectedCity.value = v ?? '',
                      ),
                    ),
                  ],
                )),
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
          ),
          Expanded(
            child: Obx(() {
              final filtered = _customerController.customers.where((c) {
                final matchesSearch = _matchesSearch(c);
                final matchesState = _selectedState.value.isEmpty
                    ? true
                    : (c.state?.toLowerCase() ==
                    _selectedState.value.toLowerCase());
                final matchesCity = _selectedCity.value.isEmpty
                    ? true
                    : (c.city?.toLowerCase() ==
                    _selectedCity.value.toLowerCase());
                return matchesSearch && matchesState && matchesCity;
              }).toList();

              if (_customerController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.black,
                  ),
                );
              }
              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No Customers Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  return InkWell(
                    onTap: () {
                      Get.to(() => CustomerView(customer: c));
                    },
                    child: Card(
                      margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            horizontal: 16, vertical: 8),
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
                            copyText: '${c.customerCompany ?? ''} (${c.customerQuniqueNumber ?? ''}) ${c.addressOne ?? ''} ${c.addressTwo ?? ''} ${c.city ?? ''}',
                          ),
                          _buildDetailRow(
                            Icons.business,
                            'Company Website',
                            _highlight(c.customerCompany),
                          ),
                          _buildDetailRow(
                            Icons.call,
                            'Phone no',
                            _highlight(c.customerPhone),
                          ),
                          _buildDetailRow(
                            Icons.call,
                            'Phone no',
                            _highlight(c.customerPhone2),
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
                            copyText: c.customerQuniqueNumber ?? 'N/A',
                          ),
                          _buildDetailRow(
                            Icons.home,
                            'Address',
                            _highlight(
                                '${c.addressOne ?? ''}, ${c.addressTwo ?? ''}, ${c.city ?? ''}, ${c.state ?? ''} - ${c.pincode ?? ''}'),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}