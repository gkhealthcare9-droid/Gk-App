import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_grow/Models/Expenses/expenses_model.dart';
import '../ApiService.dart';
import '../../Utils/Appconstants.dart';

class ExpensesServices {
  final Dio _dio = ApiService().dio;

  Future<ExpenseModel?> fetchWallet() async {
    try {
      final response = await _dio.get(AppConstants.GETWALLET);

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching wallet: $e');
      return null;
    }
  }

  Future<List<TransactionModel>?> fetchTranscations() async {
    try {
      final response = await _dio.get(AppConstants.TRANSCATIONS);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => TransactionModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching transactions: $e');
      return null;
    }
  }

  Future<List<ExpensesCategoryModel>?> fetchexpensescatrgory() async {
    try {
      final response = await _dio.get(AppConstants.EXPENSESCATEGORY);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => ExpensesCategoryModel.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching expenses category: $e');
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
        AppConstants.FUNDSWITHDRAW,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }
}
