import 'package:get/get.dart';
import 'package:sales_grow/Models/report/GenerateReports/Installation_Report_Model.dart';
import 'package:sales_grow/Models/report/Manufacturer.dart';
import 'package:sales_grow/Services/report/GenerateReportServices/Installation_Report_Services.dart';

import '../../Services/report/report_services.dart';

class ReportController extends GetxController {

  var isLoading = false.obs;
  var maufacturer = <GetManufacturerModel>[].obs; // ✅ Define the list here
  var installationReports = <FetchInstallationReport>[].obs;
  final ReportServices _reportServices = ReportServices();
  final InstallationReportService _installationReportService = InstallationReportService();


  Future<void> fetchManufacturer() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetched = await _reportServices.fetchManufacturer();
      if (fetched != null) {
        maufacturer.assignAll(fetched); // ✅ This now works
      } else {
        Get.snackbar("Error", "No category data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchInstallationReports() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetched = await _installationReportService.fetchinstallationreport();
      if (fetched != null) {
        installationReports.assignAll(fetched); // ✅ This now works
        print(installationReports.toList());
      } else {
        Get.snackbar("Error", "No category data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> addInstallation(PostInstallationReport report) async {
    isLoading.value = true;
    try {
      final response = await _installationReportService.addInstallation(report);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Customer added successfully');
      } else {
        Get.snackbar(
            'Error', 'Failed to add customer: ${response.statusMessage}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while adding customer: $e');
    } finally {
      isLoading.value = false;
    }
  }


}