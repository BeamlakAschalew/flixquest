// ignore_for_file: unnecessary_const, prefer_const_constructors
import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(
      {required bool isDarkTheme,
      required bool isM3Enabled,
      required ColorScheme? lightDynamicColor,
      required ColorScheme? darkDynamicColor,
      required BuildContext context}) {
    return ThemeData(
      useMaterial3: false,
      textTheme: isDarkTheme
          ? ThemeData.dark().textTheme.apply(
                fontFamily: 'Poppins',
              )
          : ThemeData.light().textTheme.apply(
                fontFamily: 'Poppins',
              ),
      appBarTheme: AppBarTheme(
          backgroundColor: isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.surface ?? Color(0xFFF57C00)
                  : lightDynamicColor?.surface ?? Color(0xFFF57C00)
              : Color(0xFFF57C00),
          iconTheme: IconThemeData(
            color: isM3Enabled
                ? isDarkTheme
                    ? darkDynamicColor?.onSurface ?? Colors.black
                    : lightDynamicColor?.onSurface ?? Colors.black
                : Colors.black,
          ),
          titleTextStyle: TextStyle(
              color: isM3Enabled
                  ? isDarkTheme
                      ? darkDynamicColor?.onSurface ?? Colors.black
                      : lightDynamicColor?.onSurface ?? Colors.black
                  : Colors.black,
              fontFamily: 'PoppinsSB',
              fontSize: 21)),
      primaryColor: isM3Enabled
          ? isDarkTheme
              ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
              : lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : const Color(0xFFF57C00),
      iconTheme: IconThemeData(
          color: isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.surface ?? Color(0xFFF57C00)
                  : lightDynamicColor?.surface ?? Color(0xFFF57C00)
              : Color(0xFFF57C00)),
      backgroundColor: isM3Enabled
          ? isDarkTheme
              ? darkDynamicColor?.background ?? Colors.black
              : lightDynamicColor?.background ?? Colors.white
          : isDarkTheme
              ? Colors.black
              : Colors.white,
      colorScheme: ColorScheme(
        primary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
                : lightDynamicColor?.primary ?? Color(0xFFF57C00)
            : const Color(0xFFF57C00),
        primaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primaryContainer ?? Colors.black
                : lightDynamicColor?.primaryContainer ?? Colors.white
            : isDarkTheme
                ? Colors.black
                : Colors.white,
        // !isDarkTheme ? const Color(0xFF8f4700) : const Color(0xFF202124),
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
