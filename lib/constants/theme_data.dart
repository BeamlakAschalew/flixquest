// ignore_for_file: unnecessary_const, prefer_const_constructors
import 'package:flutter/material.dart';

ThemeData darkThemeData(
  bool isM3Enabled,
  ColorScheme? darkDynamicColor,
) {
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? darkDynamicColor?.onPrimary ?? Colors.black
            : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.black
              : Colors.black,
          fontFamily: 'PoppinsSB',
          fontSize: 21),
    ),
    dialogTheme: DialogTheme(backgroundColor: Color(0xFF171717)),
    primaryColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : const Color(0xFFF57C00),
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
    ),
    bannerTheme: MaterialBannerThemeData(),
    chipTheme: ChipThemeData(),
    snackBarTheme: SnackBarThemeData(),
    scaffoldBackgroundColor: Color(0xFF161716),
    radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : Color(0xFFF57C00))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
              : Color(0xFFF57C00),
        ),
        foregroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Color(0xFFF57C00)
              : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isM3Enabled
                ? darkDynamicColor?.primary.withOpacity(0.1) ??
                    Color(0xFFF57C00).withOpacity(0.1)
                : Color(0xFFF57C00).withOpacity(0.1),
          ),
          maximumSize: MaterialStateProperty.all(const Size(200, 60)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
                        : Color(0xFFF57C00),
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Colors.black
          : Colors.black,
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
      selectionHandleColor: const Color(0xFFFFFFFF),
      selectionColor: Colors.white12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Poppins'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    indicatorColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : Color(0xFFF57C00),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : Color(0xFFF57C00),
      ),
      trackColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primaryContainer ?? Color(0xFF994d02)
            : Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : const Color(0xFFF57C00),
      primaryContainer: isM3Enabled
          ? darkDynamicColor?.primaryContainer ?? Color(0xFF723600)
          : Color(0xFF723600),
      secondary: isM3Enabled
          ? darkDynamicColor?.secondary ?? Color(0xFFe4bfa8)
          : Color(0xFFe4bfa8),
      secondaryContainer: isM3Enabled
          ? darkDynamicColor?.secondaryContainer ?? Color(0xFF5b4130)
          : Color(0xFF5b4130),
      surface: isM3Enabled
          ? darkDynamicColor?.surface ?? Color(0xFF201a17)
          : Color(0xFF201a17),
      background: isM3Enabled
          ? darkDynamicColor?.background ?? Color(0xFF201a17)
          : Color(0xFF201a17),
      error: isM3Enabled
          ? darkDynamicColor?.error ?? Color(0xFFffb4ab)
          : Color(0xFFffb4ab),
      onPrimary: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Color(0xFF502400)
          : Color(0xFF502400),
      onSecondary: isM3Enabled
          ? darkDynamicColor?.onSecondary ?? Color(0xFF422b1b)
          : Color(0xFF502400),
      onSurface: isM3Enabled
          ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
          : Color(0xFFece0da),
      onBackground: isM3Enabled
          ? darkDynamicColor?.onBackground ?? Color(0xFFece0da)
          : Color(0xFFece0da),
      onError: isM3Enabled
          ? darkDynamicColor?.onError ?? Color(0xFF690005)
          : Color(0xFF690005),
      errorContainer: isM3Enabled
          ? darkDynamicColor?.errorContainer ?? Color(0xFF93000a)
          : Color(0xFF93000a),
      onErrorContainer: isM3Enabled
          ? darkDynamicColor?.onErrorContainer ?? Color(0xFFffdad6)
          : Color(0xFFffdad6),
      onPrimaryContainer: isM3Enabled
          ? darkDynamicColor?.onPrimaryContainer ?? Color(0xFFffdcc6)
          : Color(0xFFffdcc6),
      onSecondaryContainer: isM3Enabled
          ? darkDynamicColor?.onSecondaryContainer ?? Color(0xFFffdcc6)
          : Color(0xFFffdcc6),
      onSurfaceVariant: isM3Enabled
          ? darkDynamicColor?.onSurfaceVariant ?? Color(0xFFd7c3b7)
          : Color(0xFFd7c3b7),
      onTertiary: isM3Enabled
          ? darkDynamicColor?.onTertiary ?? Color(0xFF31320a)
          : Color(0xFF31320a),
      onTertiaryContainer: isM3Enabled
          ? darkDynamicColor?.onTertiaryContainer ?? Color(0xFFe5e6ae)
          : Color(0xFFe5e6ae),
      outline: isM3Enabled
          ? darkDynamicColor?.outline ?? Color(0xFF9f8d83)
          : Color(0xFF9f8d83),
      tertiary: isM3Enabled
          ? darkDynamicColor?.tertiary ?? Color(0xFFc9ca94)
          : Color(0xFFc9ca94),
      tertiaryContainer: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF48491f)
          : Color(0xFF48491f),
      surfaceVariant: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF52443c)
          : Color(0xFF52443c),
      brightness: Brightness.dark,
    ).copyWith(
        background: isM3Enabled
            ? darkDynamicColor?.background ?? Colors.black
            : Colors.black),
  );
}

