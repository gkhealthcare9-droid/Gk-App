import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Auth/UsersModel.dart';
import 'package:sales_grow/Services/AuthServices/Auth_Services.dart';
import 'package:sales_grow/Services/AuthServices/SecureStorageService.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Auth/User_Model.dart';
import '../../Utils/AppConstants.dart';
import '../../Services/ApiService.dart';

class ProfileController extends GetxController {
  final Dio _dio = ApiService().dio;
  var isLoading = false.obs;
  var userProfile = UserModel().obs;
  var users = <UsersModels>[].obs;
  final LoginService _loginService = LoginService();

  /// Fetches the user profile from the server.
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _dio.get(AppConstants.USERPROFILE);

      if (response.statusCode == 200 && response.data != null) {
        userProfile.value = UserModel.fromJson(response.data);
      } else {
        CustomAlert.error('Failed to fetch profile');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map ? e.response?.data['msg']?.toString() ?? 'Failed to fetch profile' : 'Failed to fetch profile';
      CustomAlert.error(errorMsg);
    } catch (e) {
      CustomAlert.error('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates the user profile on the server.
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (userProfile.value.id == null) {
      CustomAlert.error('User identity not found. Please re-login.');
      return;
    }
    
    isLoading.value = true;
    try {
      final updatedData = {
        'id': userProfile.value.id,
        'name': name,
        'email': email,
        'phone': phone,
      };

      final response = await _dio.put(
        AppConstants.USERPROFILE,
        data: updatedData,
      );

      if (response.statusCode == 200 && response.data != null) {
        userProfile.value = UserModel.fromJson(response.data);
        CustomAlert.success('Profile updated successfully');
        
        // Update cached name if it changed
        if (name != userProfile.value.name) {
          await SecureStorageService.saveUserName(name);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', name);
        }

        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      } else {
        CustomAlert.error('Failed to update profile');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map 
          ? (e.response?.data['msg'] ?? e.response?.data['message'] ?? 'Failed to update profile').toString() 
          : 'Failed to update profile';
      CustomAlert.error(errorMsg);
    } catch (e) {
      CustomAlert.error('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      List<UsersModels>? fetchedCustomers = await _loginService.fetchUsers();

      if (fetchedCustomers != null) {
        users.assignAll(fetchedCustomers); // Replace existing list
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
