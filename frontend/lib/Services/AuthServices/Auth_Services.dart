import 'package:dio/dio.dart';
import 'package:sales_grow/Models/Auth/UsersModel.dart';
import '../ApiService.dart';
import '../../Models/Auth/User_Model.dart';
import '../../Utils/Appconstants.dart';

class LoginService {
  final Dio _dio = ApiService().dio;

  Future<Response?> login(String email, String password) async {
    try {
      Response response = await _dio.post(
        AppConstants.LOGIN,
        data: {
          "email": email,
          "password": password
        },
      );
      return response;
    } on DioException catch (e) {
      print('Error during login: ${e.response?.data}');
      return e.response;
    } catch (e) {
      print('Unexpected error during login: $e');
      return null;
    }
  }

  Future<Response?> signup(String name, String email, String phone, String password, String positionId) async {
    try {
      Response response = await _dio.post(
        AppConstants.SIGNUP,
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "positionId": positionId,
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
      final response = await _dio.get(
        '${AppConstants.Employee}/by-customer/$id',
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
      final response = await _dio.get(
        AppConstants.GETUSERS,
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => UsersModels.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch users: ${response.statusCode}');
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

  Future<UserModel> fetchProfile(String token) async {
    try {
      final response = await _dio.get(
        AppConstants.USERPROFILE,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
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
