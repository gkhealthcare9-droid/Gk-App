import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Employee/AddEmployee_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/Appconstants.dart';

class Employeeservices{
  final Dio _dio = Dio();
  Future<List<GetEmployeeModel>?> fetchEmployees(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.Employee}/$id',
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => GetEmployeeModel.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${response.data}');
          return null;
        }
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

}


class VendorEmployeeServices{
  final Dio _dio = Dio();




}