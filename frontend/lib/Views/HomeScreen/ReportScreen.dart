import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import '../Reports/DeliveryChallan.dart';
import '../Reports/InstallationReport.dart';
import '../Reports/IncidentReport.dart';
import '../Reports/InspectionReport.dart';
import '../Reports/PurchaseOrderReport.dart';
import '../Reports/ServiceReport.dart';
import '../Reports/QuotationReport.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
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
        Get.to(() => InstallationReport());
        break;
      case 'Service':
        Get.to(() => ServiceRepotScreen());
        break;
      case 'Inspection':
        Get.to(() => InspectionReportScreen());
        break;
      case 'Incident':
        Get.to(() => IncidentReportscreen());
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
        CustomAlert.error('Screen not found for $option');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Reports'),
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
