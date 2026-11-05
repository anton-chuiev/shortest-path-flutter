import 'package:flutter/material.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/presentation/process/process_routes.dart';
import 'package:shortest_path/presentation/theme/app_dimens.dart';
import 'package:shortest_path/presentation/widgets/bottom_action_button.dart';

/// Screen 1.2. Placeholder: path calculation and sending results come in F3.
class ProcessPage extends StatelessWidget {
  const ProcessPage({
    super.key,
    required this.routes,
    required this.url,
    required this.tasks,
  });

  final ProcessRoutes routes;

  /// API URL entered on the Home screen; results are sent to it too.
  final Uri url;

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process screen')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                // TODO(F3): replace with the calculation progress from
                // ProcessCubit; for now shows what came from the Home screen.
                child: Text(
                  '${tasks.length} tasks loaded from $url',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          BottomActionButton(
            label: 'Send results to server',
            onPressed: routes.toResults,
          ),
        ],
      ),
    );
  }
}
