import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/app/app_router.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';
import 'package:shortest_path/presentation/theme/app_theme.dart';

/// Root widget: provides the repository to the whole tree and wires the
/// theme and the router into [MaterialApp].
class App extends StatelessWidget {
  const App({super.key, required this.router, required this.tasksRepository});

  final AppRouter router;
  final TasksRepository tasksRepository;

  @override
  Widget build(BuildContext context) {
    // Above MaterialApp, so every route can read the repository.
    return RepositoryProvider.value(
      value: tasksRepository,
      child: MaterialApp(
        title: 'Shortest Path',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: router.navigatorKey,
        home: router.buildHome(),
      ),
    );
  }
}
