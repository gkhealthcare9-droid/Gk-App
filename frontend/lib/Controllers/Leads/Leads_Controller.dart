import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../Models/Leads/Leads_Model.dart';
import '../../Services/leads/Leads_Services.dart';

class LeadController extends GetxController {
  final LeadsServices _leadsServices = LeadsServices();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var leads = <LeadModel>[].obs; // Observable list of leads
  var followUps = <FollowUpModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeads(); // Fetch leads when the controller is initialized
  }

  Future<void> leadFollowups(String id) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetched = await _leadsServices.fetchFollowup(id);
      if (fetched != null) {
        followUps.assignAll(fetched); // Update the observable list
      } else {
        Get.snackbar("Error", "No follow-up data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch follow-ups: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addFollowUp({
    required String leadId,
    required DateTime datetime,
    required String notes,
  }) async {
    try {
      final success = await _leadsServices.createFollowUp(
        leadId: leadId,
        datetime: datetime,
        notes: notes,
      );
      return success;
    } catch (e) {
      print('Error adding follow-up: $e');
      return false;
    }
  }

  // }

  /// Fetches leads from the server and updates the leads list
  Future<void> fetchLeads() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedLeads = await _leadsServices.fetchLeads();
      if (fetchedLeads != null) {
        leads.assignAll(fetchedLeads); // Update the observable list
      }
      if (leads.isEmpty) {
        Get.snackbar('Info', 'No leads found');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds a new lead to the server
  Future<void> addLead(PostLead postLead) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _leadsServices.addLead(postLead);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Lead added successfully');
        await fetchLeads(); // Refresh the leads list after adding
      } else {
        errorMessage.value = 'Failed to add lead: ${response.statusCode}';
        Get.snackbar('Error', errorMessage.value);
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data['message'] ??
          'Server error: ${e.response?.statusCode}';
      Get.snackbar('Error', errorMessage.value);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  ///Edit leas controller
  Future<bool> updateLead(String leadId, PostLead updatedLead) async {
    print('🔁 Sending update for lead: $leadId');
    print('📦 Payload: ${updatedLead.toJson()}');

    try {
      final response = await _leadsServices.updateLead(leadId, updatedLead);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Lead updated successfully');
        Get.snackbar('Success', 'Lead updated successfully');
        await fetchLeads();
        return true;
      } else {
        print('❌ Failed to update lead: ${response.statusCode}');
        print('❌ Response: ${response.data}');
        Get.snackbar('Error', 'Failed: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('❌ DioException in controller');
      print('🔸 Status code: ${e.response?.statusCode}');
      print('🔸 Error data: ${e.response?.data}');
      print('🔸 Error message: ${e.message}');
      Get.snackbar('Error', e.response?.data['message'] ?? 'Server error occurred');
      return false;
    } catch (e) {
      print('❌ Unexpected error in controller: $e');
      Get.snackbar('Error', 'Something went wrong while updating lead');
      return false;
    }
  }


  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    try {
      final response = await _leadsServices.updateLeadStatus(leadId, newStatus);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Status updated');
        fetchLeads();
      } else {
        Get.snackbar('Error', 'Failed to update status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    }
  }
}
