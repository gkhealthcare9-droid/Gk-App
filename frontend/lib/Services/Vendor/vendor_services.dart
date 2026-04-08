import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Vendor/Vendor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Category/getcategory_model.dart';
import '../../Models/Employee/add_vendor_employee_model.dart';
import '../../Utils/Appconstants.dart';

class VendorServices {
  final Dio _dio = Dio();

  Future<VendorModel?> fetchVendorById(String unique) async {
    print('📥 Calling fetchVendorById with unique: $unique');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      print('🔑 Retrieved token: $token');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final url =
          '${AppConstants.BASE_URL}${AppConstants.VENDORByUNIQUE}/$unique';
      print('🌐 Sending GET request to: $url');

      final response = await _dio.get(url);

      print('📦 Response Status: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Successfully fetched vendor data');
        return VendorModel.fromJson(response.data);
      } else {
        print('❌ Failed to fetch vendor data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🛑 Error in fetchVendorByUnique: $e');
      return null;
    }
  }

  Future<List<VendorModel>?> fetchVendors() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.VENDOR}',
      );

      if (response.statusCode == 200) {
        print(response.data);
        if (response.data is List) {
          return (response.data as List)
              .map((item) => VendorModel.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${response.data}');
          return null;
        }
      } else {
        print('Failed to fetch vendors: ${response.statusCode}');
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

  Future<Response> addvendor(AddVendorModel vendor) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('Session expired, please login again.');
      } else {
        print(token);
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.VENDOR}/add',
        data: vendor.toJson(),
      );

      return response;
    } on DioException catch (e) {
      print('Error during upload: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during signup: $e');
      rethrow;
    }
  }

  Future<Response> editvendor(String id, AddVendorModel vendor) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        '${AppConstants.BASE_URL}${AppConstants.VENDOR}/$id',
        data: vendor.toJson(),
      );

      return response;
    } on DioException catch (e) {
      print('Error during update: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during update: $e');
      rethrow;
    }
  }

  Future<Response> deletevendor(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.delete(
        '${AppConstants.BASE_URL}${AppConstants.VENDOR}/$id',
      );

      return response;
    } on DioException catch (e) {
      print('Error during delete: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during delete: $e');
      rethrow;
    }
  }

  Future<List<GetCategoryModel>?> fetchCategory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.VENDOREMPLOYEECATEGORY}',
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => GetCategoryModel.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${response.data}');
          return null;
        }
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

  Future<Response> AddEmployee(AddvendorEmployee employee) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('Session expired, please login again.');
      } else {
        print(token);
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.VENDOREMPLOYEE}/add',
        data: employee.toJson(),
      );

      return response;
    } on DioException catch (e) {
      print('Error during upload: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during signup: $e');
      rethrow;
    }
  }

  Future<List<GetvendorEmployee>?> fetchvendoremployee(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.VENDOREMPLOYEE}/by-vendor/$id',
      );

      if (response.statusCode == 200) {
        print(response.data);
        if (response.data is List) {
          return (response.data as List)
              .map((item) => GetvendorEmployee.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${response.data}');
          return null;
        }
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

  Future<Response> editVendorEmployee(
    String id,
    AddvendorEmployee employee,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        '${AppConstants.BASE_URL}${AppConstants.VENDOREMPLOYEE}/$id',
        data: employee.toJson(),
      );

      return response;
    } on DioException catch (e) {
      print('Error during employee update: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during employee update: $e');
      rethrow;
    }
  }

  Future<Response> deleteVendorEmployee(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.delete(
        '${AppConstants.BASE_URL}${AppConstants.VENDOREMPLOYEE}/$id',
      );

      return response;
    } on DioException catch (e) {
      print('Error during employee delete: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during employee delete: $e');
      rethrow;
    }
  }

  Future<Response> updateVendorEmployee(
    String id,
    AddvendorEmployee employee,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        '${AppConstants.BASE_URL}${AppConstants.VENDOREMPLOYEE}/$id',
        data: employee.toJson(),
      );

      return response;
    } on DioException catch (e) {
      print('Error during employee update: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during employee update: $e');
      rethrow;
    }
  }
}
