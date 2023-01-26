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
            fontSize: 21),
      ),
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
            : Color(0xFFF57C00),
      ),
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
                ? darkDynamicColor?.primaryContainer ?? Color(0xFF723600)
                : lightDynamicColor?.primaryContainer ?? Color(0xFFffdcc6)
            : isDarkTheme
                ? Color(0xFF723600)
                : Color(0xFFffdcc6),
        secondary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.secondary ?? Color(0xFFe4bfa8)
                : lightDynamicColor?.secondary ?? Color(0xFF755846)
            : isDarkTheme
                ? Color(0xFFe4bfa8)
                : Color(0xFF755846),
        secondaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.secondaryContainer ?? Color(0xFF5b4130)
                : lightDynamicColor?.secondaryContainer ?? Color(0xFFffdcc6)
            : isDarkTheme
                ? Color(0xFF5b4130)
                : Color(0xFFffdcc6),
        surface: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.surface ?? Color(0xFF201a17)
                : lightDynamicColor?.surface ?? Color(0xFFfffbff)
            : isDarkTheme
                ? Color(0xFF201a17)
                : Color(0xFFfffbff),
        background: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.background ?? Color(0xFF201a17)
                : lightDynamicColor?.background ?? Color(0xFFfffbff)
            : isDarkTheme
                ? Color(0xFF201a17)
                : Color(0xFFfffbff),
        error: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.error ?? Color(0xFFffb4ab)
                : lightDynamicColor?.error ?? Color(0xFFba1a1a)
            : isDarkTheme
                ? Color(0xFFffb4ab)
                : Color(0xFFba1a1a),
        onPrimary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onPrimary ?? Color(0xFF502400)
                : lightDynamicColor?.error ?? Color(0xFFffffff)
            : isDarkTheme
                ? Color(0xFF502400)
                : Color(0xFFffffff),
        onSecondary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSecondary ?? Color(0xFF422b1b)
                : lightDynamicColor?.onSecondary ?? Color(0xFFffffff)
            : isDarkTheme
                ? Color(0xFF502400)
                : Color(0xFFffffff),
        onSurface: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
                : lightDynamicColor?.onSurface ?? Color(0xFF201a17)
            : isDarkTheme
                ? Color(0xFFece0da)
                : Color(0xFF201a17),
        onBackground: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onBackground ?? Color(0xFFece0da)
                : lightDynamicColor?.onBackground ?? Color(0xFF201a17)
            : isDarkTheme
                ? Color(0xFFece0da)
                : Color(0xFF201a17),
        onError: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onError ?? Color(0xFF690005)
                : lightDynamicColor?.onError ?? Color(0xFFffffff)
            : isDarkTheme
                ? Color(0xFF690005)
                : Color(0xFFffffff),
        errorContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.errorContainer ?? Color(0xFF93000a)
                : lightDynamicColor?.errorContainer ?? Color(0xFFffdad6)
            : isDarkTheme
                ? Color(0xFF93000a)
                : Color(0xFFffdad6),
        onErrorContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onErrorContainer ?? Color(0xFFffdad6)
                : lightDynamicColor?.onErrorContainer ?? Color(0xFF410002)
            : isDarkTheme
                ? Color(0xFFffdad6)
                : Color(0xFF410002),
        onPrimaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onPrimaryContainer ?? Color(0xFFffdcc6)
                : lightDynamicColor?.onPrimaryContainer ?? Color(0xFF311400)
            : isDarkTheme
                ? Color(0xFFffdcc6)
                : Color(0xFF311400),
        onSecondaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSecondaryContainer ?? Color(0xFFffdcc6)
                : lightDynamicColor?.onSecondaryContainer ?? Color(0xFF2b1708)
            : isDarkTheme
                ? Color(0xFFffdcc6)
                : Color(0xFF2b1708),
        onSurfaceVariant: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSurfaceVariant ?? Color(0xFFd7c3b7)
                : lightDynamicColor?.onSurfaceVariant ?? Color(0xFF52443c)
            : isDarkTheme
                ? Color(0xFFd7c3b7)
                : Color(0xFF52443c),
        onTertiary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onTertiary ?? Color(0xFF31320a)
                : lightDynamicColor?.onTertiary ?? Color(0xFFffffff)
            : isDarkTheme
                ? Color(0xFF31320a)
                : Color(0xFFffffff),
        onTertiaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onTertiaryContainer ?? Color(0xFFe5e6ae)
                : lightDynamicColor?.onTertiaryContainer ?? Color(0xFF1c1d00)
            : isDarkTheme
                ? Color(0xFFe5e6ae)
                : Color(0xFF1c1d00),
        outline: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.outline ?? Color(0xFF9f8d83)
                : lightDynamicColor?.outline ?? Color(0xFF84746a)
            : isDarkTheme
                ? Color(0xFF9f8d83)
                : Color(0xFF84746a),
        tertiary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.tertiary ?? Color(0xFFc9ca94)
                : lightDynamicColor?.tertiary ?? Color(0xFF5f6134)
            : isDarkTheme
                ? Color(0xFFc9ca94)
                : Color(0xFF5f6134),
        tertiaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF48491f)
                : lightDynamicColor?.tertiaryContainer ?? Color(0xFFe5e6ae)
            : isDarkTheme
                ? Color(0xFF48491f)
                : Color(0xFFe5e6ae),
        surfaceVariant: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF52443c)
                : lightDynamicColor?.tertiaryContainer ?? Color(0xFFf4ded3)
            : isDarkTheme
                ? Color(0xFF52443c)
                : Color(0xFFf4ded3),
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      bannerTheme: MaterialBannerThemeData(),
      chipTheme: ChipThemeData(),
      snackBarTheme: SnackBarThemeData(),
      scaffoldBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
    );
  }
}
