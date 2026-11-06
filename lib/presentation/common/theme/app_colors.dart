import 'package:flutter/material.dart';

/// App colors taken from the mockups in the task description.
abstract final class AppColors {
  static const Color appBar = Color(0xFF2196F3);
  static const Color onAppBar = Colors.white;

  static const Color background = Color(0xFFFAFAFA);

  static const Color primaryButton = Color(0xFF40C4FF);
  static const Color primaryButtonBorder = Color(0xFF448AFF);
  static const Color onPrimaryButton = Colors.black;

  static const Color progressIndicator = Color(0xFF2196F3);
  static const Color divider = Color(0xFFEEEEEE);

  // Preview grid: cell colors are given in the task description.
  static const Color startCell = Color(0xFF64FFDA);
  static const Color endCell = Color(0xFF009688);
  static const Color blockedCell = Color(0xFF000000);
  static const Color pathCell = Color(0xFF4CAF50);
  static const Color emptyCell = Color(0xFFFFFFFF);
  static const Color gridLine = Color(0xFF000000);

  /// Coordinates inside a cell; white on a black (blocked) cell.
  static const Color onCell = Colors.black87;
  static const Color onBlockedCell = Colors.white;
}
