import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shortest_path/app/app.dart';
import 'package:shortest_path/app/app_router.dart';
import 'package:shortest_path/core/network/api_client.dart';
import 'package:shortest_path/data/repositories/tasks_repository_impl.dart';

void main() {
  // Composition root: app-wide dependencies are created once, here.
  // The http.Client lives as long as the app, so it is never closed.
  final tasksRepository = TasksRepositoryImpl(ApiClient(http.Client()));

  runApp(App(router: AppRouter(), tasksRepository: tasksRepository));
}
