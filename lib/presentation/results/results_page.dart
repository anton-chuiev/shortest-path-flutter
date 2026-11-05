import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/results/results_routes.dart';

/// Screen 1.3. Placeholder: the real list of results comes in F4.
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.routes});

  final ResultsRoutes routes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result list screen')),
      body: ListView(
        children: [
          // TODO(F4): replace with one row per calculated result.
          ListTile(
            title: const Text(
              'Placeholder result',
              textAlign: TextAlign.center,
            ),
            onTap: routes.toPreview,
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
