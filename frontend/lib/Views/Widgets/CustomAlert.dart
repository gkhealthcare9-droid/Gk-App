import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/Colors.dart';

class CustomAlert {
  static void success(String message, {String title = "Success"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(String message, {String title = "Error"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  static void info(String message, {String title = "Note"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.primaryBlue,
      icon: Icons.info_outline,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Definitive Flutter-compatible scheduling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Automatic self-dismissal after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isDialogOpen!) {
          Get.back();
        }
      });

      if (!Get.isDialogOpen!) {
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: backgroundColor, size: 45),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey.withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false, // User doesn't need to tap outside, it auto-dismisses
          transitionCurve: Curves.easeOutBack,
        );
      }
    });
  }
}
