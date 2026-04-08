import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/report/GenerateReports/Installation_Report_Model.dart';
import '../../../Utils/Appconstants.dart';

class InstallationReportService {
  final Dio _dio = Dio();

  InstallationReportService() {
    _dio.options.baseUrl = AppConstants.BASE_URL;
  }

  Future<Response> addInstallation(PostInstallationReport report) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null || token.isEmpty) throw Exception('Session expired, please login again.');

      // Add auth token to headers
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Prepare form data
      FormData formData = FormData.fromMap(await report.toMultipartMap());

      // Send POST request
      final response = await _dio.post(
        AppConstants.INSTALLATIONREPORT,
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      print('❌ Dio error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  Future<List<FetchInstallationReport >?> fetchinstallationreport() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.INSTALLATIONREPORT}',
      );

      if (response.statusCode == 200) {
        print('/////////////////INstallation Report ${response.data}');
        if (response.data is List) {
          return (response.data as List)
              .map((item) => FetchInstallationReport.fromJson(item))
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
