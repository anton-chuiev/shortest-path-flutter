import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/theme/app_colors.dart';
import 'package:shortest_path/presentation/theme/app_dimens.dart';

/// App-wide theme matching the mockups: blue app bar, light grey background,
/// light blue rounded bottom button with a blue border.
abstract final class AppTheme {
  static const double _buttonHeight = 48;

  /// Built once on first access and reused afterwards.
  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.appBar,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBar,
        foregroundColor: AppColors.onAppBar,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: AppColors.onPrimaryButton,
          elevation: 0,
          minimumSize: const Size.fromHeight(_buttonHeight),
          side: const BorderSide(color: AppColors.primaryButtonBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
    );
  }
}
