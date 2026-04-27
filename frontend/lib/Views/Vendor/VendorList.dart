import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/AddVendor/vendor_controller.dart';
import '../../Models/Vendor/Vendor.dart';
import '../Widgets/CustomAppBar.dart';
import 'vendor_view.dart';
import 'AddVendor.dart';

class VendorsListScreen extends StatefulWidget {
  const VendorsListScreen({super.key});

  @override
  State<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen> {
  final VendorController vendorController = Get.find<VendorController>();
  final _searchQuery = ''.obs;
  final _searchCtrl = TextEditingController();

  final _selectedState = ''.obs;
  final _selectedCity = ''.obs;

  @override
  void initState() {
    super.initState();
    vendorController.fetchVendors();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _allStates {
    final list = vendorController.vendors
        .map((v) => v.state?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    return list.toSet().toList()..sort();
  }

  List<String> get _allCities {
    final state = _selectedState.value.toLowerCase();
    final list = vendorController.vendors.where((v) {
      if (state.isEmpty) return true;
      return v.state?.toLowerCase() == state;
    }).map((v) => v.city?.trim() ?? '').where((c) => c.isNotEmpty).toList();
    return list.toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filtered = vendorController.vendors.where((v) {
        final q = _searchQuery.value.toLowerCase();
        final name = v.vendorName?.toLowerCase() ?? '';
        final city = v.city?.toLowerCase() ?? '';
        final state = v.state?.toLowerCase() ?? '';

        final matchesSearch = name.contains(q) || city.contains(q) || state.contains(q);

        final matchesState = _selectedState.value.isEmpty
            ? true
            : (v.state?.toLowerCase() == _selectedState.value.toLowerCase());

        final matchesCity = _selectedCity.value.isEmpty
            ? true
            : (v.city?.toLowerCase() == _selectedCity.value.toLowerCase());

        return matchesSearch && matchesState && matchesCity;
      }).toList();

      return Scaffold(
        appBar: CustomAppBar(
          title: 'Vendors',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  filtered.length.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedState.value.isEmpty ? null : _selectedState.value,
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
                            _selectedCity.value = '';
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedCity.value.isEmpty ? null : _selectedCity.value,
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
                  ),
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
                        borderSide: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: vendorController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('No matching vendors'))
                      : RefreshIndicator(
                          onRefresh: () => vendorController.fetchVendors(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final v = filtered[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  onTap: () => Get.to(() => vendorview(vendor: v)),
                                  title: Text(v.vendorName ?? 'No Name',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${v.city ?? ""}, ${v.state ?? ""}'),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          onPressed: () => Get.to(() => const AddVendorScreen()),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }
}
