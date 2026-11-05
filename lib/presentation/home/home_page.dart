import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/home/home_routes.dart';
import 'package:shortest_path/presentation/widgets/bottom_action_button.dart';

/// Screen 1.1. Placeholder: URL input, validation and task loading come in F2.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.routes});

  final HomeRoutes routes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home screen')),
      body: Column(
        children: [
          const Spacer(),
          BottomActionButton(
            label: 'Start counting process',
            onPressed: routes.toProcess,
          ),
        ],
      ),
    );
  }
}
