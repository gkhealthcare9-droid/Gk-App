import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Leads/Leads_Model.dart';
import '../ApiService.dart';
import '../../Utils/AppConstants.dart';

class LeadsServices {
  final Dio _dio = ApiService().dio;

  Future<List<FollowUpModel>?> fetchFollowup(String leadId) async {
    try {
      final response = await _dio.get(
        '/api/v1/lead/followup/lead/$leadId',
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => FollowUpModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching follow-ups: $e');
      return null;
    }
  }

  Future<bool> createFollowUp({
    required String leadId,
    required DateTime datetime,
    required String notes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/lead/followup/add',
        data: {
          'lead': leadId,
          'datetime': datetime.toIso8601String(),
          'notes': notes,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error in createFollowUp: $e');
      return false;
    }
  }

  Future<Response> addLead(PostLead postLead) async {
    try {
      final response = await _dio.post(
        '/api/v1/lead/add',
        data: postLead.toJson(),
      );
      return response;
    } catch (e) {
      print('Error adding lead: $e');
      rethrow;
    }
  }

  Future<List<LeadModel>?> fetchLeads() async {
    try {
      final response = await _dio.get(AppConstants.POSTLEADS);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => LeadModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching leads: $e');
      return null;
    }
  }

  Future<Response> updateLead(String leadId, PostLead updatedLead) async {
    try {
      final response = await _dio.put(
        '/api/v1/lead/$leadId',
        data: updatedLead.toJson(),
      );
      return response;
    } catch (e) {
      print('Error updating lead: $e');
      rethrow;
    }
  }

  Future<Response> updateLeadStatus(String leadId, String status) async {
    try {
      return await _dio.put(
        '/api/v1/lead/status/$leadId/',
        data: {'status': status},
      );
    } catch (e) {
      print('Error updating lead status: $e');
      rethrow;
    }
  }
}
