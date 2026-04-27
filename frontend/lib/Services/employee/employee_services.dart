import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';
import '../ApiService.dart';

class Employeeservices {
  final Dio _dio = ApiService().dio;

  Future<List<GetEmployeeModel>?> fetchEmployees(String id) async {
    try {
      final response = await _dio.get('/api/v1/user/by-customer/$id');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => GetEmployeeModel.fromJson(item))
              .toList();
        }
        return null;
      } else {
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

  Future<bool> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/v1/user/$id', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Update staff error: ${e.response?.data}');
      return false;
    }
  }
}
