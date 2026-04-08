import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import 'DetailedCustomerOutstanding.dart';

class OutstandingAllScreen extends StatefulWidget {
  const OutstandingAllScreen({super.key});

  @override
  State<OutstandingAllScreen> createState() => _OutstandingAllScreenState();
}

class _OutstandingAllScreenState extends State<OutstandingAllScreen> {
  final CustomerController _controller = Get.put(CustomerController());

  @override
  void initState() {
    super.initState();
    _controller.fetchalloutstanding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customer Outstandings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => const Center(
                      child: FilterDialog(), // we'll rename the widget below
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.fetchalloutstanding(),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 🔍 Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, company, phone, city...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _controller.updateSearch,
                ),
                const SizedBox(height: 10),

                // // ⬇️ Dropdown Filters
                // Obx(
                //   () =>
                //       _controller.isFilterExpanded.value
                //           ? Column(
                //             children: [
                //               // City Dropdown
                //               DropdownButtonFormField<String>(
                //                 decoration: InputDecoration(
                //                   labelText: "Filter by City",
                //                   border: OutlineInputBorder(
                //                     borderRadius: BorderRadius.circular(12),
                //                   ),
                //                 ),
                //                 value:
                //                     _controller.selectedCity.value.isEmpty
                //                         ? null
                //                         : _controller.selectedCity.value,
                //                 items:
                //                     _controller.alloutstanding
                //                         .map((e) => e.customer.city)
                //                         .toSet()
                //                         .map(
                //                           (city) => DropdownMenuItem(
                //                             value: city,
                //                             child: Text(city),
                //                           ),
                //                         )
                //                         .toList(),
                //                 onChanged:
                //                     (val) => _controller.updateFilters(
                //                       city: val ?? '',
                //                     ),
                //               ),
                //               const SizedBox(height: 10),
                //
                //               // State Dropdown
                //               DropdownButtonFormField<String>(
                //                 decoration: InputDecoration(
                //                   labelText: "Filter by State",
                //                   border: OutlineInputBorder(
                //                     borderRadius: BorderRadius.circular(12),
                //                   ),
                //                 ),
                //                 value:
                //                     _controller.selectedState.value.isEmpty
                //                         ? null
                //                         : _controller.selectedState.value,
                //                 items:
                //                     _controller.alloutstanding
                //                         .map((e) => e.customer.state)
                //                         .toSet()
                //                         .map(
                //                           (state) => DropdownMenuItem(
                //                             value: state,
                //                             child: Text(state),
                //                           ),
                //                         )
                //                         .toList(),
                //                 onChanged:
                //                     (val) => _controller.updateFilters(
                //                       state: val ?? '',
                //                     ),
                //               ),
                //               const SizedBox(height: 10),
                //
                //               // Due only checkbox
                //               Obx(
                //                 () => CheckboxListTile(
                //                   title: const Text(
                //                     "Only show customers with dues",
                //                   ),
                //                   value: _controller.dueOnly.value,
                //                   onChanged:
                //                       (val) =>
                //                           _controller.updateFilters(due: val),
                //                   controlAffinity:
                //                       ListTileControlAffinity.leading,
                //                 ),
                //               ),
                //             ],
                //           )
                //           : SizedBox.shrink(),
                // ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = _controller.filteredList;

              if (data.isEmpty) {
                return const Center(child: Text('No matching records found.'));
              }

              final totalOutstanding = data.fold<int>(
                0,
                (sum, item) => sum + item.currentDue,
              );

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final out = data[index];

                        return InkWell(
                          onTap: () {
                            Get.to(
                              () => Detailedcustomeroutstanding(
                                customerId: out.customer.id,
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      out.customer.customerCompany,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '₹${out.currentDue}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                out.customer.customerName,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              childrenPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              children: [
                                _infoRow(
                                  Icons.monetization_on,
                                  'Initial Due',
                                  '₹${out.initialDue}',
                                  Colors.orange,
                                ),
                                _infoRow(
                                  Icons.account_balance_wallet,
                                  'Current Due',
                                  '₹${out.currentDue}',
                                  Colors.red,
                                ),
                                _infoRow(
                                  Icons.phone,
                                  'Phone',
                                  out.customer.customerPhone,
                                  Colors.black,
                                ),
                                _infoRow(
                                  Icons.email,
                                  'Email',
                                  out.customer.customerEmail,
                                  Colors.black,
                                ),
                                _infoRow(
                                  Icons.location_city,
                                  'City',
                                  out.customer.city,
                                  Colors.black,
                                ),
                                _infoRow(
                                  Icons.map,
                                  'State',
                                  out.customer.state,
                                  Colors.black,
                                ),
                                _infoRow(
                                  Icons.payments,
                                  'Payments Count',
                                  '${out.payments.length}',
                                  Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      border: Border(top: BorderSide(color: Colors.grey)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Outstanding",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "₹$totalOutstanding",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter Outstanding",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // City Dropdown
              Obx(
                () => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialValue:
                      controller.selectedCity.value.isEmpty
                          ? null
                          : controller.selectedCity.value,
                  items:
                      controller.alloutstanding
                          .map((e) => e.customer.city)
                          .toSet()
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => controller.updateFilters(city: val ?? ''),
                ),
              ),
              const SizedBox(height: 12),

              // State Dropdown
              Obx(
                () => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "State",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialValue:
                      controller.selectedState.value.isEmpty
                          ? null
                          : controller.selectedState.value,
                  items:
                      controller.alloutstanding
                          .map((e) => e.customer.state)
                          .toSet()
                          .map(
                            (state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => controller.updateFilters(state: val ?? ''),
                ),
              ),
              const SizedBox(height: 12),

              // Due Checkbox
              Obx(
                () => CheckboxListTile(
                  value: controller.dueOnly.value,
                  title: const Text("Only show customers with dues"),
                  onChanged: (val) => controller.updateFilters(due: val),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text(
                      "Clear All",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      controller.updateFilters(
                        city: '',
                        state: '',
                        due: false,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Apply Filters"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
