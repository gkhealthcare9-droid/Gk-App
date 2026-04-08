import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';
import 'package:sales_grow/Models/Outstanding/Outstanding_model.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';

import '../../Models/Category/getcategory_model.dart';
import '../../Models/Outstanding/Customer_outstanding_model.dart';
import '../../Services/customer/Customer_services.dart';

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
  var employees = <GetEmployeeModel>[].obs;
  var categoryList = <GetCategoryModel>[].obs; // ✅ Define the list here
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

  void clearData() {
    customers.clear();
    employees.clear();

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

  Future<void> fetchCategories() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetched = await _customerServices.fetchCategory();
      if (fetched != null) {
        categoryList.assignAll(fetched); // ✅ This now works
      } else {
        Get.snackbar("Error", "No category data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
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
      Get.snackbar('Error', 'Something went wrong: $e');
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
      Get.snackbar('Error', 'Failed to fetch customer: $e');
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

  Future<void> AddEmployee(AddEmployeeModel employee) async {
    isLoading.value = true;
    try {
      final response = await _customerServices.AddEmployee(employee);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Customer added successfully');
        await fetchEmployees(employee.customer!); // Optionally refresh the list
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

  Future<bool> updateEmployee(
    String employeeId,
    AddEmployeeModel updated,
  ) async {
    isLoading.value = true;
    try {
      // Assume your service has an `updateEmployee` PUT/PATCH endpoint:
      final response = await _customerServices.updateEmployee(
        employeeId,
        updated,
      );

      if (response.statusCode == 200) {
        // Optionally refresh the employee list after a successful update
        await fetchEmployees(updated.customer!);
        Get.snackbar('Success', 'Employee updated successfully');
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update employee: ${response.statusMessage}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong while updating employee: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Inside CustomerController

  Future<void> deleteEmployee(String id, String customerId) async {
    try {
      isLoading.value = true;
      final response = await _customerServices.deleteEmployee(id);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Employee deleted');
        await fetchEmployees(customerId);
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete employee: ${response.statusMessage}',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEmployees(String id) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      List<GetEmployeeModel>? fetchedCustomers = await _customerServices
          .fetchEmployees(id);
      if (fetchedCustomers != null) {
        employees.assignAll(fetchedCustomers); // Replace existing list
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
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
        Get.snackbar('Success', 'Customer added successfully');
        await fetchCustomers();
        Get.offAll(() => CustomBottomNavBar());
      } else {
        print("❌ Failed to add customer:");
        print("Status Code: ${response.statusCode}");
        print("Response: ${response.data}");
        Get.snackbar(
          'Error',
          'Failed to add customer: ${response.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 Exception occurred: $e');
      print('📍 Stack trace: $stackTrace');
      Get.snackbar('Error', 'Something went wrong while adding customer');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      final response = await _customerServices.deleteCustomer(customerId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        customers.removeWhere((c) => c.id == customerId);
        Get.back(); // ⬅️ Auto-navigate back
        Get.snackbar('Deleted', 'Customer deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        update(); // optional if you're using GetBuilder
      } else {
        Get.snackbar('Error', 'Failed to delete customer',
            backgroundColor: Colors.red, colorText: Colors.white);
        Get.snackbar(
          'Error',
          'Failed to Delete customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete customer: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
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
        Get.offAll(() => CustomBottomNavBar()); // Navigate to CustomersList
        Get.snackbar('Success', 'Customer updated successfully');
      } else {
        Get.snackbar(
          'Error',
          'Failed to update customer: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while updating customer: $e');
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
        Get.snackbar('Success', 'Customer added successfully');

        await fetchalloutstanding(); // ✅ Refresh the list after adding

        // ✅ After fetch, navigate safely to CustomAppBar
        Future.delayed(Duration.zero, () {
          Get.offAll(
            () => CustomBottomNavBar(),
          ); // << Your CustomAppBar screen here
        });
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

  // Future<void> fetchalloutstanding() async {
  //   if (isLoading.value) return;
  //
  //   isLoading.value = true;
  //   try {
  //     final fetcheddallOutstanding = await _customerServices.fetchAllOutstanding();
  //     if (fetcheddallOutstanding != null) {
  //       alloutstanding.assignAll(fetcheddallOutstanding);
  //     } else {
  //     }
  //   } catch (e) {
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
