
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_grow/Models/Expenses/expenses_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/Appconstants.dart';

class ExpensesServices {
  final Dio _dio = Dio();

// expenses_services.dart
  Future<ExpenseModel?> fetchWallet() async {
    try {
      print("Service: fetchWallet ▶️ 1. Preparing SharedPreferences");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      print("Service: fetchWallet ▶️ 2. Retrieved token: $token");

      if (token == null) {
        print("Service: fetchWallet ▶️ Silent failure (No token)");
        return null;
      }

      final url = '${AppConstants.BASE_URL}${AppConstants.GETWALLET}';
      print("Service: fetchWallet ▶️ 3. URL = $url");
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // add a timeout so we know if it's hanging
      final response = await _dio
          .get(url)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('HTTP GET timed out');
      });

      print("Service: fetchWallet ▶️ 4. Got HTTP ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Service: fetchWallet ▶️ 5. Data = ${response.data}");
        if (response.data is Map<String, dynamic>) {
          return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
        } else {
          print("Service: fetchWallet ▶️ ❌ Unexpected data type: ${response.data.runtimeType}");
          return null;
        }
      } else {
        print("Service: fetchWallet ▶️ ❌ Non-200 status: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      print('Service: fetchWallet ▶️ DioException: ${e.message} / status ${e.response?.statusCode}');
      return null;
    } catch (e) {
      print('Service: fetchWallet ▶️ Unexpected error: $e');
      return null;
    }
  }
  Future<List<TransactionModel>?> fetchTranscations() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.TRANSCATIONS}',
      );

      if (response.statusCode == 200) {
        print(response.data);
        if (response.data is List) {
          return (response.data as List)
              .map((item) => TransactionModel.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${response.data}');
          return null;
        }
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
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


  Future<List<ExpensesCategoryModel>?> fetchexpensescatrgory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConstants.BASE_URL}${AppConstants.EXPENSESCATEGORY}',
      );

      if (response.statusCode == 200) {
        print(response.data);
        if (response.data is List) {
          return (response.data as List)
              .map((item) => ExpensesCategoryModel.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${response.data}');
          return null;
        }
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
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

  Future<bool> addExpense({
    required String description,
    required double amount,
    String? category,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return false;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Build a single FormData object. Only attach "bill" if bits != null.
      Map<String, dynamic> dataMap = {
        'description': description,
        'amount': amount,
        'category': category,
      };

      if (imageBytes != null) {
        dataMap['bill'] = MultipartFile.fromBytes(
          imageBytes,
          filename: fileName ?? 'bill.jpg',
        );
      }

      FormData formData = FormData.fromMap(dataMap);

      final response = await _dio.post(
        '${AppConstants.BASE_URL}${AppConstants.FUNDSWITHDRAW}',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add expense: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }


}