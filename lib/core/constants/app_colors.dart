import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2C5F2D);
  static const secondary = Color(0xFF97BC62);
  static const accent = Color(0xFFC9A961);
  static const background = Color(0xFFF9F7F2);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const error = Color(0xFFD32F2F);
  
  static const loyaltyGradient = LinearGradient(
    colors: [primary, Color(0xFF1A4A1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}