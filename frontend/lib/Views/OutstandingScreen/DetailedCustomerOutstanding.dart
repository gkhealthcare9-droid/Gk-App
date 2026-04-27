import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Utils/Colors.dart';
import 'package:sales_grow/Controllers/AddCustomer/Customer_controller.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';

class Detailedcustomeroutstanding extends StatefulWidget {
  final String customerId;
  const Detailedcustomeroutstanding({super.key, required this.customerId});

  @override
  State<Detailedcustomeroutstanding> createState() =>
      _DetailedcustomeroutstandingState();
}

class _DetailedcustomeroutstandingState
    extends State<Detailedcustomeroutstanding> {
  final CustomerController _controller = Get.put(CustomerController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _controller.fetchAllCustomerOutstanding(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text("Customer Outstanding"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = _controller.outstandingData.value;

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(data.initialDue, data.currentDue),
                    const SizedBox(height: 20),
                    const Text(
                      "Payment History",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: data.payments.isEmpty
                          ? const Center(child: Text("No payments found."))
                          : ListView.builder(
                        itemCount: data.payments.length,
                        itemBuilder: (context, index) {
                          final payment = data.payments[index];
                          final isDebit = payment.type.toLowerCase() == 'debit';
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDebit
                                    ? Colors.red.shade100
                                    : Colors.green.shade100,
                                child: Icon(
                                  isDebit
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: isDebit ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(
                                '₹${payment.amount}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${payment.type.toUpperCase()} | Invoice: ${payment.invoiceNumber}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  if (payment.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        payment.description,
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.black54),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Text(
                                DateFormat('dd MMM, yyyy')
                                    .format(payment.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔽 Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text("Receive Payment"),
                      onPressed: () => _showPaymentDialog('credit'),

                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.upload),
                      label: const Text("Add Outstanding"),
                      onPressed: () => _showPaymentDialog('debit'),

                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  void _showPaymentDialog(String type) {
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController invoiceCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(type == 'credit' ? 'Receive Payment' : 'Add Outstanding'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: invoiceCtrl,
                decoration: const InputDecoration(labelText: 'Invoice Number'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final int? amount = int.tryParse(amountCtrl.text);
              if (amount == null ||
                  invoiceCtrl.text.isEmpty ||
                  descCtrl.text.isEmpty) {
                CustomAlert.error("Please fill all fields correctly");
                return;
              }

              await _controller.addOutstaning(
                widget.customerId,
                amount,
                type,
                invoiceCtrl.text,
                descCtrl.text,
              );

              await _controller.fetchAllCustomerOutstanding(widget.customerId);

              Get.back();
              CustomAlert.success(type == 'credit'
                  ? 'Payment received successfully'
                  : 'Outstanding added successfully');
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int initialDue, int currentDue) {
    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            label: "Initial Due",
            amount: initialDue,
            color: Colors.orange,
            icon: Icons.history,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            label: "Current Due",
            amount: currentDue,
            color: Colors.red,
            icon: Icons.warning,
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '₹$amount',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
