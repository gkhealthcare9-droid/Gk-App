import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';

class LocationController extends GetxController {
  var states = [].obs;
  var cities = [].obs;
  var filteredCities = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStates();
  }

  Future<void> fetchStates() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/states'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        states.value = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching states: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/cities/by-state/$stateId'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        filteredCities.value = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching filtered cities: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addCity(String name, int stateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/cities/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({
          'name': name,
          'stateId': stateId,
        }),
      );

      if (response.statusCode == 201) {
        // Refresh the cities list for this state
        await fetchCitiesByState(stateId);
      }
    } catch (e) {
      print('Error adding city: $e');
    }
  }

  Future<void> fetchCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/cities'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (response.statusCode == 200) {
        cities.value = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }
}
