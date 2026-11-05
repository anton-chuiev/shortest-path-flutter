import 'package:flutter/material.dart';
import 'package:shortest_path/app/app_router.dart';
import 'package:shortest_path/presentation/home/home_page.dart';
import 'package:shortest_path/presentation/theme/app_theme.dart';

/// Root widget: wires the theme and the router into [MaterialApp].
class App extends StatelessWidget {
  const App({super.key, required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shortest Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: router.navigatorKey,
      home: HomePage(routes: router),
    );
  }
}
