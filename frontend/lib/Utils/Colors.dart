import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette: Professional Light Blue and Soft White
  static const Color primaryBlue = Color(0xFF64B5F6); // Soft Light Blue
  static const Color accentBlue = Color(0xFF2196F3); // More active blue
  static const Color paleBlue = Color(0xFFE3F2FD); // Very light blue for subtle backgrounds
  
  // High-End Neutral Palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhiteOriginal = Color(0xFFF9FAFB);
  static const Color offWhite = Color(0xFFFAFBFF); // Slightly blue-ish white
  static const Color black = Color(0xFF212121); // Clean dark grey
  static const Color grey = Color(0xFF9E9E9E);
  static const Color bgGrey = Color(0xFFF4F7FB); // Modern background color
  
  // Functional Colors
  static const Color softGrey = Color(0xFFEEEEEE);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // Legacy mappings for consistency (Redirecting deep blues to light blues)
  static const Color blue = primaryBlue;
  static const Color secondaryBlue = accentBlue;
  static const Color yellow = accentBlue; 
  static const Color lightyellow = paleBlue;
}