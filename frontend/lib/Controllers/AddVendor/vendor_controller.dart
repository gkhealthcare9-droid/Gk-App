import 'package:get/get.dart';
import 'package:sales_grow/Models/Employee/add_vendor_employee_model.dart';
import 'package:sales_grow/Models/Vendor/Vendor.dart';
import 'package:sales_grow/Services/Vendor/vendor_services.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import '../../Models/Category/getcategory_model.dart';

class VendorController extends GetxController {
  var isLoading = false.obs;
  var vendors = <VendorModel>[].obs;
  var employees = <GetvendorEmployee>[].obs;
  var categoryList = <GetCategoryModel>[].obs;

  final VendorServices _VendorServices = VendorServices();

  void clearData() {
    vendors.clear();
    isLoading.value = false;
  }

  Future<void> fetchVendors() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      List<VendorModel>? fetchedVendors = await _VendorServices.fetchVendors();
      if (fetchedVendors != null) {
        vendors.assignAll(fetchedVendors);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEmployees(String id) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      List<GetvendorEmployee>? fetchedCustomers =
          await _VendorServices.fetchvendoremployee(id);
      if (fetchedCustomers != null) {
        employees.assignAll(fetchedCustomers);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final fetched = await _VendorServices.fetchCategory();
      if (fetched != null) {
        categoryList.assignAll(fetched);
      } else {
        Get.snackbar("Error", "No category data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> AddEmployee(AddvendorEmployee employee) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.AddEmployee(employee);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Customer added successfully');
        await fetchEmployees(employee.vendor!);
      } else {
        Get.snackbar(
          'Error',
          'Failed to add customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while adding customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addvendor(AddVendorModel vendor) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.addvendor(vendor);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Vendor added successfully');
        await fetchVendors();
        Future.delayed(Duration.zero, () {
          Get.offAll(() => CustomBottomNavBar());
        });
      } else {
        Get.snackbar(
          'Error',
          'Failed to add vendor: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while adding vendor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletevendor(String id) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.deletevendor(id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Customer Deleted successfully');
        clearData();
        await fetchVendors();
      } else {
        Get.snackbar(
          'Error',
          'Failed to Delete customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while adding customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editVendor(String id, AddVendorModel vendor) async {
    try {
      isLoading.value = true;
      final response = await _VendorServices.editvendor(id, vendor);
      if (response.statusCode == 200 || response.statusCode == 201) {
        clearData();
        await fetchVendors();
        Get.offAll(() => CustomBottomNavBar());
        Get.snackbar('Success', 'Vendor updated successfully');
      } else {
        Get.snackbar(
          'Error',
          'Failed to update vendor: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editVendorEmployee(String id, AddvendorEmployee employee) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.editVendorEmployee(id, employee);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Employee updated successfully');
        await fetchEmployees(employee.vendor!);
        Future.delayed(Duration.zero, () {
          Get.offAll(() => CustomBottomNavBar());
        });
      } else {
        Get.snackbar(
          'Error',
          'Failed to update employee: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Employee update failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVendorEmployee(String id, String vendorId) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.deleteVendorEmployee(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Success', 'Employee deleted successfully');
        await fetchEmployees(vendorId);
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete employee: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while deleting employee: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<VendorModel?> fetchVendorById(String vendorId) async {
    print('VendorController calling fetchVendorById with: $vendorId');
    if (isLoading.value) return null;
    isLoading.value = true;
    try {
      final vendor = await _VendorServices.fetchVendorById(vendorId);
      if (vendor == null) {
        print('Vendor fetch returned null for ID: $vendorId');
      }
      return vendor;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch vendor: $e");
      print('Error details: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
