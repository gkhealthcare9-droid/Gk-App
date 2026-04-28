import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sales_grow/Helpers/download_helper.dart'
    if (dart.library.html) 'package:sales_grow/Helpers/download_helper_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/Outstanding/Outstanding_model.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:sales_grow/Views/Customer/CustomerList.dart';

import '../../Models/Category/getcategory_model.dart';
import 'package:sales_grow/Models/CustomerContact/CustomerContactModel.dart';
import 'package:sales_grow/Models/Outstanding/Customer_outstanding_model.dart';
import 'package:sales_grow/Services/customer/Customer_services.dart';

class CustomerController extends GetxController {
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filteredList = <OutstandingModel>[].obs;
  var isFilterExpanded = false.obs;
  var selectedCity = ''.obs;
  var selectedState = ''.obs;

  var dueOnly = false.obs;
  var customers = <CustomerModel>[].obs;
  var customer = CustomerModel().obs;
  var hospitalContacts =
      <GetCustomerContactModel>[].obs; // Renamed from employees
  var contactPositionList =
      <ContactPositionModel>[].obs; // Renamed from categoryList
  var employeeCategories = <GetCategoryModel>[].obs; // For internal staff

  // Legacy Getters to support unmigrated views
  RxList<GetCustomerContactModel> get employees => hospitalContacts;
  RxList<ContactPositionModel> get categoryList => contactPositionList;
  final CustomerServices _customerServices = CustomerServices();
  final RxBool isCustomerFound = false.obs;

  RxString selectedEngineerName = ''.obs;
  var outstandingData =
      CustomerOutstandingModel(
        id: '',
        initialDue: 0,
        currentDue: 0,
        customer: 'customer',
        payments: [],
        v: 1,
      ).obs;
  var alloutstanding = <OutstandingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  void clearData() {
    customers.clear();
    hospitalContacts.clear();

    isLoading.value = false;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    filterOutstandingList();
  }

  void filterOutstandingList() {
    List<OutstandingModel> filtered =
        alloutstanding.where((out) {
          final query = searchQuery.value.toLowerCase();
          final matchesSearch =
              query.isEmpty ||
              out.customer.customerCompany.toLowerCase().contains(query) ||
              out.customer.customerName.toLowerCase().contains(query) ||
              out.customer.customerPhone.toLowerCase().contains(query) ||
              out.customer.city.toLowerCase().contains(query) ||
              out.customer.state.toLowerCase().contains(query);

          final matchesCity =
              selectedCity.value.isEmpty ||
              out.customer.city == selectedCity.value;
          final matchesState =
              selectedState.value.isEmpty ||
              out.customer.state == selectedState.value;
          final matchesDue = !dueOnly.value || out.currentDue > 0;

          return matchesSearch && matchesCity && matchesState && matchesDue;
        }).toList();

    filteredList.assignAll(filtered);
  }

  void updateFilters({
    String? name,
    String? company,
    bool? due,
    String? city,
    String? state,
  }) {
    // if (name != null) nameFilter.value = name.toLowerCase();
    // if (company != null) companyFilter.value = company.toLowerCase();
    if (due != null) dueOnly.value = due;
    if (city != null) selectedCity.value = city;
    if (state != null) selectedState.value = state;
    filterOutstandingList();
  }

