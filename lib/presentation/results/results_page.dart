import 'package:flutter/material.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/presentation/formatting/result_path_text.dart';
import 'package:shortest_path/presentation/results/results_routes.dart';
import 'package:shortest_path/presentation/theme/app_colors.dart';

/// Screen 1.3: the shortest path of every task, one row per task.
///
/// Only shows data it was given, so it needs no Cubit.
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.routes, required this.results});

  final ResultsRoutes routes;

  /// One result per task, in the order the tasks came from the server.
  final List<TaskResult> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result list screen')),
      body: ListView.separated(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          // A long path wraps onto several lines instead of being cut off.
          return ListTile(
            // Material 3 uses bodyLarge for the title: larger and with wider
            // letter spacing than the small text on the mockup.
            titleTextStyle: Theme.of(context).textTheme.bodyMedium,
            title: Text(resultPathText(result), textAlign: TextAlign.center),
            onTap: () => routes.toPreview(result),
          );
        },
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.divider),
      ),
    );
  }
}
