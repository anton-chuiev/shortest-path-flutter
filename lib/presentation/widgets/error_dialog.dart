import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows [message] in a platform-style alert with a single `OK` button:
/// Cupertino on iOS and macOS, Material elsewhere.
Future<void> showErrorDialog(BuildContext context, {required String message}) {
  return showAdaptiveDialog<void>(
    context: context,
    builder: (_) => AlertDialog.adaptive(
      title: const Text('Error'),
      content: Text(message),
      actions: const [_OkAction()],
    ),
  );
}

/// `AlertDialog.adaptive` switches only the dialog itself; its buttons have
/// to be picked per platform too.
class _OkAction extends StatelessWidget {
  const _OkAction();

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).pop();
    const label = Text('OK');

    return switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoDialogAction(
        onPressed: close,
        child: label,
      ),
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.windows => TextButton(onPressed: close, child: label),
    };
  }
}
