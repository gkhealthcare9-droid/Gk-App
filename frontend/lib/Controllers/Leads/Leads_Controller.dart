import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../Models/Leads/Leads_Model.dart';
import '../../Services/leads/Leads_Services.dart';
import '../../Views/Widgets/CustomAlert.dart';
import '../../Views/Widgets/CustomBottomNav.dart';

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
        CustomAlert.error("No follow-up data found");
      }
    } catch (e) {
      CustomAlert.error("Failed to fetch follow-ups: $e");
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
        // Optional: CustomAlert.info('No leads found');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      CustomAlert.error(errorMessage.value);
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
        CustomAlert.success('Lead added successfully');
        await fetchLeads(); // Refresh the leads list after adding
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        errorMessage.value = 'Failed to add lead: ${response.statusCode}';
        CustomAlert.error(errorMessage.value);
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data['message'] ??
          'Server error: ${e.response?.statusCode}';
      CustomAlert.error(errorMessage.value);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      CustomAlert.error(errorMessage.value);
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
        CustomAlert.success('Lead updated successfully');
        await fetchLeads();
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
        return true;
      } else {
        print('❌ Failed to update lead: ${response.statusCode}');
        print('❌ Response: ${response.data}');
        CustomAlert.error('Failed: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('❌ DioException in controller');
      print('🔸 Status code: ${e.response?.statusCode}');
      print('🔸 Error data: ${e.response?.data}');
      print('🔸 Error message: ${e.message}');
      CustomAlert.error(e.response?.data['message'] ?? 'Server error occurred');
      return false;
    } catch (e) {
      print('❌ Unexpected error in controller: $e');
      CustomAlert.error('Something went wrong while updating lead');
      return false;
    }
  }

  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    try {
      final response = await _leadsServices.updateLeadStatus(leadId, newStatus);
      if (response.statusCode == 200) {
        CustomAlert.success('Status updated');
        fetchLeads();
      } else {
        CustomAlert.error('Failed to update status');
      }
    } catch (e) {
      CustomAlert.error('Exception: $e');
    }
  }
}
