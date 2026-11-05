import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/theme/app_dimens.dart';

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
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: ElevatedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
