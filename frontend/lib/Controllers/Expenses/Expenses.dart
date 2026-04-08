import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/Expenses/expenses_model.dart';
import 'package:sales_grow/Services/Expenses/expenses_services.dart';

class ExpensesController extends GetxController {
  var isLoading = false.obs;
  var wallet = ExpenseModel(
    balance: 0.0,
    createdAt: DateTime.now(),
    id: '',
    transactions: [],
    updatedAt: DateTime.now(),
    user: '',
  ).obs;
var transcations = <TransactionModel>[].obs;
var expensescategory = <ExpensesCategoryModel>[].obs;
  final ExpensesServices _expensesServices = ExpensesServices();

  Future<void> fetchWallet() async {

    if (isLoading.value) return;
    print("Debig 1");
    isLoading.value = true;
    print("Debig 2");

    try {
      print("Debig 3");

      ExpenseModel? fetchedWallet = await _expensesServices.fetchWallet();
      print("Debig 4");

      if (fetchedWallet != null) {
        print("Debig 5");

        wallet.value = fetchedWallet; // ✅ Assign to Rx value
        print("Debig 6");

      } else {
        Get.snackbar('Error', 'No wallet data found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchTranscations() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetched = await _expensesServices.fetchTranscations();
      if (fetched != null) {
        transcations.assignAll(fetched); // ✅ This now works
      } else {
        Get.snackbar("Error", "No category data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchexpensesCategory() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final fetched = await _expensesServices.fetchexpensescatrgory();
      if (fetched != null) {
        expensescategory.assignAll(fetched); // ✅ This now works
      } else {
        Get.snackbar("Error", "No category data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }
  /// ✅ Add new expense with image
  Future<void> addExpense({
    required String description,
    required double amount,
    String? category,
    Uint8List? imageBytes,
    String? fileName,
    io.File? billImage, // Keep for backward compatibility or mobile-specific logic
  }) async {
    isLoading.value = true;

    try {
      final success = await _expensesServices.addExpense(
        description: description,
        amount: amount,
        category: category,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      if (success) {
        Get.snackbar('Success', 'Expense added successfully');
        await fetchWallet(); // 🔁 Refresh wallet
      } else {
        Get.snackbar('Error', 'Failed to add expense');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
