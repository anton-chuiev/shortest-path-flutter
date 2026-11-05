import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/process/process_routes.dart';
import 'package:shortest_path/presentation/widgets/bottom_action_button.dart';

/// Screen 1.2. Placeholder: path calculation and sending results come in F3.
class ProcessPage extends StatelessWidget {
  const ProcessPage({super.key, required this.routes});

  final ProcessRoutes routes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process screen')),
      body: Column(
        children: [
          const Spacer(),
          BottomActionButton(
            label: 'Send results to server',
            onPressed: routes.toResults,
          ),
        ],
      ),
    );
  }
}
