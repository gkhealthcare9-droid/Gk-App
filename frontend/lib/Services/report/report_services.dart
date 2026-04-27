import 'package:dio/dio.dart';
import 'package:sales_grow/Models/report/Manufacturer.dart';
import '../ApiService.dart';
import '../../Utils/Appconstants.dart';

class ReportServices{
  final Dio _dio = ApiService().dio;

  Future<List<GetManufacturerModel>?> fetchManufacturer() async {
    try {
      final response = await _dio.get(
        AppConstants.GETMANUFACTURER,
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
        print('Failed to fetch manufacturers: ${response.statusCode}');
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
