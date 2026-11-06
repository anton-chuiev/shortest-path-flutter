import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/app/app_router.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';
import 'package:shortest_path/domain/repositories/url_repository.dart';
import 'package:shortest_path/presentation/common/theme/app_theme.dart';

/// Root widget: provides the repositories to the whole tree and wires the
/// theme and the router into [MaterialApp].
class App extends StatelessWidget {
  const App({
    super.key,
    required this.router,
    required this.tasksRepository,
    required this.urlRepository,
    this.initialUrl,
  });

  final AppRouter router;
  final TasksRepository tasksRepository;
  final UrlRepository urlRepository;

  /// The URL saved on a previous launch, shown on the Home screen.
  final Uri? initialUrl;

  @override
  Widget build(BuildContext context) {
    // Above MaterialApp, so every route can read the repositories.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tasksRepository),
        RepositoryProvider.value(value: urlRepository),
      ],
      child: MaterialApp(
        title: 'Shortest Path',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: router.navigatorKey,
        home: router.buildHome(initialUrl: initialUrl),
      ),
    );
  }
}
