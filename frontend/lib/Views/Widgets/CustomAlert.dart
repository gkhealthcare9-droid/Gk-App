import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlert {
  /// Displays a success snackbar.
  static void success(String message, {String title = "Success", BuildContext? context}) {
    _show(Colors.green, message, title, Icons.check_circle_outline);
  }

  /// Displays a success snackbar (named parameters version).
  static void showSuccess({BuildContext? context, required String message, String title = "Success"}) {
    _show(Colors.green, message, title, Icons.check_circle_outline);
  }

  /// Displays an error snackbar.
  static void error(String message, {String title = "Error", BuildContext? context}) {
    _show(Colors.red, message, title, Icons.error_outline);
  }

  /// Displays an error snackbar (named parameters version).
  static void showError({BuildContext? context, required String message, String title = "Error"}) {
    _show(Colors.red, message, title, Icons.error_outline);
  }

  /// Displays an info snackbar.
  static void info(String message, {String title = "Note", BuildContext? context}) {
    _show(Colors.blue, message, title, Icons.info_outline);
  }

  /// Displays a warning snackbar.
  static void warning(String message, {String title = "Warning", BuildContext? context}) {
    _show(Colors.orange, message, title, Icons.warning_amber_rounded);
  }

  /// Displays a loading snackbar (not recommended, but kept for compatibility).
  static void loading({String message = "Please wait...", BuildContext? context}) {
    _show(Colors.blueGrey, message, "Loading", Icons.hourglass_empty);
  }

  /// Internal method to show GetX snackbar.
  static void _show(Color color, String message, String title, IconData icon) {
    // If we're already closing a snackbar, don't trigger another one immediately
    // to avoid animation sync issues.
    if (Get.isSnackbarOpen) {
       return; 
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }
}
