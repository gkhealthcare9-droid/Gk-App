import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../Services/ApiService.dart';
import '../../Utils/Appconstants.dart';

class DashboardController extends GetxController {
  final Dio _dio = ApiService().dio;
  var stats = {}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading(true);
      final response = await _dio.get(AppConstants.DASHBOARD_STATS);

      if (response.statusCode == 200) {
        stats.value = response.data;
      } else {
        print('Error fetching stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stats: $e');
    } finally {
      isLoading(false);
    }
  }
}