ThemeData lightThemeData(bool isM3Enabled, ColorScheme? lightDynamicColor) {
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade400),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? lightDynamicColor?.onPrimary ?? Colors.black
            : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? lightDynamicColor?.onPrimary ?? Colors.black
              : Colors.black,
          fontFamily: 'PoppinsSB',
          fontSize: 21),
    ),
    dialogTheme: DialogTheme(backgroundColor: Color(0xFFdedede)),
    primaryColor: isM3Enabled
        ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
        : const Color(0xFFF57C00),
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
    ),
    bannerTheme: MaterialBannerThemeData(),
    chipTheme: ChipThemeData(),
    snackBarTheme: SnackBarThemeData(),
    scaffoldBackgroundColor: Color(0xFFf5f5f5),
    radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(isM3Enabled
            ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
            : Color(0xFFF57C00))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
              : Color(0xFFF57C00),
        ),
        foregroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? lightDynamicColor?.onPrimary ?? Color(0xFFF57C00)
              : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isM3Enabled
                ? lightDynamicColor?.primary.withOpacity(0.1) ??
                    Color(0xFFF57C00).withOpacity(0.1)
                : Color(0xFFF57C00).withOpacity(0.1),
          ),
          maximumSize: MaterialStateProperty.all(const Size(200, 60)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
                        : Color(0xFFF57C00),
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? lightDynamicColor?.onPrimary ?? Colors.black
          : Colors.black,
      color: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
      selectionHandleColor: const Color(0xFF000000),
      selectionColor: Colors.black12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.black26, fontFamily: 'Poppins'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    indicatorColor: isM3Enabled
        ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
        : Color(0xFFF57C00),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(
        isM3Enabled
            ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
            : Color(0xFFF57C00),
      ),
      trackColor: MaterialStatePropertyAll(
        isM3Enabled
            ? lightDynamicColor?.primaryContainer ?? Color(0xFF994d02)
            : Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : const Color(0xFFF57C00),
      primaryContainer: isM3Enabled
          ? lightDynamicColor?.primaryContainer ?? Color(0xFFffdcc6)
          : Color(0xFFffdcc6),
      secondary: isM3Enabled
          ? lightDynamicColor?.secondary ?? Color(0xFF755846)
          : Color(0xFF755846),
      secondaryContainer: isM3Enabled
          ? lightDynamicColor?.secondaryContainer ?? Color(0xFFffdcc6)
          : Color(0xFFffdcc6),
      surface: isM3Enabled
          ? lightDynamicColor?.surface ?? Color(0xFFfffbff)
          : Color(0xFFfffbff),
      background: isM3Enabled
          ? lightDynamicColor?.background ?? Color(0xFFfffbff)
          : Color(0xFFfffbff),
      error: isM3Enabled
          ? lightDynamicColor?.error ?? Color(0xFFba1a1a)
          : Color(0xFFba1a1a),
      onPrimary: isM3Enabled
          ? lightDynamicColor?.error ?? Color(0xFFffffff)
          : Color(0xFFffffff),
      onSecondary: isM3Enabled
          ? lightDynamicColor?.onSecondary ?? Color(0xFFffffff)
          : Color(0xFFffffff),
      onSurface: isM3Enabled
          ? lightDynamicColor?.onSurface ?? Color(0xFF201a17)
          : Color(0xFF201a17),
      onBackground: isM3Enabled
          ? lightDynamicColor?.onBackground ?? Color(0xFF201a17)
          : Color(0xFF201a17),
      onError: isM3Enabled
          ? lightDynamicColor?.onError ?? Color(0xFFffffff)
          : Color(0xFFffffff),
      errorContainer: isM3Enabled
          ? lightDynamicColor?.errorContainer ?? Color(0xFFffdad6)
          : Color(0xFFffdad6),
      onErrorContainer: isM3Enabled
          ? lightDynamicColor?.onErrorContainer ?? Color(0xFF410002)
          : Color(0xFF410002),
      onPrimaryContainer: isM3Enabled
          ? lightDynamicColor?.onPrimaryContainer ?? Color(0xFF311400)
          : Color(0xFF311400),
      onSecondaryContainer: isM3Enabled
          ? lightDynamicColor?.onSecondaryContainer ?? Color(0xFF2b1708)
          : Color(0xFF2b1708),
      onSurfaceVariant: isM3Enabled
          ? lightDynamicColor?.onSurfaceVariant ?? Color(0xFF52443c)
          : Color(0xFF52443c),
      onTertiary: isM3Enabled
          ? lightDynamicColor?.onTertiary ?? Color(0xFFffffff)
          : Color(0xFFffffff),
      onTertiaryContainer: isM3Enabled
          ? lightDynamicColor?.onTertiaryContainer ?? Color(0xFF1c1d00)
          : Color(0xFF1c1d00),
      outline: isM3Enabled
          ? lightDynamicColor?.outline ?? Color(0xFF84746a)
          : Color(0xFF84746a),
      tertiary: isM3Enabled
          ? lightDynamicColor?.tertiary ?? Color(0xFF5f6134)
          : Color(0xFF5f6134),
      tertiaryContainer: isM3Enabled
          ? lightDynamicColor?.tertiaryContainer ?? Color(0xFFe5e6ae)
          : Color(0xFFe5e6ae),
      surfaceVariant: isM3Enabled
          ? lightDynamicColor?.tertiaryContainer ?? Color(0xFFf4ded3)
          : Color(0xFFf4ded3),
      brightness: Brightness.light,
    ).copyWith(
        background: isM3Enabled
            ? lightDynamicColor?.background ?? Colors.white
            : Colors.white),
  );
}