  Future<void> addContactPosition(String position) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.addContactPosition(position);
      if (response.statusCode == 201 || response.statusCode == 200) {
        CustomAlert.success('Position added successfully');
        await fetchContactPositions();
      } else {
        CustomAlert.error('Failed to add position');
      }
    } catch (e) {
      CustomAlert.error('Error adding position: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateContactPosition(String id, String position) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.updateContactPosition(id, position);
      if (response.statusCode == 200) {
        CustomAlert.success('Position updated successfully');
        await fetchContactPositions();
      } else {
        CustomAlert.error('Failed to update position');
      }
    } catch (e) {
      CustomAlert.error('Error updating position: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteContactPosition(dynamic id) async {
    isLoading.value = true;
    try {
      final String idStr = id.toString();
      final response = await _customerServices.deleteContactPosition(idStr);
      if (response.statusCode == 200) {
        CustomAlert.success('Position deleted successfully');
        await fetchContactPositions();
      } else {
        // The backend might return 400 if it's in use
        String msg = response.data?['message'] ?? 'Failed to delete position';
        CustomAlert.error(msg);
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        CustomAlert.error(e.response?.data['message'] ?? 'Error deleting position');
      } else {
        CustomAlert.error('Error deleting position: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  var isPositionsLoading = false.obs;

  Future<void> fetchContactPositions() async {
    isPositionsLoading.value = true;
    try {
      final fetched = await _customerServices.fetchContactPositions();
      if (fetched != null) {
        contactPositionList.assignAll(fetched);
      } else {
        CustomAlert.error("No position data found");
      }
    } catch (e) {
      CustomAlert.error("Failed to fetch positions: $e");
    } finally {
      isPositionsLoading.value = false;
    }
  }

  // Keep for legacy compatibility if needed
  Future<void> fetchCategories() async {
    await fetchContactPositions();
  }

  Future<void> fetchEmployeeCategories() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final fetched = await _customerServices.fetchCategoriesByType('Employee');
      if (fetched != null) {
        employeeCategories.assignAll(fetched);
      }
    } catch (e) {
      CustomAlert.error("Failed to fetch staff categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addEmployeeCategory(String category) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.addStaffCategory(category);
      if (response.statusCode == 201 || response.statusCode == 200) {
        CustomAlert.success('Category added successfully');
        await fetchEmployeeCategories();
      }
    } catch (e) {
      CustomAlert.error('Error adding category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEmployeeCategory(String id, String category) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.updateStaffCategory(id, category);
      if (response.statusCode == 200) {
        CustomAlert.success('Category updated successfully');
        await fetchEmployeeCategories();
      }
    } catch (e) {
      CustomAlert.error('Error updating category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEmployeeCategory(dynamic id) async {
    isLoading.value = true;
    try {
      final String idStr = id.toString();
      final response = await _customerServices.deleteStaffCategory(idStr);
      if (response.statusCode == 200) {
        CustomAlert.success('Category deleted successfully');
        await fetchEmployeeCategories();
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

  Future<void> fetchCustomers() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      List<CustomerModel>? fetchedCustomers =
          await _customerServices.fetchCustomers();
      if (fetchedCustomers != null) {
        customers.assignAll(fetchedCustomers); // Replace existing list
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerByUnique(String unique) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final fetchedCustomer = await _customerServices.fetchByUnique(unique);
      if (fetchedCustomer != null && fetchedCustomer.customerName != null) {
        customer.value = fetchedCustomer;
        isCustomerFound.value = true; // ✅ found
      } else {
        isCustomerFound.value = false; // ❌ not found
        customer.value = CustomerModel(); // clear stale data
      }
    } catch (e) {
      isCustomerFound.value = false;
      CustomAlert.error('Failed to fetch customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchalloutstanding() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetchedAllOutstanding =
          await _customerServices.fetchAllOutstanding();
      if (fetchedAllOutstanding != null) {
        alloutstanding.assignAll(fetchedAllOutstanding);
        filterOutstandingList(); // <- Apply filter after fetch
      }
    } catch (e) {
      // handle if needed
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> AddCustomerContact(AddCustomerContactModel contact) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.AddCustomerContact(contact);
      print(
        'AddCustomerContact success: ${response.statusCode} - ${response.data}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Contact added successfully');
        await fetchCustomerContacts(contact.customer!);
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
        return true;
      } else {
        CustomAlert.error(
          'Failed to add contact: ${response.statusMessage}',
        );
        return false;
      }
    } catch (e) {
      print('AddCustomerContact error: $e');
      CustomAlert.error(
        'Something went wrong while adding contact: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Legacy wrapper to avoid breaking older UI calls
  Future<bool> AddEmployee(dynamic data) async {
    if (data is AddCustomerContactModel) {
      return await AddCustomerContact(data);
    }
    return false;
  }

  Future<bool> updateCustomerContact(
    String contactId,
    AddCustomerContactModel updated,
  ) async {
    isLoading.value = true;
    try {
      print("⏳ Updating contact $contactId...");
      print("Payload: ${updated.toJson()}");

      final response = await _customerServices.updateCustomerContact(
        contactId,
        updated,
      );

      print("✅ Server response for update: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Contact updated successfully');
        await fetchCustomerContacts(updated.customer!);
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
        return true;
      } else {
        CustomAlert.error(
          'Failed to update contact: ${response.statusMessage}',
        );
        return false;
      }
    } catch (e) {
      print("🚨 Exception during update: $e");
      CustomAlert.error(
        'Something went wrong while updating contact: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Legacy wrapper
  Future<bool> updateEmployee(String id, dynamic updated) async {
    if (updated is AddCustomerContactModel) {
      return await updateCustomerContact(id, updated);
    }
    return false;
  }

  // Inside CustomerController

  Future<void> deleteCustomerContact(String id, String customerId) async {
    try {
      isLoading.value = true;
      final response = await _customerServices.deleteCustomerContact(id);
      if (response.statusCode == 200) {
        await fetchCustomerContacts(customerId);
        CustomAlert.success('Contact deleted');
      } else {
        CustomAlert.error(
          'Failed to delete contact: ${response.statusMessage}',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Legacy wrapper
  Future<void> deleteEmployee(String id, String customerId) async {
    await deleteCustomerContact(id, customerId);
  }

  Future<void> fetchCustomerContacts(String id) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      List<GetCustomerContactModel>? fetchedContacts = await _customerServices
          .fetchCustomerContacts(id);
      if (fetchedContacts != null) {
        hospitalContacts.assignAll(fetchedContacts);
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Legacy wrapper
  Future<void> fetchEmployees(String id) async {
    await fetchCustomerContacts(id);
  }

  /// Add a new customer
  Future<void> addCustomer(AddCustomerModel customer) async {
    isLoading.value = true;
    try {
      print("⏳ Sending customer add request...");
      final response = await _customerServices.AddCustomer(customer).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception("⏰ Server took too long to respond (timeout)");
        },
      );

      print("✅ Server responded with status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("🎉 Customer added successfully: ${response.data}");
        await fetchCustomers();
        isLoading.value = false;

        CustomAlert.success('Customer added successfully');
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        print("❌ Failed to add customer:");
        print("Status Code: ${response.statusCode}");
        print("Response: ${response.data}");
        CustomAlert.error(
          'Failed to add customer: ${response.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 Exception occurred: $e');
      print('📍 Stack trace: $stackTrace');
      CustomAlert.error('Something went wrong while adding customer');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      final response = await _customerServices.deleteCustomer(customerId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        customers.removeWhere((c) => c.id == customerId);

        CustomAlert.success('Customer deleted successfully');
        await Future.delayed(const Duration(seconds: 2));
        Get.back(); // ⬅️ Auto-navigate back
        update(); // optional if you're using GetBuilder
      } else {
        CustomAlert.error(
          'Failed to delete customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error(
        'Failed to delete customer: $e',
      );
    }
  }

  /// ✅ EDIT customer
  Future<void> editCustomer(String id, AddCustomerModel customer) async {
    isLoading.value = true;
    try {
      print('Updating customer ID: $id');
      print('Payload: ${customer.toJson()}');
      final response = await _customerServices.editCustomer(id, customer);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCustomers(); // Refresh customers list
        isLoading.value = false;

        CustomAlert.success('Customer updated successfully');
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        CustomAlert.error(
          'Failed to update customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Something went wrong while updating customer: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllCustomerOutstanding(String id) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetchedOutstanding = await _customerServices
          .fetchAllCustomerOutstanding(id);
      if (fetchedOutstanding != null) {
        outstandingData.value = fetchedOutstanding;
      } else {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOutstaning(
    String customer,
    int amount,
    String type,
    String invoiceNumber,
    String description,
  ) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.addOutstanding(
        customer,
        amount,
        type,
        invoiceNumber,
        description,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomAlert.success('Payment added successfully');

        await fetchalloutstanding(); // ✅ Refresh the list after adding

        // ✅ After fetch, navigate safely to CustomAppBar
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(
          () => CustomBottomNavBar(),
        ); // << Your CustomAppBar screen here
      } else {
        CustomAlert.error(
          'Failed to add payment: ${response.statusMessage}',
        );
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importExcel() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Necessary for Web to get bytes
      );

      if (result != null && result.files.single.bytes != null) {
        isLoading.value = true;

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        final response = await _customerServices.importCustomers(
          bytes,
          fileName,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final errors = response.data['errors'];
          if (errors != null && errors is List && errors.isNotEmpty) {
            Get.defaultDialog(
              title: "Import Finished with Warnings",
              content: Text(
                "Imported ${response.data['count']} records. ${errors.length} rows had errors.",
              ),
              confirm: TextButton(
                onPressed: () => Get.back(),
                child: Text("OK"),
              ),
            );
          } else {
            CustomAlert.success(
              response.data['message'] ?? 'Import successful',
            );
          }
          await fetchCustomers();
        } else {
          CustomAlert.error('Import failed: ${response.statusMessage}');
        }
      } else {
        CustomAlert.error('No file data received. Please try again.');
      }
    } catch (e) {
      print('Import Error: $e');
      CustomAlert.error('An error occurred during import: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToExcel() async {
    try {
      isLoading.value = true;
      final response = await _customerServices.exportCustomers();

      if (response.statusCode == 200) {
        // Handle download for Web
        final fName =
            "customers_export_${DateTime.now().millisecondsSinceEpoch}.xlsx";
        final mime =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        await downloadFile(List<int>.from(response.data), fName, mime);

        CustomAlert.success('Excel file exported successfully');
      } else {
        CustomAlert.error('Export failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Export Error: $e');
      CustomAlert.error(
        'An error occurred during export: $e. Make sure you are on a compatible browser.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
