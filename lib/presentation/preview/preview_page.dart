import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/presentation/formatting/result_path_text.dart';
import 'package:shortest_path/presentation/preview/result_grid.dart';
import 'package:shortest_path/presentation/theme/app_dimens.dart';

/// Screen 1.4: the grid of one task with its shortest path, and the path
/// as text below it.
class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key, required this.result});

  /// The result selected on the Result list screen.
  final TaskResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview screen')),
      // The grid stays in place; only the text below it scrolls. A grid
      // inside a scroll view would fight it over vertical drags while zoomed.
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // As wide as the screen in portrait. A window wider than tall
            // (Android split screen) limits the grid by its height instead.
            Center(
              child: SizedBox.square(
                dimension: math.min(
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
                child: ResultGrid(result: result),
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small,
                  ),
                  child: Text(
                    resultPathText(result),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