ThemeData amoledThemeData(bool isM3Enabled, ColorScheme? darkDynamicColor) {
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? darkDynamicColor?.onPrimary ?? Colors.black
            : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.black
              : Colors.black,
          fontFamily: 'PoppinsSB',
          fontSize: 21),
    ),
    dialogTheme: DialogTheme(backgroundColor: Color(0xFF171717)),
    primaryColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : const Color(0xFFF57C00),
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
    ),
    bannerTheme: MaterialBannerThemeData(),
    chipTheme: ChipThemeData(),
    snackBarTheme: SnackBarThemeData(),
    scaffoldBackgroundColor: Colors.black,
    radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : Color(0xFFF57C00))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
              : Color(0xFFF57C00),
        ),
        foregroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Color(0xFFF57C00)
              : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isM3Enabled
                ? darkDynamicColor?.primary.withOpacity(0.1) ??
                    Color(0xFFF57C00).withOpacity(0.1)
                : Color(0xFFF57C00).withOpacity(0.1),
          ),
          maximumSize: MaterialStateProperty.all(const Size(200, 60)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
                        : Color(0xFFF57C00),
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Colors.black
          : Colors.black,
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : Color(0xFFF57C00),
      selectionHandleColor: const Color(0xFFFFFFFF),
      selectionColor: Colors.white12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Poppins'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    indicatorColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : Color(0xFFF57C00),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : Color(0xFFF57C00),
      ),
      trackColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primaryContainer ?? Color(0xFF994d02)
            : Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : const Color(0xFFF57C00),
      primaryContainer: isM3Enabled
          ? darkDynamicColor?.primaryContainer ?? Color(0xFF723600)
          : Color(0xFF723600),
      secondary: isM3Enabled
          ? darkDynamicColor?.secondary ?? Color(0xFFe4bfa8)
          : Color(0xFFe4bfa8),
      secondaryContainer: isM3Enabled
          ? darkDynamicColor?.secondaryContainer ?? Color(0xFF5b4130)
          : Color(0xFF5b4130),
      surface: isM3Enabled
          ? darkDynamicColor?.surface ?? Color(0xFF201a17)
          : Colors.black,
      background: isM3Enabled
          ? darkDynamicColor?.background ?? Color(0xFF201a17)
          : Colors.black,
      error: isM3Enabled
          ? darkDynamicColor?.error ?? Color(0xFFffb4ab)
          : Color(0xFFffb4ab),
      onPrimary: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Color(0xFF502400)
          : Color(0xFF502400),
      onSecondary: isM3Enabled
          ? darkDynamicColor?.onSecondary ?? Color(0xFF422b1b)
          : Color(0xFF502400),
      onSurface: isM3Enabled
          ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
          : Color(0xFFece0da),
      onBackground: isM3Enabled
          ? darkDynamicColor?.onBackground ?? Color(0xFFece0da)
          : Color(0xFFece0da),
      onError: isM3Enabled
          ? darkDynamicColor?.onError ?? Color(0xFF690005)
          : Color(0xFF690005),
      errorContainer: isM3Enabled
          ? darkDynamicColor?.errorContainer ?? Color(0xFF93000a)
          : Color(0xFF93000a),
      onErrorContainer: isM3Enabled
          ? darkDynamicColor?.onErrorContainer ?? Color(0xFFffdad6)
          : Color(0xFFffdad6),
      onPrimaryContainer: isM3Enabled
          ? darkDynamicColor?.onPrimaryContainer ?? Color(0xFFffdcc6)
          : Color(0xFFffdcc6),
      onSecondaryContainer: isM3Enabled
          ? darkDynamicColor?.onSecondaryContainer ?? Color(0xFFffdcc6)
          : Color(0xFFffdcc6),
      onSurfaceVariant: isM3Enabled
          ? darkDynamicColor?.onSurfaceVariant ?? Color(0xFFd7c3b7)
          : Color(0xFFd7c3b7),
      onTertiary: isM3Enabled
          ? darkDynamicColor?.onTertiary ?? Color(0xFF31320a)
          : Color(0xFF31320a),
      onTertiaryContainer: isM3Enabled
          ? darkDynamicColor?.onTertiaryContainer ?? Color(0xFFe5e6ae)
          : Color(0xFFe5e6ae),
      outline: isM3Enabled
          ? darkDynamicColor?.outline ?? Color(0xFF9f8d83)
          : Color(0xFF9f8d83),
      tertiary: isM3Enabled
          ? darkDynamicColor?.tertiary ?? Color(0xFFc9ca94)
          : Color(0xFFc9ca94),
      tertiaryContainer: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF48491f)
          : Color(0xFF48491f),
      surfaceVariant: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF52443c)
          : Color(0xFF52443c),
      brightness: Brightness.dark,
    ).copyWith(
        background: isM3Enabled
            ? darkDynamicColor?.background ?? Colors.black
            : Colors.black),
  );
}

class Styles {
  static ThemeData themeData(
      {required String appThemeMode,
      required bool isM3Enabled,
      required ColorScheme? lightDynamicColor,
      required ColorScheme? darkDynamicColor,
      required BuildContext context}) {
    return appThemeMode == "dark"
        ? darkThemeData(isM3Enabled, darkDynamicColor)
        : appThemeMode == "light"
            ? lightThemeData(isM3Enabled, lightDynamicColor)
            : appThemeMode == "amoled"
                ? amoledThemeData(isM3Enabled, darkDynamicColor)
                : darkThemeData(isM3Enabled, darkDynamicColor);
  }
}
