// ignore_for_file: unnecessary_const, prefer_const_constructors
import 'package:flixquest/models/app_colors.dart';
import 'package:flutter/material.dart';

ThemeData darkThemeData(
    bool isM3Enabled, ColorScheme? darkDynamicColor, AppColor color) {
  bool useUserColor = color.index != -1;
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Figtree'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? darkDynamicColor?.onPrimary ?? Colors.black
            : useUserColor
                ? color.cs.onPrimary
                : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.black
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.black,
          fontFamily: 'FigtreeSB',
          fontSize: 21),
    ),
    dialogTheme: DialogThemeData(backgroundColor: Color(0xFF171717)),
    primaryColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : useUserColor
            ? color.cs.primary
            : Color(0xFFF57C00),
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
    ),
    bannerTheme: MaterialBannerThemeData(),
    chipTheme: ChipThemeData(),
    snackBarTheme: SnackBarThemeData(
        backgroundColor: isM3Enabled
            ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
            : useUserColor
                ? color.cs.onSurface
                : Color(0xFFece0da),
        contentTextStyle: TextStyle(
            color: isM3Enabled
                ? darkDynamicColor?.surface ?? Color(0xFF201a17)
                : useUserColor
                    ? color.cs.surface
                    : Color(0xFF201a17))),
    scaffoldBackgroundColor: Color(0xFF161716),
    radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : useUserColor
                ? color.cs.primary
                : Color(0xFFF57C00))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
              : useUserColor
                  ? color.cs.primary
                  : Color(0xFFF57C00),
        ),
        foregroundColor: WidgetStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.white
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isM3Enabled
                ? darkDynamicColor?.primary.withOpacity(0.1) ??
                    Color(0xFFF57C00).withOpacity(0.1)
                : useUserColor
                    ? color.cs.primary.withOpacity(0.1)
                    : Color(0xFFF57C00).withOpacity(0.1),
          ),
          maximumSize: WidgetStateProperty.all(const Size(200, 60)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
                        : useUserColor
                            ? color.cs.primary
                            : Color(0xFFF57C00),
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Colors.black
          : useUserColor
              ? color.cs.onPrimary
              : Colors.black,
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      selectionHandleColor: const Color(0xFFFFFFFF),
      selectionColor: Colors.white12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Figtree'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    indicatorColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : useUserColor
            ? color.cs.primary
            : Color(0xFFF57C00),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : useUserColor
                ? color.cs.primary
                : Color(0xFFF57C00),
      ),
      trackColor: WidgetStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primaryContainer ?? Color(0xFF994d02)
            : useUserColor
                ? color.cs.primaryContainer
                : Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      primaryContainer: isM3Enabled
          ? darkDynamicColor?.primaryContainer ?? Color(0xFF723600)
          : useUserColor
              ? color.cs.primaryContainer
              : Color(0xFF723600),
      secondary: isM3Enabled
          ? darkDynamicColor?.secondary ?? Color(0xFFe4bfa8)
          : useUserColor
              ? color.cs.secondary
              : Color(0xFFe4bfa8),
      secondaryContainer: isM3Enabled
          ? darkDynamicColor?.secondaryContainer ?? Color(0xFF5b4130)
          : useUserColor
              ? color.cs.secondaryContainer
              : Color(0xFF5b4130),
      surface: isM3Enabled
          ? darkDynamicColor?.surface ?? Color(0xFF201a17)
          : useUserColor
              ? color.cs.surface
              : Color(0xFF201a17),
      error: isM3Enabled
          ? darkDynamicColor?.error ?? Color(0xFFffb4ab)
          : useUserColor
              ? color.cs.error
              : Color(0xFFffb4ab),
      onPrimary: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Color(0xFF502400)
          : useUserColor
              ? color.cs.onPrimary
              : Color(0xFF502400),
      onSecondary: isM3Enabled
          ? darkDynamicColor?.onSecondary ?? Color(0xFF422b1b)
          : useUserColor
              ? color.cs.onSecondary
              : Color(0xFF502400),
      onSurface: isM3Enabled
          ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
          : useUserColor
              ? color.cs.onSurface
              : Color(0xFFece0da),
      onError: isM3Enabled
          ? darkDynamicColor?.onError ?? Color(0xFF690005)
          : useUserColor
              ? color.cs.onError
              : Color(0xFF690005),
      errorContainer: isM3Enabled
          ? darkDynamicColor?.errorContainer ?? Color(0xFF93000a)
          : useUserColor
              ? color.cs.errorContainer
              : Color(0xFF93000a),
      onErrorContainer: isM3Enabled
          ? darkDynamicColor?.onErrorContainer ?? Color(0xFFffdad6)
          : useUserColor
              ? color.cs.onErrorContainer
              : Color(0xFFffdad6),
      onPrimaryContainer: isM3Enabled
          ? darkDynamicColor?.onPrimaryContainer ?? Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onPrimaryContainer
              : Color(0xFFffdcc6),
      onSecondaryContainer: isM3Enabled
          ? darkDynamicColor?.onSecondaryContainer ?? Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onSecondaryContainer
              : Color(0xFFffdcc6),
      onSurfaceVariant: isM3Enabled
          ? darkDynamicColor?.onSurfaceVariant ?? Color(0xFFd7c3b7)
          : useUserColor
              ? color.cs.onSurfaceVariant
              : Color(0xFFd7c3b7),
      onTertiary: isM3Enabled
          ? darkDynamicColor?.onTertiary ?? Color(0xFF31320a)
          : useUserColor
              ? color.cs.onTertiary
              : Color(0xFF31320a),
      onTertiaryContainer: isM3Enabled
          ? darkDynamicColor?.onTertiaryContainer ?? Color(0xFFe5e6ae)
          : useUserColor
              ? color.cs.onTertiaryContainer
              : Color(0xFFe5e6ae),
      outline: isM3Enabled
          ? darkDynamicColor?.outline ?? Color(0xFF9f8d83)
          : useUserColor
              ? color.cs.outline
              : Color(0xFF9f8d83),
      tertiary: isM3Enabled
          ? darkDynamicColor?.tertiary ?? Color(0xFFc9ca94)
          : useUserColor
              ? color.cs.tertiary
              : Color(0xFFc9ca94),
      tertiaryContainer: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF48491f)
          : useUserColor
              ? color.cs.tertiaryContainer
              : Color(0xFF48491f),
      surfaceContainerHighest: isM3Enabled
          ? darkDynamicColor?.surfaceContainerHighest ?? Color(0xFF52443c)
          : useUserColor
              ? color.cs.surfaceContainerHighest
              : Color(0xFF52443c),
      brightness: Brightness.dark,
    ).copyWith(
        surface: isM3Enabled
            ? darkDynamicColor?.surface ?? Color(0xFF201a17)
            : useUserColor
                ? color.cs.surface
                : Color(0xFF201a17)),
  );
}

