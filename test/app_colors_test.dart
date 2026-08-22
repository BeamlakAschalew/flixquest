import 'package:flixquest/models/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom theme uses the selected color as its exact primary', () {
    const selectedColor = Color(0xFFFF0000);

    for (final isDark in [false, true]) {
      final customColor = AppColorsList()
          .appColors(isDark, customColor: selectedColor.toARGB32())
          .singleWhere((color) => color.index == AppColor.customIndex);

      expect(customColor.cs.primary, selectedColor);
      expect(customColor.cs.onPrimary, Colors.white);
    }
  });
}
