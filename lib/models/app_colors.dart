import 'package:flutter/material.dart';

class AppColor {
  ColorScheme cs;
  int index;
  AppColor({required this.cs, required this.index});

  static ColorScheme colorGetter(Color color, bool isDark) {
    return ColorScheme.fromSeed(
        seedColor: color,
        brightness: isDark ? Brightness.dark : Brightness.light);
  }
}

class AppColorsList {
  List<AppColor> appColors(bool isDark) {
    List<Color> baseColors = [
      const Color(0xFF32a852), // Green
      const Color(0xFFff5722), // Deep Orange
      const Color(0xFF3f51b5), // Indigo
      const Color(0xFFe91e63), // Pink
      const Color(0xFF009688), // Teal
      const Color(0xFF673ab7), // Deep Purple
      const Color(0xFF795548), // Brown
      const Color(0xFF607d8b), // Blue Grey
      const Color(0xFFcddc39), // Lime
      const Color(0xFF4caf50), // Green
      const Color(0xFF9c27b0), // Purple
      const Color(0xFF00bcd4), // Cyan
      const Color(0xFF795548), // Brown
      const Color(0xFFf44336), // Red
      const Color(0xFF03a9f4), // Light Blue
    ];

    List<AppColor> appColors = [
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFFF57C00), isDark), index: -1),
      AppColor(cs: AppColor.colorGetter(baseColors[0], isDark), index: 1),
      AppColor(cs: AppColor.colorGetter(baseColors[1], isDark), index: 2),
      AppColor(cs: AppColor.colorGetter(baseColors[2], isDark), index: 3),
      AppColor(cs: AppColor.colorGetter(baseColors[3], isDark), index: 4),
      AppColor(cs: AppColor.colorGetter(baseColors[4], isDark), index: 5),
      AppColor(cs: AppColor.colorGetter(baseColors[5], isDark), index: 6),
      AppColor(cs: AppColor.colorGetter(baseColors[6], isDark), index: 7),
      AppColor(cs: AppColor.colorGetter(baseColors[7], isDark), index: 8),
      AppColor(cs: AppColor.colorGetter(baseColors[8], isDark), index: 9),
      AppColor(cs: AppColor.colorGetter(baseColors[9], isDark), index: 10),
      AppColor(cs: AppColor.colorGetter(baseColors[10], isDark), index: 11),
      AppColor(cs: AppColor.colorGetter(baseColors[11], isDark), index: 12),
      AppColor(cs: AppColor.colorGetter(baseColors[12], isDark), index: 13),
      AppColor(cs: AppColor.colorGetter(baseColors[13], isDark), index: 14),
      AppColor(cs: AppColor.colorGetter(baseColors[14], isDark), index: 15),
    ];
    return appColors;
  }
}

/*


List<AppColor> appColors = [
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFFF57C00), isDark), index: -1),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFF32a852), isDark), index: 0),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFF8e44ad), isDark), index: 1),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFF2c3e50), isDark), index: 2),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFFd35400), isDark), index: 3),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFF16a085), isDark), index: 4),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFFc0392b), isDark), index: 5),
      AppColor(
          cs: AppColor.colorGetter(const Color(0xFFc09b2b), isDark), index: 6),
    ];


*/
