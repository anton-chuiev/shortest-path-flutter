import 'package:shortest_path/domain/entities/task.dart';

/// Navigation actions available from the Home screen.
abstract interface class HomeRoutes {
  /// Opens the Process screen with the [tasks] loaded from [url];
  /// results are sent to the same [url].
  void toProcess({required Uri url, required List<Task> tasks});
}
