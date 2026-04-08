import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import '../GetReportsScreens/InstallationReports.dart';
import '../Reports/DeliveryChallan.dart';
import '../Reports/PurchaseOrderReport.dart';
import '../Reports/ServiceReport.dart';
import '../Reports/QuotationReport.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  final List<Map<String, dynamic>> options = [
    {"label": "Installation", "icon": Icons.build},
    {"label": "Service", "icon": Icons.miscellaneous_services},
    {"label": "Inspection", "icon": Icons.search},
    {"label": "Incident", "icon": Icons.report_problem},
    {"label": "Quotation", "icon": Icons.home_repair_service},
    {"label": "Purchase Order", "icon": Icons.shopping_cart_checkout},
    {"label": "Delivery Challan", "icon": Icons.note_alt},
  ];

  void navigateToScreen(String option) {
    switch (option) {
      case 'Installation':
        Get.to(() => GetInstallationReports());
        break;
      case 'Service':
        Get.to(() => ServiceRepotScreen());
        break;
      case 'Inspection':
        // Get.to(() => InspectionViewReportScreen());
        break;
      case 'Incident':
        // Get.to(() => IncidentViewReportScreen());
        break;
      case 'Quotation':
        Get.to(() => AddQuotationScreen());
        break;
      case 'Purchase Order':
        Get.to(() => PurchaseOrderScreen());
        break;
      case 'Delivery Challan':
        Get.to(() => DeliveryChallanScreen());
        break;
      default:
        Get.snackbar('Error', 'Screen not found for $option');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'View Reports'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = options[index];
            return GestureDetector(
              onTap: () => navigateToScreen(item['label']),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      size: 48,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
