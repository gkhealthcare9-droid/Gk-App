// lib/Services/Customer_service.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sales_grow/Models/Category/getcategory_model.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';
import 'package:sales_grow/Utils/AppConstants.dart';

import '../../Models/Outstanding/Customer_outstanding_model.dart';
import '../../Models/Outstanding/Outstanding_model.dart';

class CustomerServices {
  final Dio _dio = Dio();


  // Placeholder for fetching tasks
  // Future<List<TaskModel>?> fetchTasks() async {
  //   try {
  //     final response = await http.get(Uri.parse('your_api_endpoint/tasks'));
  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //       return (jsonData as List).map((e) => TaskModel.fromJson(e)).toList();
  //     }
  //     return null;
  //   } catch (e) {
  //     throw Exception('Failed to fetch tasks: $e');
  //   }
  // }
  /// Fetch all customers
  Future<List<CustomerModel>?> fetchCustomers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.CUSTOMER}',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => CustomerModel.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  /// Fetch a single customer by its unique identifier
  Future<CustomerModel?> fetchByUnique(String unique) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.CUSTOMERByUNIQUE}/$unique',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return CustomerModel.fromJson(response.data);
      } else {
        print('Failed to fetch customer: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  /// Fetch all employee‐position categories
  Future<List<GetCategoryModel>?> fetchCategory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.EmployeeCategory}',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => GetCategoryModel.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  /// Create a new employee under the given customer
  Future<Response> AddEmployee(AddEmployeeModel employee) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.Employee}/add',
        data: employee.toJson(),
      );
      return response;
    } on DioException catch (e) {
      print('Error during AddEmployee: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during AddEmployee: $e');
      rethrow;
    }
  }

  /// Fetch all employees for a given customer ID
  Future<List<GetEmployeeModel>?> fetchEmployees(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.Employee}/by-customer/$id',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => GetEmployeeModel.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch employees: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  /// Update an existing employee (by employeeId)
  Future<Response> updateEmployee(
    String employeeId,
    AddEmployeeModel updated,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.put(
        '${AppConstants.BASE_URL}${AppConstants.Employee}/$employeeId',
        data: updated.toJson(),
      );
      return response;
    } on DioException catch (e) {
      print('Error during updateEmployee: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during updateEmployee: $e');
      rethrow;
    }
  }

  /// Delete an existing employee (by employeeId)
  Future<Response> deleteEmployee(String employeeId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.delete(
        '${AppConstants.BASE_URL}${AppConstants.Employee}/$employeeId',
      );
      return response;
    } on DioException catch (e) {
      print('Error during deleteEmployee: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during deleteEmployee: $e');
      rethrow;
    }
  }

  /// Create a new customer
  Future<Response> AddCustomer(AddCustomerModel customer) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      print(
        '📤 Request URL: ${AppConstants.BASE_URL}${AppConstants.CUSTOMER}/add',
      );
      // print('📦 Payload: ${jsonEncode(customer.toJson())}');

      final response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.CUSTOMER}/add',
        data: customer.toJson(),
      );

      print('✅ Dio Response Status Code: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Dio Error Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('💥 Unexpected Error: $e');
      rethrow;
    }
  }

  /// Edit (update) an existing customer by ID
  Future<Response> editCustomer(String id, AddCustomerModel customer) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.put(
        '${AppConstants.BASE_URL}${AppConstants.CUSTOMER}/$id',
        data: customer.toJson(),
      );
      return response;
    } on DioException catch (e) {
      print('Error during editCustomer: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during editCustomer: $e');
      rethrow;
    }
  }

  /// Delete an existing customer by ID
  Future<Response> deleteCustomer(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.delete(
        '${AppConstants.BASE_URL}${AppConstants.CUSTOMER}/$id',
      );
      return response;
    } on DioException catch (e) {
      print('Error during deleteCustomer: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during deleteCustomer: $e');
      rethrow;
    }
  }

  /// Fetch all customer outstanding details
  Future<CustomerOutstandingModel?> fetchAllCustomerOutstanding(
    String id,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.GETCUSTOMEROUTSTANDING}/$id',
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return CustomerOutstandingModel.fromJson(response.data);
      } else {
        print('Failed to fetch customer outstanding: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  Future<CustomerOutstandingModel?> fetchpayment(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}/api/v1/customer/payment/add-payment',
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return CustomerOutstandingModel.fromJson(response.data);
      } else {
        print('Failed to fetch customer outstanding: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  Future<List<OutstandingModel>?> fetchAllOutstanding() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}/api/v1/customer/payment',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => OutstandingModel.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch customer outstanding: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  Future<Response> addOutstanding(
    String customer,
    int amount,
    String type,
    String invoiceNumber,
    String description,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final payload = {
        "customer": customer,
        "amount": amount,
        "type": type,
        "invoiceNumber": invoiceNumber,
        "description": description,
      };
      final response = await _dio.post(
        '${AppConstants.BASE_URL}/api/v1/customer/payment/add-payment',
        data: payload,
      );
      return response;
    } on DioException catch (e) {
      print('Error during AddCustomer: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during AddCustomer: $e');
      rethrow;
    }
  }
}
