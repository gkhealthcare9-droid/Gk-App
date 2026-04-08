import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Auth/UsersModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Auth/User_Model.dart';
import '../../Utils/Appconstants.dart';

class LoginService {
  final Dio _dio = Dio();

  Future<Response?> login(String email, String password) async {
    try {
      // Make the API call
      Response response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.LOGIN}',
        data: {
          "email":email,
          "password":password
        },
      );

      // Return the response to the controller
      // print(response);
      return response;
    } on DioException catch (e) {
      // Handle Dio-specific exceptions
      print('Error during login: ${e.response?.data}');
      return e.response;
    } catch (e) {
      // Handle any other exceptions
      print('Unexpected error during login: $e');
      return null;
    }
  }

  Future<Response?> signup(String name, String email, String phone, String password) async {
    try {
      Response response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.SIGNUP}',
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "userType": "user"
        },
      );
      return response;
    } on DioException catch (e) {
      print('Error during signup: ${e.response?.data}');
      return e.response;
    } catch (e) {
      print('Unexpected error during signup: $e');
      return null;
    }
  }
  Future<Response?> fetchEmployees(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        print('Token not found, skipping fetchEmployees');
        return null;
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.Employee}/by-customer/$id',
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        print('Failed to fetch employees: ${response.statusCode}');
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
  Future<List<UsersModels>?> fetchUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.GETUSERS}',
      );
    print('///started');
      if (response.statusCode == 200 && response.data is List) {
        print(response.data);
        return (response.data as List)
            .map((item) => UsersModels.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print(e);
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  Future<UserModel> fetchProfile(String token) async {
    try {
      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.USERPROFILE}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Error fetching profile: ${e.response?.data}');
      throw Exception('Failed to fetch profile');
    }
  }


}