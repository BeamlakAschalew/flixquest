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
    // Curated color palette with modern, vibrant colors
    final List<Color> baseColors = [
      const Color(0xFF6366F1), // Indigo - Modern purple-blue
      const Color(0xFFEC4899), // Pink - Vibrant hot pink
      const Color(0xFF10B981), // Emerald - Fresh green
      const Color(0xFFF59E0B), // Amber - Warm gold
      const Color(0xFF8B5CF6), // Violet - Rich purple
      const Color(0xFF06B6D4), // Cyan - Bright cyan
      const Color(0xFFEF4444), // Red - Bold red
      const Color(0xFF14B8A6), // Teal - Ocean teal
      const Color(0xFFF97316), // Orange - Energetic orange
      const Color(0xFFA855F7), // Purple - Deep purple
      const Color(0xFF3B82F6), // Blue - Sky blue
      const Color(0xFF84CC16), // Lime - Fresh lime
      const Color(0xFFDB2777), // Rose - Deep pink
      const Color(0xFF0EA5E9), // Light Blue - Bright blue
      const Color(0xFF22C55E), // Green - Grass green
      const Color(0xFFEAB308), // Yellow - Sunshine yellow
      const Color(0xFF64748B), // Slate - Cool grey-blue
      const Color(0xFFD946EF), // Fuchsia - Electric magenta
      const Color(0xFF059669), // Green Teal - Deep emerald
      const Color(0xFFF43F5E), // Coral Red - Warm red
    ];

    // Default color (index -1) + dynamically generated color list
    return [
      AppColor(
        cs: AppColor.colorGetter(const Color(0xFFF97316), isDark),
        index: -1,
      ),
      ...List.generate(
        baseColors.length,
        (index) => AppColor(
          cs: AppColor.colorGetter(baseColors[index], isDark),
          index: index + 1,
        ),
      ),
    ];
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
