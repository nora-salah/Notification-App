import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor1 = Color.fromARGB(255, 50, 199, 99);
  static const Color primaryColor2 = Color.fromARGB(255, 56, 118, 253);
  static const Color secondaryColor = Color.fromARGB(255, 98, 142, 255);

  static const Color secondaryColor2 = Color(0xFF9DCEFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black2 = Color(0xFF1D1617);
  static const Color gray = Color(0xFF7B6F72);
  static const Color lightGray = Color(0xFFF7F8F8);
  static const Color midGray = Color(0xFFADA4A5);
  static List<Color> get primaryColors => [primaryColor1, primaryColor2];
  static List<Color> get secondaryColors => [secondaryColor, secondaryColor2];
}
