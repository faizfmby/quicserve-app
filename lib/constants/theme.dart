import 'package:flutter/material.dart';

class AppColors {
  // Theme Color
  static const Color teal = Color(0xFF1D9A9F);
  static const Color blue = Color(0xFF4059C8); //Opacity 30%
  static const Color yellow1 = Color(0xFFFFEE13);
  static const Color orange1 = Color.fromARGB(255, 255, 153, 0);
  static const Color yellow2 = Color(0xFFFFE713);
  static const Color orange2 = Color(0xFFF1AC20);
  static const Color red = Color(0xFFFF4B4B);

  // Gradient Color
  static const LinearGradient gradient1 = LinearGradient(colors: [
    AppColors.teal,
    AppColors.blue
  ], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient gradient2 = LinearGradient(colors: [
    AppColors.yellow2,
    AppColors.orange2
  ], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient gradient3 = LinearGradient(colors: [
    AppColors.red,
    Color.fromARGB(255, 146, 35, 35)
  ], begin: Alignment.topLeft, end: Alignment.bottomRight);

  // Background Color
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightgrey1 = Color(0xFFF3F3F3);
  static const Color lightgrey2 = Color(0xFFE3E3E3);
  static const Color lightgrey3 = Color(0xFFC3C3C3);
  static const Color lightgrey4 = Color(0xFFBBBBBB);
  static const Color lightgrey5 = Color(0xFFA4A4A4);
  static const Color black = Color(0xFF000000);
  static const Color darkgrey1 = Color(0xFF252525);
  static const Color darkgrey2 = Color(0xFF2D2D2D);
  static const Color darkgrey3 = Color(0xFF353535);
  static const Color darkgrey4 = Color(0xFF515151);
}

class CustomFont {
  // DaysOne
  static const TextStyle daysone10 = TextStyle(fontFamily: 'Days_One', fontSize: 10);
  static const TextStyle daysone14 = TextStyle(fontFamily: 'Days_One', fontSize: 14);
  static const TextStyle daysone24 = TextStyle(fontFamily: 'Days_One', fontSize: 24);
  static const TextStyle daysone32 = TextStyle(fontFamily: 'Days_One', fontSize: 36);
  static const TextStyle daysone72 = TextStyle(fontFamily: 'Days_One', fontSize: 72);

  // Calibri Regular
  static const TextStyle calibri16 = TextStyle(fontFamily: 'Calibri', fontSize: 16, color: AppColors.black);
  static const TextStyle calibri20 = TextStyle(fontFamily: 'Calibri', fontSize: 20, color: AppColors.black);
  static const TextStyle calibri22 = TextStyle(fontFamily: 'Calibri', fontSize: 22, color: AppColors.black);
  static const TextStyle calibri36 = TextStyle(fontFamily: 'Calibri', fontSize: 36, color: AppColors.black);
  static const TextStyle calibri26 = TextStyle(fontFamily: 'Calibri', fontSize: 26, color: AppColors.black);
  static const TextStyle calibri48 = TextStyle(fontFamily: 'Calibri', fontSize: 48, color: AppColors.black);

  // Calibri Bold
  static const TextStyle calibribold12 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 12);
  static const TextStyle calibribold18 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 18);
  static const TextStyle calibribold22 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 22);
  static const TextStyle calibribold24 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 24);
  static const TextStyle calibribold28 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 28);
  static const TextStyle calibribold36 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 36);
  static const TextStyle calibribold48 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 48);
  static const TextStyle calibribold80 = TextStyle(fontFamily: 'Calibri', fontWeight: FontWeight.w700, fontSize: 80);
}
