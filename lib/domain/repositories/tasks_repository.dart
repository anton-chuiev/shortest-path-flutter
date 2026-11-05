import 'package:shortest_path/domain/entities/task.dart';

/// Access to the shortest-path tasks API.
///
/// Failures are reported as `NetworkException` from `core/network`;
/// they are not translated into separate domain errors.
abstract interface class TasksRepository {
  /// Loads the tasks to solve with a GET request to [url].
  Future<List<Task>> fetchTasks(Uri url);
}
