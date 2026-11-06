import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';
import 'package:shortest_path/domain/repositories/url_repository.dart';
import 'package:shortest_path/presentation/screens/home/home_cubit.dart';
import 'package:shortest_path/presentation/screens/home/home_page.dart';
import 'package:shortest_path/presentation/screens/home/home_routes.dart';
import 'package:shortest_path/presentation/screens/preview/preview_page.dart';
import 'package:shortest_path/presentation/screens/process/process_cubit.dart';
import 'package:shortest_path/presentation/screens/process/process_page.dart';
import 'package:shortest_path/presentation/screens/process/process_routes.dart';
import 'package:shortest_path/presentation/screens/results/results_page.dart';
import 'package:shortest_path/presentation/screens/results/results_routes.dart';

/// Single place that knows how screens are built and connected.
///
/// Each page depends only on its own routes interface; this class
/// implements all of them. It drives the app's [Navigator] through
/// [navigatorKey], so callers don't need a [BuildContext].
class AppRouter implements HomeRoutes, ProcessRoutes, ResultsRoutes {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// The first screen, used as `MaterialApp.home`; [initialUrl] is the URL
  /// saved on a previous launch.
  Widget buildHome({Uri? initialUrl}) {
    return BlocProvider(
      create: (context) => HomeCubit(
        tasksRepository: context.read<TasksRepository>(),
        urlRepository: context.read<UrlRepository>(),
      ),
      child: HomePage(routes: this, initialUrl: initialUrl),
    );
  }

  @override
  void toProcess({required Uri url, required List<Task> tasks}) {
    _push(
      BlocProvider(
        create: (context) {
          final cubit = ProcessCubit(
            repository: context.read<TasksRepository>(),
            url: url,
            tasks: tasks,
          );
          // The calculation starts as soon as the screen is shown.
          unawaited(cubit.calculate());
          return cubit;
        },
        child: ProcessPage(routes: this),
      ),
    );
  }

  @override
  void toResults(List<TaskResult> results) =>
      _push(ResultsPage(routes: this, results: results));

  @override
  void toPreview(TaskResult result) => _push(PreviewPage(result: result));

  void _push(Widget page) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw StateError('AppRouter.navigatorKey is not attached to a Navigator');
    }
    // The returned Future completes when the page is popped; nobody awaits
    // a result from these screens, so it is intentionally not awaited.
    unawaited(navigator.push(MaterialPageRoute<void>(builder: (_) => page)));
  }
}
