import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../Utils/Appconstants.dart';
import 'AuthServices/SecureStorageService.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.BASE_URL,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    /* 
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('DIO_LOG: $obj'),
    ));
    */

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors like 401 Unauthorized
          if (e.response?.statusCode == 401) {
            // Logic to handle logout or token refresh
            print('Unauthorized! Token might be expired.');
          }
          return handler.next(e);
        },
      ),
    );
  }
}
