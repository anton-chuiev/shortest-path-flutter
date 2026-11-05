import 'package:shortest_path/core/network/cancellation_token.dart';
import 'package:shortest_path/domain/entities/check_result.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/entities/task_result.dart';

/// Access to the shortest-path tasks API.
///
/// Failures are reported as `NetworkException` from `core/network`;
/// they are not translated into separate domain errors.
abstract interface class TasksRepository {
  /// Loads the tasks to solve with a GET request to [url].
  Future<List<Task>> fetchTasks(Uri url);

  /// Sends [results] with a POST request to [url] and returns the server's
  /// verdict on each of them.
  ///
  /// The server expects a result for every task it returned, including the
  /// tasks without a path. Cancelling [cancellationToken] aborts the request
  /// with `RequestCancelledException`.
  Future<List<CheckResult>> submitResults(
    Uri url,
    List<TaskResult> results, {
    CancellationToken? cancellationToken,
  });
}
