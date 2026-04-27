import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../Services/AuthServices/SecureStorageService.dart';

import '../AuthScreens/LoginScreen.dart';
import '../Widgets/CustomBottomNav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  String _currentDateTime = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _navigateToNext();
  }

  void _updateDateTime() {
    _currentDateTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime = _formatDateTime(DateTime.now());
      });
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatTwoDigits(dateTime.day)}/${_formatTwoDigits(dateTime.month)}/${dateTime.year} '
        '${_formatTwoDigits(dateTime.hour)}:${_formatTwoDigits(dateTime.minute)}:${_formatTwoDigits(dateTime.second)}';
  }

  String _formatTwoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await SecureStorageService.getToken();

    if (token != null && token.isNotEmpty) {
      final isExpired = JwtDecoder.isExpired(token);
      if (!isExpired) {
        _timer.cancel();
        Get.offAll(() => CustomBottomNavBar());
        return;
      } else {
        await SecureStorageService.clearAll();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('authToken');
      }
    }

    _timer.cancel();
    Get.offAll(() => const LoginScreen());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              width: 200,
              height: 220,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}