ThemeData lightThemeData(
    bool isM3Enabled, ColorScheme? lightDynamicColor, AppColor color) {
  bool useUserColor = color.index != -1;
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Figtree'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade400),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? lightDynamicColor?.onPrimary ?? Colors.black
            : useUserColor
                ? color.cs.onPrimary
                : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? lightDynamicColor?.onPrimary ?? Colors.black
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.black,
          fontFamily: 'FigtreeSB',
          fontSize: 21),
    ),
    dialogTheme: DialogThemeData(backgroundColor: Color(0xFFdedede)),
    primaryColor: isM3Enabled
        ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
        : useUserColor
            ? color.cs.primary
            : const Color(0xFFF57C00),
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
    ),
    bannerTheme: MaterialBannerThemeData(),
    chipTheme: ChipThemeData(),
    snackBarTheme: SnackBarThemeData(
        backgroundColor: isM3Enabled
            ? lightDynamicColor?.onSurface ?? Color(0xFF201a17)
            : useUserColor
                ? color.cs.onSurface
                : Color(0xFF201a17),
        contentTextStyle: TextStyle(
            color: isM3Enabled
                ? lightDynamicColor?.surface ?? Color(0xFFfffbff)
                : useUserColor
                    ? color.cs.surface
                    : Color(0xFFfffbff))),
    scaffoldBackgroundColor: Color(0xFFf5f5f5),
    radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(isM3Enabled
            ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
            : useUserColor
                ? color.cs.primary
                : Color(0xFFF57C00))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isM3Enabled
              ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
              : useUserColor
                  ? color.cs.primary
                  : Color(0xFFF57C00),
        ),
        foregroundColor: WidgetStatePropertyAll(
          isM3Enabled
              ? lightDynamicColor?.onPrimary ?? Colors.white
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isM3Enabled
                ? lightDynamicColor?.primary.withOpacity(0.1) ??
                    Color(0xFFF57C00).withOpacity(0.1)
                : useUserColor
                    ? color.cs.primary.withOpacity(0.1)
                    : Color(0xFFF57C00).withOpacity(0.1),
          ),
          maximumSize: WidgetStateProperty.all(const Size(200, 60)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
                        : useUserColor
                            ? color.cs.primary
                            : Color(0xFFF57C00),
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? lightDynamicColor?.onPrimary ?? Colors.black
          : useUserColor
              ? color.cs.onPrimary
              : Colors.black,
      color: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      selectionHandleColor: const Color(0xFF000000),
      selectionColor: Colors.black12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.black26, fontFamily: 'Figtree'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    indicatorColor: isM3Enabled
        ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
        : useUserColor
            ? color.cs.primary
            : Color(0xFFF57C00),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(
        isM3Enabled
            ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
            : useUserColor
                ? color.cs.primary
                : Color(0xFFF57C00),
      ),
      trackColor: WidgetStatePropertyAll(
        isM3Enabled
            ? lightDynamicColor?.primaryContainer ?? Color(0xFF994d02)
            : useUserColor
                ? color.cs.primaryContainer
                : Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? lightDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : const Color(0xFFF57C00),
      primaryContainer: isM3Enabled
          ? lightDynamicColor?.primaryContainer ?? Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.primaryContainer
              : Color(0xFFffdcc6),
      secondary: isM3Enabled
          ? lightDynamicColor?.secondary ?? Color(0xFF755846)
          : useUserColor
              ? color.cs.secondary
              : Color(0xFF755846),
      secondaryContainer: isM3Enabled
          ? lightDynamicColor?.secondaryContainer ?? Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.secondaryContainer
              : Color(0xFFffdcc6),
      surface: isM3Enabled
          ? lightDynamicColor?.surface ?? Color(0xFFfffbff)
          : useUserColor
              ? color.cs.surface
              : Color(0xFFfffbff),
      error: isM3Enabled
          ? lightDynamicColor?.error ?? Color(0xFFba1a1a)
          : useUserColor
              ? color.cs.error
              : Color(0xFFba1a1a),
      onPrimary: isM3Enabled
          ? lightDynamicColor?.onPrimary ?? Color(0xFFFFC890)
          : useUserColor
              ? color.cs.onPrimary
              : Color(0xFFFFC890),
      onSecondary: isM3Enabled
          ? lightDynamicColor?.onSecondary ?? Color(0xFFffffff)
          : useUserColor
              ? color.cs.onSecondary
              : Color(0xFFffffff),
      onSurface: isM3Enabled
          ? lightDynamicColor?.onSurface ?? Color(0xFF201a17)
          : useUserColor
              ? color.cs.onSurface
              : Color(0xFF201a17),
      onError: isM3Enabled
          ? lightDynamicColor?.onError ?? Color(0xFFffffff)
          : useUserColor
              ? color.cs.onError
              : Color(0xFFffffff),
      errorContainer: isM3Enabled
          ? lightDynamicColor?.errorContainer ?? Color(0xFFffdad6)
          : useUserColor
              ? color.cs.errorContainer
              : Color(0xFFffdad6),
      onErrorContainer: isM3Enabled
          ? lightDynamicColor?.onErrorContainer ?? Color(0xFF410002)
          : useUserColor
              ? color.cs.onErrorContainer
              : Color(0xFF410002),
      onPrimaryContainer: isM3Enabled
          ? lightDynamicColor?.onPrimaryContainer ?? Color(0xFF311400)
          : useUserColor
              ? color.cs.onPrimaryContainer
              : Color(0xFF311400),
      onSecondaryContainer: isM3Enabled
          ? lightDynamicColor?.onSecondaryContainer ?? Color(0xFF2b1708)
          : useUserColor
              ? color.cs.onSecondaryContainer
              : Color(0xFF2b1708),
      onSurfaceVariant: isM3Enabled
          ? lightDynamicColor?.onSurfaceVariant ?? Color(0xFF52443c)
          : useUserColor
              ? color.cs.onSurfaceVariant
              : Color(0xFF52443c),
      onTertiary: isM3Enabled
          ? lightDynamicColor?.onTertiary ?? Color(0xFFffffff)
          : useUserColor
              ? color.cs.onTertiary
              : Color(0xFFffffff),
      onTertiaryContainer: isM3Enabled
          ? lightDynamicColor?.onTertiaryContainer ?? Color(0xFF1c1d00)
          : useUserColor
              ? color.cs.onTertiaryContainer
              : Color(0xFF1c1d00),
      outline: isM3Enabled
          ? lightDynamicColor?.outline ?? Color(0xFF84746a)
          : useUserColor
              ? color.cs.outline
              : Color(0xFF84746a),
      tertiary: isM3Enabled
          ? lightDynamicColor?.tertiary ?? Color(0xFF5f6134)
          : useUserColor
              ? color.cs.tertiary
              : Color(0xFF5f6134),
      tertiaryContainer: isM3Enabled
          ? lightDynamicColor?.tertiaryContainer ?? Color(0xFFe5e6ae)
          : useUserColor
              ? color.cs.tertiaryContainer
              : Color(0xFFe5e6ae),
      surfaceContainerHighest: isM3Enabled
          ? lightDynamicColor?.surfaceContainerHighest ?? Color(0xFFf4ded3)
          : useUserColor
              ? color.cs.surfaceContainerHighest
              : Color(0xFFf4ded3),
      brightness: Brightness.light,
    ).copyWith(
        surface: isM3Enabled
            ? lightDynamicColor?.surface ?? Color(0xFFfffbff)
            : useUserColor
                ? color.cs.surface
                : Color(0xFFfffbff)),
  );
}

