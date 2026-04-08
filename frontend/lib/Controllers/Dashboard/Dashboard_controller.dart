import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';

class DashboardController extends GetxController {
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
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.DASHBOARD_STATS),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        stats.value = json.decode(response.body);
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
