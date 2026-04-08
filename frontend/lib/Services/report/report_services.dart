import 'package:dio/dio.dart';
import 'package:sales_grow/Models/report/Manufacturer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/Appconstants.dart';

class ReportServices{

  final Dio _dio = Dio();

  Future<List<GetManufacturerModel>?> fetchManufacturer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.GETMANUFACTURER}',
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => GetManufacturerModel.fromJson(item))
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