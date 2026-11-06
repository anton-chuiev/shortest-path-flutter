import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortest_path/app/app.dart';
import 'package:shortest_path/app/app_router.dart';
import 'package:shortest_path/core/network/api_client.dart';
import 'package:shortest_path/data/repositories/tasks_repository_impl.dart';
import 'package:shortest_path/data/repositories/url_repository_impl.dart';

Future<void> main() async {
  // The saved URL is read through a platform channel, which needs the
  // Flutter engine to be initialised before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Composition root: app-wide dependencies are created once, here.
  // The http.Client lives as long as the app, so it is never closed.
  final tasksRepository = TasksRepositoryImpl(ApiClient(http.Client()));
  final urlRepository = UrlRepositoryImpl(SharedPreferencesAsync());

  // Read before the first frame, so the URL field never flashes empty.
  final savedUrl = await urlRepository.loadUrl();

  runApp(
    App(
      router: AppRouter(),
      tasksRepository: tasksRepository,
      urlRepository: urlRepository,
      initialUrl: savedUrl,
    ),
  );
}
