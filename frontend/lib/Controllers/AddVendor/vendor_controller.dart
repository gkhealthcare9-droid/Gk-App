import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Employee/add_vendor_employee_model.dart';
import 'package:sales_grow/Models/Vendor/Vendor.dart';
import 'package:sales_grow/Services/Vendor/vendor_services.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
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
      CustomAlert.error('Something went wrong: $e');
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
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final fetched = await _VendorServices.fetchCategories();
      if (fetched != null) {
        categoryList.assignAll(fetched);
      } else {
        CustomAlert.error("No category data found");
      }
    } catch (e) {
      CustomAlert.error("Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(String category) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.addCategory(category);
      if (response.statusCode == 201 || response.statusCode == 200) {
        CustomAlert.success('Category added successfully');
        await fetchCategories();
      }
    } catch (e) {
      CustomAlert.error('Error adding category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(String id, String category) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.updateCategory(id, category);
      if (response.statusCode == 200) {
        CustomAlert.success('Category updated successfully');
        await fetchCategories();
      }
    } catch (e) {
      CustomAlert.error('Error updating category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(dynamic id) async {
    isLoading.value = true;
    try {
      final String idStr = id.toString();
      final response = await _VendorServices.deleteCategory(idStr);
      if (response.statusCode == 200) {
        CustomAlert.success('Category deleted successfully');
        await fetchCategories();
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        CustomAlert.error(e.response?.data['message'] ?? 'Error deleting category');
      } else {
        CustomAlert.error('Error deleting category: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> AddEmployee(AddvendorEmployee employee) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.AddEmployee(employee);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Employee added successfully');
        await fetchEmployees(employee.vendor!);
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
      } else {
        CustomAlert.error(
          'Failed to add customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Something went wrong while adding customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addvendor(AddVendorModel vendor) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.addvendor(vendor);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Vendor added successfully');
        await fetchVendors();
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => CustomBottomNavBar());
      } else {
        CustomAlert.error(
          'Failed to add vendor: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Something went wrong while adding vendor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletevendor(String id) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.deletevendor(id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Vendor Deleted successfully');
        clearData();
        await fetchVendors();
      } else {
        CustomAlert.error(
          'Failed to Delete vendor: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Something went wrong while deleting vendor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editVendor(String id, AddVendorModel vendor) async {
    try {
      isLoading.value = true;
      final response = await _VendorServices.editvendor(id, vendor);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Vendor updated successfully');
        clearData();
        await fetchVendors();
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => CustomBottomNavBar());
      } else {
        CustomAlert.error(
          'Failed to update vendor: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Update failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editVendorEmployee(String id, AddvendorEmployee employee) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.editVendorEmployee(id, employee);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Employee updated successfully');
        await fetchEmployees(employee.vendor!);
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => CustomBottomNavBar());
      } else {
        CustomAlert.error(
          'Failed to update employee: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Employee update failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVendorEmployee(String id, String vendorId) async {
    isLoading.value = true;
    try {
      final response = await _VendorServices.deleteVendorEmployee(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        CustomAlert.success('Employee deleted successfully');
        await fetchEmployees(vendorId);
      } else {
        CustomAlert.error(
          'Failed to delete employee: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Something went wrong while deleting employee: $e');
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
      CustomAlert.error("Failed to fetch vendor: $e");
      print('Error details: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
