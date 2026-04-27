// frontend/lib/Services/Geography/Location_services.dart

import 'package:dio/dio.dart';
import '../../Models/Geography/GeographyModel.dart';
import '../../Utils/Appconstants.dart';
import '../ApiService.dart';

class LocationService {
  final Dio _dio = ApiService().dio;

  // ========== States ==========

  Future<List<StateModel>?> fetchStates() async {
    try {
      final response = await _dio.get(
        '${AppConstants.LOCATION}/states',
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => StateModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('LocationService fetchStates error: $e');
    }
    return null;
  }

  // ========== Cities ==========

  Future<List<CityModel>?> fetchCities() async {
    try {
      final response = await _dio.get(
        '${AppConstants.LOCATION}/cities',
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => CityModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('LocationService fetchCities error: $e');
    }
    return null;
  }

  Future<List<CityModel>?> fetchCitiesByState(int stateId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.LOCATION}/cities/by-state/$stateId',
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => CityModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('LocationService fetchCitiesByState error: $e');
    }
    return null;
  }

  Future<Response> addState(String name) async {
    return await _dio.post(
      '${AppConstants.LOCATION}/states/add',
      data: {'name': name},
    );
  }

  Future<Response> updateState(int id, String name) async {
    return await _dio.put(
      '${AppConstants.LOCATION}/states/$id',
      data: {'name': name},
    );
  }

  Future<Response> deleteState(int id) async {
    return await _dio.delete(
      '${AppConstants.LOCATION}/states/$id',
    );
  }

  Future<Response> addCity(String name, int stateId) async {
    return await _dio.post(
      '${AppConstants.LOCATION}/cities/add',
      data: {'name': name, 'stateId': stateId},
    );
  }

  Future<Response> updateCity(int id, String name, int stateId) async {
    return await _dio.put(
      '${AppConstants.LOCATION}/cities/$id',
      data: {'name': name, 'stateId': stateId},
    );
  }

  Future<Response> deleteCity(int id) async {
    return await _dio.delete(
      '${AppConstants.LOCATION}/cities/$id',
    );
  }
}
