import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Leads/Leads_Model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/AppConstants.dart';

class LeadsServices {
  final Dio _dio = Dio();

  // Future<List<FollowUpModel>?> fetchFollowup(String leadId) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('authToken');
  //     if (token == null) throw Exception('Token not found');
  //
  //     _dio.options.headers['Authorization'] = 'Bearer $token';
  //     final response = await _dio.get('${AppConstants.BASE_URL}/api/v1/lead/followup/lead/$leadId');
  //
  //
  //     if (response.statusCode == 200 && response.data is List) {
  //       print(response.data);
  //       return (response.data as List)
  //           .map((item) => FollowUpModel.fromJson(item))
  //           .toList();
  //     } else {
  //       print('Failed to fetch categories: ${response.statusCode}');
  //       return null;
  //     }
  //   } on DioException catch (e) {
  //     print('Dio error: ${e.response?.data}');
  //     return null;
  //   } catch (e) {
  //     print('Unexpected error: $e');
  //     return null;
  //   }
  // }
  Future<List<FollowUpModel>?> fetchFollowup(String leadId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}/api/v1/lead/followup/lead/$leadId',
      );

      print(
        'Fetch Follow-Up Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>() // Filter out non-Map items
            .map((item) => FollowUpModel.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch follow-ups: ${response.statusCode}');
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

  Future<bool> createFollowUp({
    required String leadId,
    required DateTime datetime,
    required String notes,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return false;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        '${AppConstants.BASE_URL}/api/v1/lead/followup/add',
        data: {
          'lead': leadId,
          'datetime': datetime.toIso8601String(),
          'notes': notes,
        },
      );

      // Log the response for debugging
      print(
        'Create Follow-Up Response: ${response.statusCode} - ${response.data}',
      );

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If the response is a string, log it and return true
        if (response.data is String) {
          print('Response is a string: ${response.data}');
          return true;
        }
        // If the response is a JSON object, you can process it further if needed
        return true;
      } else {
        print('Failed to create follow-up: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('Dio error in createFollowUp: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected error in createFollowUp: $e');
      return false;
    }
  }

  Future<Response> addLead(PostLead postLead) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('Session expired, please login again.');

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        '${AppConstants.BASE_URL}/api/v1/lead/add',
        data: postLead.toJson(),
      );

      return response;
    } on DioException catch (e) {
      print('Error during addLead: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error during addLead: $e');
      rethrow;
    }
  }

  Future<List<LeadModel>?> fetchLeads() async {
    try {
      // Retrieve the authentication token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      print('Token: $token'); // Debugging
      if (token == null) return null;

      // Set Authorization header
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Make the API request
      final response = await _dio.get('${AppConstants.BASE_URL}/api/v1/lead');

      // Log response details for debugging
      print('Fetch Leads Status: ${response.statusCode}');
      print('Fetch Leads Response: ${response.data}');

      // Check if response data is a list
      if (response.statusCode == 200 && response.data is List) {
        // Map the JSON list to a list of LeadModel objects
        return (response.data as List)
            .map((json) => LeadModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Unexpected response format or status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Log error details
      print('Dio Error in fetchLeads: ${e.response?.statusCode}');
      print('Dio Error Data: ${e.response?.data}');
      print('Dio Error Message: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch leads');
    } catch (e) {
      // Log unexpected errors
      print('Unexpected error in fetchLeads: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  ///edit lead service
  Future<Response> updateLead(String leadId, PostLead updatedLead) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        '${AppConstants.BASE_URL}/api/v1/lead/$leadId', //
        data: updatedLead.toJson(),
      );

      print('✅ Lead update success: ${response.statusCode} - ${response.data}');
      return response;
    } on DioException catch (e) {
      print('❌ DioException occurred while updating lead');
      print('🔸 Status code: ${e.response?.statusCode}');
      print('🔸 Error data: ${e.response?.data}');
      print('🔸 Error message: ${e.message}');
      print('🔸 Request: ${e.requestOptions.path}');
      print('🔸 Method: ${e.requestOptions.method}');
      print('🔸 Headers: ${e.requestOptions.headers}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error in updateLead service: $e');
      rethrow;
    }
  }

  Future<Response> updateLeadStatus(String leadId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    return dio.put(
      '${AppConstants.BASE_URL}/api/v1/lead/status/$leadId/',
      data: {'status': status},
    );
  }
}
