import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Category/getcategory_model.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Models/CustomerContact/CustomerContactModel.dart';
import 'package:sales_grow/Utils/AppConstants.dart';
import '../ApiService.dart';
import '../../Models/Outstanding/Customer_outstanding_model.dart';
import '../../Models/Outstanding/Outstanding_model.dart';

class CustomerServices {
  final Dio _dio = ApiService().dio;

  Future<List<CustomerModel>?> fetchCustomers() async {
    try {
      final response = await _dio.get(AppConstants.CUSTOMER);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => CustomerModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching customers: $e');
      return null;
    }
  }

  Future<CustomerModel?> fetchByUnique(String unique) async {
    try {
      final response = await _dio.get('${AppConstants.CUSTOMERByUNIQUE}/$unique');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return CustomerModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null; // Silently return null for 404
      }
      print('Error fetching customer by unique: $e');
      return null;
    }
  }

  Future<List<ContactPositionModel>?> fetchContactPositions() async {
    try {
      final response = await _dio.get(AppConstants.CONTACT_POSITION);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => ContactPositionModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching contact positions: $e');
      return null;
    }
  }

  Future<Response> addContactPosition(String position) async {
    try {
      return await _dio.post(
        AppConstants.CONTACT_POSITION,
        data: {"position": position},
      );
    } catch (e) {
      print('Error adding contact position: $e');
      rethrow;
    }
  }

  Future<Response> updateContactPosition(String id, String position) async {
    try {
      return await _dio.put(
        '${AppConstants.CONTACT_POSITION}/$id',
        data: {"position": position},
      );
    } catch (e) {
      print('Error updating contact position: $e');
      rethrow;
    }
  }

  Future<Response> deleteContactPosition(String id) async {
    try {
      return await _dio.delete('${AppConstants.CONTACT_POSITION}/$id');
    } catch (e) {
      print('Error deleting contact position: $e');
      rethrow;
    }
  }

  Future<List<GetCategoryModel>?> fetchCategoriesByType(String type) async {
    try {
      final response = await _dio.get('${AppConstants.CATEGORY}?type=$type');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => GetCategoryModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching categories: $e');
      return null;
    }
  }

  Future<Response> addStaffCategory(String category) async {
    try {
      return await _dio.post(
        '${AppConstants.Employee}/category',
        data: {"category": category},
      );
    } catch (e) {
      print('Error adding staff category: $e');
      rethrow;
    }
  }

  Future<Response> updateStaffCategory(String id, String category) async {
    try {
      return await _dio.put(
        '${AppConstants.Employee}/category/$id',
        data: {"category": category},
      );
    } catch (e) {
      print('Error updating staff category: $e');
      rethrow;
    }
  }

  Future<Response> deleteStaffCategory(String id) async {
    try {
      return await _dio.delete('${AppConstants.Employee}/category/$id');
    } catch (e) {
      print('Error deleting staff category: $e');
      rethrow;
    }
  }

  Future<Response> AddCustomerContact(AddCustomerContactModel contact) async {
    try {
      return await _dio.post(
        '${AppConstants.CUSTOMER_CONTACT}/add',
        data: contact.toJson(),
      );
    } catch (e) {
      print('Error adding customer contact: $e');
      rethrow;
    }
  }

  Future<List<GetCustomerContactModel>?> fetchCustomerContacts(String id) async {
    try {
      final response = await _dio.get(
        '${AppConstants.CUSTOMER_CONTACT}/by-customer/$id',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => GetCustomerContactModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching customer contacts: $e');
      return null;
    }
  }

  Future<Response> updateCustomerContact(String contactId, AddCustomerContactModel updated) async {
    try {
      return await _dio.put(
        '${AppConstants.CUSTOMER_CONTACT}/$contactId',
        data: updated.toJson(),
      );
    } catch (e) {
      print('Error updating customer contact: $e');
      rethrow;
    }
  }

  Future<Response> deleteCustomerContact(String contactId) async {
    try {
      return await _dio.delete('${AppConstants.CUSTOMER_CONTACT}/$contactId');
    } catch (e) {
      print('Error deleting customer contact: $e');
      rethrow;
    }
  }

  Future<Response> AddCustomer(AddCustomerModel customer) async {
    try {
      return await _dio.post(
        '${AppConstants.CUSTOMER}/add',
        data: customer.toJson(),
      );
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  Future<Response> editCustomer(String id, AddCustomerModel customer) async {
    try {
      return await _dio.put(
        '${AppConstants.CUSTOMER}/$id',
        data: customer.toJson(),
      );
    } catch (e) {
      print('Error editing customer: $e');
      rethrow;
    }
  }

  Future<Response> deleteCustomer(String id) async {
    try {
      return await _dio.delete('${AppConstants.CUSTOMER}/$id');
    } catch (e) {
      print('Error deleting customer: $e');
      rethrow;
    }
  }

  Future<CustomerOutstandingModel?> fetchAllCustomerOutstanding(String id) async {
    try {
      final response = await _dio.get('${AppConstants.GETCUSTOMEROUTSTANDING}/$id');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data is Map<String, dynamic>) {
        return CustomerOutstandingModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching customer outstanding: $e');
      return null;
    }
  }

  Future<List<OutstandingModel>?> fetchAllOutstanding() async {
    try {
      final response = await _dio.get('/api/v1/customer/payment');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => OutstandingModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching all outstanding: $e');
      return null;
    }
  }

  Future<Response> addOutstanding(String customer, int amount, String type, String invoiceNumber, String description) async {
    try {
      final payload = {
        "customer": customer,
        "amount": amount,
        "type": type,
        "invoiceNumber": invoiceNumber,
        "description": description,
      };
      return await _dio.post(
        '/api/v1/customer/payment/add-payment',
        data: payload,
      );
    } catch (e) {
      print('Error adding outstanding: $e');
      rethrow;
    }
  }

  Future<Response> importCustomers(Uint8List bytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });

      return await _dio.post(
        AppConstants.EXCEL_IMPORT,
        data: formData,
      );
    } catch (e) {
      print('Error importing customers: $e');
      rethrow;
    }
  }

  Future<Response> exportCustomers() async {
    try {
      return await _dio.get(
        AppConstants.EXCEL_EXPORT,
        options: Options(responseType: ResponseType.bytes),
      );
    } catch (e) {
      print('Error exporting customers: $e');
      rethrow;
    }
  }
}