ThemeData lightsOutThemeData(
    bool isM3Enabled, ColorScheme? darkDynamicColor, AppColor color) {
  bool useUserColor = color.index != -1;
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Figtree'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? darkDynamicColor?.onPrimary ?? Colors.black
            : useUserColor
                ? color.cs.onPrimary
                : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.black
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.black,
          fontFamily: 'FigtreeSB',
          fontSize: 21),
      // shape: ContinuousRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     bottomLeft: Radius.circular(20.0),
      //     bottomRight: Radius.circular(20.0),
      //   ),
      // ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: Color(0xFF171717)),
    primaryColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : useUserColor
            ? color.cs.primary
            : const Color(0xFFF57C00),
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
    ),
    bannerTheme: MaterialBannerThemeData(),
    chipTheme: ChipThemeData(),
    snackBarTheme: SnackBarThemeData(
        backgroundColor: isM3Enabled
            ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
            : useUserColor
                ? color.cs.onSurface
                : Color(0xFFece0da),
        contentTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.surface ?? Color(0xFF201a17)
              : useUserColor
                  ? color.cs.surface
                  : Color(0xFF201a17),
        )),
    scaffoldBackgroundColor: Colors.black,
    radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : useUserColor
                ? color.cs.primary
                : Color(0xFFF57C00))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
              : useUserColor
                  ? color.cs.primary
                  : Color(0xFFF57C00),
        ),
        foregroundColor: WidgetStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.white
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isM3Enabled
                ? darkDynamicColor?.primary.withOpacity(0.1) ??
                    Color(0xFFF57C00).withOpacity(0.1)
                : useUserColor
                    ? color.cs.primary.withOpacity(0.1)
                    : Color(0xFFF57C00).withOpacity(0.1),
          ),
          maximumSize: WidgetStateProperty.all(const Size(200, 60)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
                        : useUserColor
                            ? color.cs.primary
                            : Color(0xFFF57C00),
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Colors.black
          : Colors.black,
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : Color(0xFFF57C00),
      selectionHandleColor: const Color(0xFFFFFFFF),
      selectionColor: Colors.white12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Figtree'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    indicatorColor: isM3Enabled
        ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
        : useUserColor
            ? color.cs.primary
            : Color(0xFFF57C00),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
            : useUserColor
                ? color.cs.primary
                : Color(0xFFF57C00),
      ),
      trackColor: WidgetStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primaryContainer ?? Color(0xFF994d02)
            : useUserColor
                ? color.cs.primaryContainer
                : Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? darkDynamicColor?.primary ?? Color(0xFFF57C00)
          : useUserColor
              ? color.cs.primary
              : const Color(0xFFF57C00),
      primaryContainer: isM3Enabled
          ? darkDynamicColor?.primaryContainer ?? Color(0xFF723600)
          : useUserColor
              ? color.cs.primaryContainer
              : Color(0xFF723600),
      secondary: isM3Enabled
          ? darkDynamicColor?.secondary ?? Color(0xFFe4bfa8)
          : useUserColor
              ? color.cs.secondary
              : Color(0xFFe4bfa8),
      secondaryContainer: isM3Enabled
          ? darkDynamicColor?.secondaryContainer ?? Color(0xFF5b4130)
          : useUserColor
              ? color.cs.secondaryContainer
              : Color(0xFF5b4130),
      surface: isM3Enabled
          ? darkDynamicColor?.surface ?? Color(0xFF201a17)
          : useUserColor
              ? color.cs.surface
              : Colors.black,
      error: isM3Enabled
          ? darkDynamicColor?.error ?? Color(0xFFffb4ab)
          : useUserColor
              ? color.cs.error
              : Color(0xFFffb4ab),
      onPrimary: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Color(0xFF502400)
          : useUserColor
              ? color.cs.onPrimary
              : Color(0xFF502400),
      onSecondary: isM3Enabled
          ? darkDynamicColor?.onSecondary ?? Color(0xFF422b1b)
          : useUserColor
              ? color.cs.onSecondary
              : Color(0xFF502400),
      onSurface: isM3Enabled
          ? darkDynamicColor?.onSurface ?? Color(0xFFece0da)
          : useUserColor
              ? color.cs.onSurface
              : Color(0xFFece0da),
      onError: isM3Enabled
          ? darkDynamicColor?.onError ?? Color(0xFF690005)
          : useUserColor
              ? color.cs.onError
              : Color(0xFF690005),
      errorContainer: isM3Enabled
          ? darkDynamicColor?.errorContainer ?? Color(0xFF93000a)
          : useUserColor
              ? color.cs.errorContainer
              : Color(0xFF93000a),
      onErrorContainer: isM3Enabled
          ? darkDynamicColor?.onErrorContainer ?? Color(0xFFffdad6)
          : useUserColor
              ? color.cs.onErrorContainer
              : Color(0xFFffdad6),
      onPrimaryContainer: isM3Enabled
          ? darkDynamicColor?.onPrimaryContainer ?? Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onPrimaryContainer
              : Color(0xFFffdcc6),
      onSecondaryContainer: isM3Enabled
          ? darkDynamicColor?.onSecondaryContainer ?? Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onSecondaryContainer
              : Color(0xFFffdcc6),
      onSurfaceVariant: isM3Enabled
          ? darkDynamicColor?.onSurfaceVariant ?? Color(0xFFd7c3b7)
          : useUserColor
              ? color.cs.onSurfaceVariant
              : Color(0xFFd7c3b7),
      onTertiary: isM3Enabled
          ? darkDynamicColor?.onTertiary ?? Color(0xFF31320a)
          : useUserColor
              ? color.cs.onTertiary
              : Color(0xFF31320a),
      onTertiaryContainer: isM3Enabled
          ? darkDynamicColor?.onTertiaryContainer ?? Color(0xFFe5e6ae)
          : useUserColor
              ? color.cs.onTertiaryContainer
              : Color(0xFFe5e6ae),
      outline: isM3Enabled
          ? darkDynamicColor?.outline ?? Color(0xFF9f8d83)
          : useUserColor
              ? color.cs.outline
              : Color(0xFF9f8d83),
      tertiary: isM3Enabled
          ? darkDynamicColor?.tertiary ?? Color(0xFFc9ca94)
          : useUserColor
              ? color.cs.tertiary
              : Color(0xFFc9ca94),
      tertiaryContainer: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? Color(0xFF48491f)
          : useUserColor
              ? color.cs.tertiaryContainer
              : Color(0xFF48491f),
      surfaceContainerHighest: isM3Enabled
          ? darkDynamicColor?.surfaceContainerHighest ?? Color(0xFF52443c)
          : useUserColor
              ? color.cs.surfaceContainerHighest
              : Color(0xFF52443c),
      brightness: Brightness.dark,
    ).copyWith(
        surface: isM3Enabled
            ? darkDynamicColor?.surface ?? Color(0xFF201a17)
            : useUserColor
                ? color.cs.surface
                : Color(0xFF201a17)),
  );
}

class Styles {
  static ThemeData themeData(
      {required String appThemeMode,
      required bool isM3Enabled,
      required ColorScheme? lightDynamicColor,
      required ColorScheme? darkDynamicColor,
      required BuildContext context,
      required AppColor appColor}) {
    return appThemeMode == 'dark'
        ? darkThemeData(isM3Enabled, darkDynamicColor, appColor)
        : appThemeMode == 'light'
            ? lightThemeData(isM3Enabled, lightDynamicColor, appColor)
            : appThemeMode == 'amoled'
                ? lightsOutThemeData(isM3Enabled, darkDynamicColor, appColor)
                : darkThemeData(isM3Enabled, darkDynamicColor, appColor);
  }
}
