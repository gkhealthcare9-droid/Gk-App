import 'package:get/get.dart';
import 'package:dio/dio.dart'as dio;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sales_grow/Models/Auth/User_Model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/AuthServices/Auth_Services.dart';
import '../../Services/AuthServices/SecureStorageService.dart';
import '../../Views/Widgets/CustomBottomNav.dart';
import '../../Views/AuthScreens/LoginScreen.dart';
import '../../Views/Widgets/CustomAlert.dart';

class LoginController extends GetxController {
  var isLoading = false.obs; // Observable for loading state
  var profile = UserModel().obs;
  final LoginService _loginService = LoginService();

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      // 1) Call your login API
      dio.Response? response = await _loginService.login(email, password);

      isLoading.value = false;
      if (response != null && response.statusCode == 200) {
        // 2) Extract the token string from the response
        final String token = response.data['token'] as String;

        // 3) Decode JWT payload using jwt_decoder
        final Map<String, dynamic> payloadMap = JwtDecoder.decode(token);

        // 4) Extract userType from payload
        final String? userType = payloadMap['userType'] as String?;

        if (userType == null) {
          CustomAlert.error('User verification failed. Please contact administrator.');
          return;
        }

        // 6) Save token, userType and name in Secure Storage and SharedPreferences
        await SecureStorageService.saveToken(token);
        await SecureStorageService.saveUserType(userType);
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userType', userType);
        
        try {
          // Fetch the profile from the database
          final UserModel profileData = await _loginService.fetchProfile(token);
          if (profileData.name != null) {
            await SecureStorageService.saveUserName(profileData.name!);
            await prefs.setString('userName', profileData.name!);
          }
        } catch (e) {
          print('Error fetching profile during login: $e');
        }

        // 7) Show a success message and navigate
        CustomAlert.success('Login Successful');
        
        await Future.delayed(const Duration(milliseconds: 1500));
        isLoading.value = false; // Reset loading BEFORE navigation
        Get.offAll(() => const CustomBottomNavBar());
      }
      else if (response?.statusCode == 400 || response?.statusCode == 401 || response?.statusCode == 404) {
        isLoading.value = false;
        CustomAlert.error(response?.data?['message'] ?? response?.data?['msg'] ?? 'Invalid credentials');
      }
      else {
        isLoading.value = false;
        CustomAlert.error(response == null ? 'Cannot connect to server. Please check your internet.' : 'Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      isLoading.value = false;
      CustomAlert.error('Technical error: $e');
    }
  }
}

class SignupController extends GetxController {
  var isLoading = false.obs;
  final LoginService _authService = LoginService();

  Future<bool> signup(String name, String email, String phone, String password, String positionId, {bool shouldNavigate = true}) async {
    isLoading.value = true;
    try {
      dio.Response? response = await _authService.signup(name, email, phone, password, positionId);
      isLoading.value = false;

      if (response != null && (response.statusCode == 201 || response.statusCode == 200)) {
        CustomAlert.success('Registration successful!');
        if (shouldNavigate) {
          Get.off(() => const LoginScreen());
        }
        return true;
      } else {
        CustomAlert.error(response?.data['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      CustomAlert.error('Something went wrong during registration');
      return false;
    }
  }
}