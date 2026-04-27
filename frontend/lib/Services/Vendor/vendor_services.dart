import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Vendor/Vendor.dart';
import '../ApiService.dart';
import '../../Models/Category/getcategory_model.dart';
import '../../Models/Employee/add_vendor_employee_model.dart';
import '../../Utils/Appconstants.dart';

class VendorServices {
  final Dio _dio = ApiService().dio;

  Future<VendorModel?> fetchVendorById(String unique) async {
    try {
      final response = await _dio.get('${AppConstants.VENDORByUNIQUE}/$unique');

      if (response.statusCode == 200) {
        return VendorModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error in fetchVendorById: $e');
      return null;
    }
  }

  Future<List<VendorModel>?> fetchVendors() async {
    try {
      final response = await _dio.get(AppConstants.VENDOR);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => VendorModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching vendors: $e');
      return null;
    }
  }

  Future<Response> addvendor(AddVendorModel vendor) async {
    try {
      return await _dio.post(
        '${AppConstants.VENDOR}/add',
        data: vendor.toJson(),
      );
    } catch (e) {
      print('Error adding vendor: $e');
      rethrow;
    }
  }

  Future<Response> editvendor(String id, AddVendorModel vendor) async {
    try {
      return await _dio.put(
        '${AppConstants.VENDOR}/$id',
        data: vendor.toJson(),
      );
    } catch (e) {
      print('Error editing vendor: $e');
      rethrow;
    }
  }

  Future<Response> deletevendor(String id) async {
    try {
      return await _dio.delete('${AppConstants.VENDOR}/$id');
    } catch (e) {
      print('Error deleting vendor: $e');
      rethrow;
    }
  }

  Future<List<GetCategoryModel>?> fetchCategory() async {
    try {
      final response = await _dio.get(AppConstants.VENDOREMPLOYEECATEGORY);

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

  Future<Response> AddEmployee(AddvendorEmployee employee) async {
    try {
      return await _dio.post(
        '${AppConstants.VENDOREMPLOYEE}/add',
        data: employee.toJson(),
      );
    } catch (e) {
      print('Error adding employee: $e');
      rethrow;
    }
  }

  Future<List<GetvendorEmployee>?> fetchvendoremployee(String id) async {
    try {
      final response = await _dio.get(
        '${AppConstants.VENDOREMPLOYEE}/by-vendor/$id',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => GetvendorEmployee.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching vendor employees: $e');
      return null;
    }
  }

  Future<Response> editVendorEmployee(String id, AddvendorEmployee employee) async {
    try {
      return await _dio.put(
        '${AppConstants.VENDOREMPLOYEE}/$id',
        data: employee.toJson(),
      );
    } catch (e) {
      print('Error updating vendor employee: $e');
      rethrow;
    }
  }

  Future<Response> deleteVendorEmployee(String id) async {
    try {
      return await _dio.delete('${AppConstants.VENDOREMPLOYEE}/$id');
    } catch (e) {
      print('Error deleting vendor employee: $e');
      rethrow;
    }
  }

  Future<Response> updateVendorEmployee(String id, AddvendorEmployee employee) async {
    return editVendorEmployee(id, employee);
  }
}
