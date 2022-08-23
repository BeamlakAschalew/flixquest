// ignore_for_file: unnecessary_const, prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      useMaterial3: false,
      textTheme: isDarkTheme
          ? ThemeData.dark().textTheme.apply(
                fontFamily: 'Poppins',
              )
          : ThemeData.light().textTheme.apply(
                fontFamily: 'Poppins',
              ),
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF57C00),
          iconTheme: const IconThemeData(
            color: Color(0xFF000000),
          ),
          titleTextStyle: TextStyle(
              color: Colors.black, fontFamily: 'PoppinsSB', fontSize: 21)),
      primaryColor: const Color(0xFFF57C00),
      iconTheme: const IconThemeData(color: Color(0xFFF57C00)),
      backgroundColor:
          isDarkTheme ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
      colorScheme: ColorScheme(
        primary: const Color(0xFFF57C00),
        primaryContainer:
            !isDarkTheme ? const Color(0xFF8f4700) : const Color(0xFF202124),
        secondary:
            isDarkTheme ? const Color(0xFF202124) : const Color(0xFF8f4700),
        secondaryContainer: const Color(0xFF141517),
        surface: const Color(0xFFF57C00),
        background:
            isDarkTheme ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
        error: const Color(0xFFFF0000),
        onPrimary:
            isDarkTheme ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
        onSecondary:
            isDarkTheme ? const Color(0xFF141517) : const Color(0xFFF7F7F7),
        onSurface:
            isDarkTheme ? const Color(0xFF141517) : const Color(0xFFF7F7F7),
        onBackground: const Color(0xFFF57C00),
        onError: const Color(0xFFFFFFFF),
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
    );
  }
}
