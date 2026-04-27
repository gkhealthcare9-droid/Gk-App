import 'package:get/get.dart';
import 'package:sales_grow/Services/Geography/Location_services.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  
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
      final fetchedStates = await _locationService.fetchStates();
      if (fetchedStates != null) {
        states.value = fetchedStates.map((e) => e.toJson()).toList();
      }
    } catch (e) {
      CustomAlert.error('Error fetching states: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      isLoading(true);
      final fetchedCities = await _locationService.fetchCitiesByState(stateId);
      if (fetchedCities != null) {
        filteredCities.value = fetchedCities.map((e) => e.toJson()).toList();
      }
    } catch (e) {
      CustomAlert.error('Error fetching cities: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addState(String name) async {
    try {
      final response = await _locationService.addState(name);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchStates();
      } else {
        CustomAlert.error('Failed to add state');
      }
    } catch (e) {
      CustomAlert.error('Error adding state: $e');
    }
  }

  Future<void> updateState(int id, String name) async {
    try {
      final response = await _locationService.updateState(id, name);
      if (response.statusCode == 200) {
        await fetchStates();
      } else {
        CustomAlert.error('Failed to update state');
      }
    } catch (e) {
      CustomAlert.error('Error updating state: $e');
    }
  }

  Future<void> deleteState(int id) async {
    try {
      final response = await _locationService.deleteState(id);
      if (response.statusCode == 200) {
        await fetchStates();
      } else {
        CustomAlert.error('Failed to delete state');
      }
    } catch (e) {
      CustomAlert.error('Error deleting state: $e');
    }
  }

  Future<void> addCity(String name, int stateId) async {
    try {
      final response = await _locationService.addCity(name, stateId);

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchCitiesByState(stateId);
      } else {
        CustomAlert.error('Failed to add city');
      }
    } catch (e) {
      CustomAlert.error('Error adding city: $e');
    }
  }

  Future<void> updateCity(int id, String name, int stateId) async {
    try {
      final response = await _locationService.updateCity(id, name, stateId);
      if (response.statusCode == 200) {
        await fetchCitiesByState(stateId);
      } else {
        CustomAlert.error('Failed to update city');
      }
    } catch (e) {
      CustomAlert.error('Error updating city: $e');
    }
  }

  Future<void> deleteCity(int id, int stateId) async {
    try {
      final response = await _locationService.deleteCity(id);
      if (response.statusCode == 200) {
        await fetchCitiesByState(stateId);
      } else {
        CustomAlert.error('Failed to delete city');
      }
    } catch (e) {
      CustomAlert.error('Error deleting city: $e');
    }
  }

  Future<void> fetchCities() async {
    try {
      final fetchedCities = await _locationService.fetchCities();
      if (fetchedCities != null) {
        cities.value = fetchedCities.map((e) => e.toJson()).toList();
      }
    } catch (e) {
      CustomAlert.error('Error fetching cities: $e');
    }
  }
}
