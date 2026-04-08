import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Views/Vendor/vendor_view.dart';
import '../../Controllers/AddVendor/vendor_controller.dart';
import '../../Models/Vendor/Vendor.dart';

class VendorsListScreen extends StatefulWidget {
  const VendorsListScreen({super.key});

  @override
  _VendorsListScreenState createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen> {
  final VendorController vendorController = Get.put(VendorController());
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _selectedState = ''.obs;
  final RxString _selectedCity = ''.obs;
  final RxBool _onlyDistributors = false.obs;



  @override
  void initState() {
    super.initState();
    vendorController.fetchVendors();
  }
  List<String> get _allCities {
    final list = vendorController.vendors
        .where((v) => _selectedState.value.isEmpty
        ? true
        : (v.state?.toLowerCase() == _selectedState.value.toLowerCase()))
        .map((v) => v.city?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  bool _matchesSearch(VendorModel v) {
    final q = _searchQuery.value.toLowerCase();
    return (v.vendorName ?? '').toLowerCase().contains(q) ||
        (v.vendorCompany ?? '').toLowerCase().contains(q) ||
        (v.vendorPhone ?? '').toLowerCase().contains(q) ||
        (v.vendorEmail ?? '').toLowerCase().contains(q) ||
        (v.vendorGSTIN ?? '').toLowerCase().contains(q) ||
        (v.addressOne ?? '').toLowerCase().contains(q) ||
        (v.addressTwo ?? '').toLowerCase().contains(q) ||
        (v.city ?? '').toLowerCase().contains(q) ||
        (v.state ?? '').toLowerCase().contains(q) ||
        (v.pincode ?? '').toLowerCase().contains(q);
  }
  List<String> get _allStates {
    final all = vendorController.vendors
        .map((v) => v.state?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    all.sort();
    return all;
  }

  Widget _highlight(String text) {
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
      text: TextSpan(style: const TextStyle(color: Colors.black), children: spans),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Expanded(child: _highlight(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filtered = vendorController.vendors.where((v) {
        final q = _searchQuery.value.toLowerCase();
        final matchesSearch = (v.vendorName ?? '').toLowerCase().contains(q);

        final matchesState = _selectedState.value.isEmpty
        ? true
            : (v.state?.toLowerCase() == _selectedState.value.toLowerCase());

        final matchesCity = _selectedCity.value.isEmpty
        ? true
            : (v.city?.toLowerCase() == _selectedCity.value.toLowerCase());

        return matchesSearch && matchesState && matchesCity;
      }).toList();


      return Scaffold(
        appBar: AppBar(
          title: const Text('Vendors'),
          actions: [
            // ─── UPDATED: show filtered.length instead of total length ───
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  filtered.length.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(150), // bumped height
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Obx(() => Row(
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('All States')),
                            ..._allStates.map((st) => DropdownMenuItem(value: st, child: Text(st))),
                          ],
                          onChanged: (v) {
                            _selectedState.value = v ?? '';
                            _selectedCity.value = ''; // reset city
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('All Cities')),
                            ..._allCities.map((ct) => DropdownMenuItem(value: ct, child: Text(ct))),
                          ],
                          onChanged: (v) => _selectedCity.value = v ?? '',
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (value) => _searchQuery.value = value,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                      prefixIcon: const Icon(Icons.search, size: 22),
                      hintText: 'Search vendors…',
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
          ),
        ),
        body: vendorController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : filtered.isEmpty
            ? const Center(child: Text('No matching vendors'))
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final v = filtered[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: _searchQuery.value.isNotEmpty,
                  leading: const Icon(Icons.store, size: 40),
                  title:  _highlight(v.vendorCompany!),
                  subtitle:_highlight(v.vendorName!),
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      Get.to(() => vendorview(vendor: v));
                    }
                  },
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildDetailRow(Icons.phone, 'Phone', v.vendorPhone!),

                    _buildDetailRow(Icons.email, 'Email', v.vendorEmail ?? ''),
                    _buildDetailRow(Icons.badge, 'GSTIN', v.vendorGSTIN ??''),
                    // _buildDetailRow(
                    //   Icons.home,
                    //   'Address',
                    //   '${v.addressOne!}, ${v.addressTwo!}, ${v.city!}, ${v.state!} - ${v.pincode!}',
                    // ),
                  ],
                ),
              );
            }
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.add),
        //   onPressed: () {
        //     Get.to(() => const AddVendorScreen())?.then((_) => vendorController.fetchVendors());
        //   },
        // ),
      );
    });
  }
}
