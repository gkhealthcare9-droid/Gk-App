import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Controllers/Expenses/Expenses.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpensesController _expensesController = Get.put(ExpensesController());
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final picker = ImagePicker();
  XFile? billImage;

  DateTime? _startDate;
  DateTime? _endDate;
String? _selectedCategoryId;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _expensesController.fetchWallet();
      await _expensesController.fetchTranscations();
      await _expensesController.fetchexpensesCategory();
    });
  }

  void addExpense() {
    final amount = double.tryParse(amountCtrl.text);
    final description = descCtrl.text.trim();
    final categoryId = _selectedCategoryId;
    if (amount == null) {
      Get.snackbar('Validation Error', 'Please enter a valid amount.');
      return;
    }
    if (description.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a description.');
      return;
    }

    // Pass image data directly
    Future.microtask(() async {
      Uint8List? imageBytes;
      String? fileName;

      if (billImage != null) {
        imageBytes = await billImage!.readAsBytes();
        fileName = billImage!.name;
      }

      _expensesController.addExpense(
        description: description,
        amount: amount,
        category: _selectedCategoryId,
        imageBytes: imageBytes,
        fileName: fileName,
      );
    });

    // Clear the form fields & reset billImage reference
    amountCtrl.clear();
    descCtrl.clear();
    setState(() {
      billImage = null;
    });
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        billImage = picked;
      });
    }
  }

  Future<void> _refresh() async {
    await _expensesController.fetchWallet();
    await _expensesController.fetchTranscations();
    await _expensesController.fetchexpensesCategory();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Obx(() {
          if (_expensesController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_expensesController.wallet.value.user!.isEmpty) {
            return const Center(child: Text('No Funds Added Yet'));
          }

          final expenses = _expensesController.transcations.value ?? [];
          final filteredExpenses = expenses.where((e) {
            if (_startDate == null || _endDate == null) return true;
            final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
            return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                date.isBefore(_endDate!.add(const Duration(days: 1)));
          }).toList();

          final groupedExpenses = _groupExpensesByDate(filteredExpenses);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildExpenseForm(),
                const SizedBox(height: 50),
                ExpansionTile(
                  title:  Text(
                    "See History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    Text("Expenses", style: Theme.of(context).textTheme.titleLarge),

                    const SizedBox(height: 10),
                    if (filteredExpenses.isEmpty)
                      const Center(child: Text("No expenses found"))
                    else
                      ...groupedExpenses.entries.map((entry) {
                        final date = entry.key;
                        final transactions = entry.value;
                        final totalAmount = transactions.fold(0.0, (sum, e) => sum + e.amount!);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${DateFormat('dd MMM yyyy').format(date)} - Total: ₹${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _expensesController.transcations.length,
                              itemBuilder: (_, i) {

                                final e = _expensesController.transcations[i];
                                final DateTime istTime = e.createdAt.add(const Duration(hours: 5, minutes: 30));
                                final String billTime = DateFormat('hh:mm a').format(istTime);
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    onTap: () {
                                      Get.to(() => ExpenseDetailScreen(expense: {
                                        'amount': e.amount,
                                        'desc': e.description,
                                        'date': e.createdAt,
                                        'category':e.category!.expensesCategory??'N/A',
                                        'image': e.bill,
                                      }));
                                    },
                                    leading: _buildBillThumbnail(e.bill),
                                    title: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "₹${e.amount}",
                                            style: const TextStyle(
                                              color: Color(0xFF2DC6E2), // Corrected color for description                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " - ${e.description}",
                                            style: const TextStyle(
                                              color: Color(0xFF2DC6E2), // Corrected color for description                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Text('Added at $billTime'),
                                    trailing: const Icon(Icons.chevron_right),
                                  ),
                                );
                              },
                            ),                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  Widget _buildBalanceCard() {
    final balance = _expensesController.wallet.value.balance ?? 0.0;
    final isNegative = balance < 0;
    final displayAmount = balance.abs().toStringAsFixed(2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              "Balance Available",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              isNegative ? "-$displayAmount" : displayAmount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isNegative ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Column(
      children: [
        _buildTextField(amountCtrl, "Amount", Icons.currency_rupee),
        const SizedBox(height: 12),
        _buildTextField(descCtrl, "Description", Icons.description),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Project *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          items: _expensesController.expensescategory.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,                        // <-- assign the ID here
              child: Text(category.expensesCategory),    // <-- display the name
            );
          }).toList(),
          onChanged: (selectedId) {
            setState(() {
              _selectedCategoryId = selectedId;    // <-- now holds the ID
            });
          },
          hint: const Text('Select Project'),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Upload Bill"),
            ),
            const SizedBox(width: 10),
            if (billImage != null) const Text("Image Selected ✅"),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: addExpense,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Color(0xFF2DC6E2), // Cyan background
            foregroundColor: Colors.white, // White text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners for consistency
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: const Text("Add Expense"),
        ),


      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: hint == "Amount" ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }

  Widget _buildBillThumbnail(String? url) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          ),
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey[200],
        child: const Icon(Icons.receipt_long),
      );
    }
  }

  Map<DateTime, List<dynamic>> _groupExpensesByDate(List<dynamic> expenses) {
    Map<DateTime, List<dynamic>> grouped = {};
    for (var e in expenses) {
      final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(e);
    }
    return grouped;
  }
}
class ExpenseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final DateTime utcTime = expense['date'];
    final DateTime istTime = utcTime.add(const Duration(hours: 5, minutes: 30));
    final String formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(istTime);

    return Scaffold(
      appBar: AppBar(title: const Text("Expense Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetail("Amount", "₹${expense['amount']}"),
            _buildDetail("Description", expense['desc']),
            _buildDetail("Project", expense['category']),
            _buildDetail("Date & Time", formattedDateTime),
            const SizedBox(height: 20),
            if (expense['image'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bill Image:", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      expense['image'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: label == "Amount"
                ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.green, // Dark green for the amount
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }}




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:sales_grow/Controllers/Expenses/Expenses.dart';
//
// class ExpenseScreen extends StatefulWidget {
//   @override
//   _ExpenseScreenState createState() => _ExpenseScreenState();
// }
//
// class _ExpenseScreenState extends State<ExpenseScreen> {
//   final ExpensesController _expensesController = Get.put(ExpensesController());
//   final TextEditingController amountCtrl = TextEditingController();
//   final TextEditingController descCtrl = TextEditingController();
//   final picker = ImagePicker();
//   File? billImage;
//
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () async {
//       await _expensesController.fetchWallet();
//     });
//   }
//
//   void addExpense() {
//     final amount = double.tryParse(amountCtrl.text);
//     if (amount != null && descCtrl.text.isNotEmpty) {  // ❗ Now bill image not mandatory
//       _expensesController.addExpense(
//         description: descCtrl.text,
//         amount: amount,
//         billImage: billImage,   // Can pass null now ✅
//       );
//       amountCtrl.clear();
//       descCtrl.clear();
//       setState(() {
//         billImage = null;
//       });
//     }
//   }
//
//   Future<void> pickImage() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         billImage = File(picked.path);
//       });
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _expensesController.fetchWallet();
//   }
//
//   Future<void> _pickDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2023),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Expense Manager"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: _pickDateRange,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: Obx(() {
//           if (_expensesController.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (_expensesController.wallet.value.user!.isEmpty) {
//             return const Center(child: Text('No Funds Added Yet'));
//           }
//
//           final expenses = _expensesController.wallet.value.transactions ?? [];
//           final filteredExpenses = expenses.where((e) {
//             if (_startDate == null || _endDate == null) return true;
//             final date = DateTime(e.createdAt!.year, e.createdAt!.month, e.createdAt!.day);
//             return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
//                 date.isBefore(_endDate!.add(const Duration(days: 1)));
//           }).toList();
//
//           final groupedExpenses = _groupExpensesByDate(filteredExpenses);
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildBalanceCard(),
//                 const SizedBox(height: 20),
//                 _buildExpenseForm(),
//                 const SizedBox(height: 20),
//                 const Divider(),
//                 const SizedBox(height: 10),
//                 Text("Expenses", style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 10),
//                 if (filteredExpenses.isEmpty)
//                   const Center(child: Text("No expenses found"))
//                 else
//                   ...groupedExpenses.entries.map((entry) {
//                     final date = entry.key;
//                     final transactions = entry.value;
//                     final totalAmount = transactions.fold(0.0, (sum, e) => sum + e.amount!);
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "${DateFormat('dd MMM yyyy').format(date)} - Total: ₹${totalAmount.toStringAsFixed(2)}",
//                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         const SizedBox(height: 6),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: transactions.length,
//                           itemBuilder: (_, i) {
//                             final e = transactions[i];
//                             final DateTime istTime = e.createdAt!.add(const Duration(hours: 5, minutes: 30));
//                             final String billTime = DateFormat('hh:mm a').format(istTime);
//                             return Card(
//                               margin: const EdgeInsets.symmetric(vertical: 6),
//                               child: ListTile(
//                                 onTap: () {
//                                   Get.to(() => ExpenseDetailScreen(expense: {
//                                     'amount': e.amount,
//                                     'desc': e.description,
//                                     'date': e.createdAt,
//                                     'image': e.bill,
//                                   }));
//                                 },
//                                 leading: _buildBillThumbnail(e.bill),
//                                 title: Text("₹${e.amount} - ${e.description}"),
//                                 subtitle: Text('Added at $billTime'),
//                                 trailing: const Icon(Icons.chevron_right),
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                       ],
//                     );
//                   }),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildBalanceCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text("Balance Available", style: TextStyle(fontSize: 16, color: Colors.black54)),
//             const SizedBox(height: 10),
//             Text(
//               "₹${_expensesController.wallet.value.balance}",
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildExpenseForm() {
//     return Column(
//       children: [
//         _buildTextField(amountCtrl, "Amount", Icons.currency_rupee),
//         const SizedBox(height: 12),
//         _buildTextField(descCtrl, "Description", Icons.description),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             ElevatedButton.icon(
//               onPressed: pickImage,
//               icon: const Icon(Icons.image),
//               label: const Text("Upload Bill (Optional)"),
//             ),
//             const SizedBox(width: 10),
//             if (billImage != null) const Text("Image Selected ✅"),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: addExpense,
//           style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
//           child: const Text("Add Expense"),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
//     return TextField(
//       controller: controller,
//       keyboardType: hint == "Amount" ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(
//         labelText: hint,
//         prefixIcon: Icon(icon),
//         filled: true,
//         fillColor: Colors.grey[100],
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
//       ),
//     );
//   }
//
//   Widget _buildBillThumbnail(String? url) {
//     if (url != null && url.isNotEmpty) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Image.network(
//           url,
//           width: 50,
//           height: 50,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => Container(
//             width: 50,
//             height: 50,
//             color: Colors.grey[300],
//             child: const Icon(Icons.broken_image),
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: 50,
//         height: 50,
//         color: Colors.grey[200],
//         child: const Icon(Icons.receipt_long),
//       );
//     }
//   }
//
//   Map<DateTime, List<dynamic>> _groupExpensesByDate(List<dynamic> expenses) {
//     Map<DateTime, List<dynamic>> grouped = {};
//     for (var e in expenses) {
//       final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
//       if (!grouped.containsKey(date)) {
//         grouped[date] = [];
//       }
//       grouped[date]!.add(e);
//     }
//     return grouped;
//   }
// }
