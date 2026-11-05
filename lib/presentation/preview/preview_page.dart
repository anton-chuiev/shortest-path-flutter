import 'package:flutter/material.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/presentation/formatting/result_path_text.dart';
import 'package:shortest_path/presentation/theme/app_dimens.dart';

/// Screen 1.4. Placeholder: shows only the path text; the grid comes in F5.
class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key, required this.result});

  /// The result selected on the Result list screen.
  final TaskResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview screen')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          // TODO(F5): show the grid with the path above this text.
          Text(resultPathText(result), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
