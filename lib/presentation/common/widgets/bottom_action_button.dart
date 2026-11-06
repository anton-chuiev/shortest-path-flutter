import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/common/theme/app_dimens.dart';

/// Full-width primary button pinned to the bottom of a screen.
///
/// Place it as the last child of the page's [Column]. [SafeArea] keeps it
/// clear of the home indicator / system navigation bar, and the padding adds
/// spacing on top of that inset.
class BottomActionButton extends StatelessWidget {
  const BottomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  static const double _loaderSize = 20;
  static const double _loaderStrokeWidth = 2;

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  /// Disables the button and shows a progress indicator instead of [label].
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? Semantics(
                  label: label,
                  child: const SizedBox.square(
                    dimension: _loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: _loaderStrokeWidth,
                    ),
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
