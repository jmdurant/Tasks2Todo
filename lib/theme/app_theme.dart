import 'package:flutter/material.dart';

import '../res/constants.dart';

class AppTheme {
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: darkOrange,
    brightness: Brightness.light,
    primary: darkOrange,
    secondary: darkAccentBlue,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: darkAccentBlue,
    brightness: Brightness.dark,
    primary: darkAccentBlue,
    secondary: darkOrange,
  );

  static ThemeData get lightTheme => _baseTheme(_lightScheme);
  static ThemeData get darkTheme => _baseTheme(_darkScheme);

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    final textTheme = Typography.material2021().black.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
