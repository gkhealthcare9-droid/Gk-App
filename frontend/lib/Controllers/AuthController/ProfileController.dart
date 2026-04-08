import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Auth/UsersModel.dart';
import 'package:sales_grow/Services/AuthServices/Auth_Services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Auth/User_Model.dart';
import '../../Utils/AppConstants.dart';

class ProfileController extends GetxController {
  final Dio _dio = Dio();
  var isLoading = false.obs;
  var userProfile = UserModel().obs;
var users = <UsersModels>[].obs;
final LoginService _loginService = LoginService();
  /// Fetches the user profile from the server.
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('${AppConstants.BASE_URL}${AppConstants.USERPROFILE}');

      if (response.statusCode == 200 && response.data != null) {
        userProfile.value = UserModel.fromJson(response.data);
      } else {
        Get.snackbar('Error', 'Failed to fetch profile');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map ? e.response?.data['msg']?.toString() ?? 'Failed to fetch profile' : 'Failed to fetch profile';
      Get.snackbar('Error', errorMsg);
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
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
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final updatedData = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      final response = await _dio.put(
        '${AppConstants.BASE_URL}${AppConstants.USERPROFILE}',
        data: updatedData,
      );

      if (response.statusCode == 200 && response.data != null) {
        userProfile.value = UserModel.fromJson(response.data);
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map ? e.response?.data['msg']?.toString() ?? 'Failed to update profile' : 'Failed to update profile';
      Get.snackbar('Error', errorMsg);
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
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
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

}