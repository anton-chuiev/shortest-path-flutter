import 'package:shortest_path/domain/entities/task_result.dart';

/// Navigation actions available from the Process screen.
abstract interface class ProcessRoutes {
  /// Opens the Result list screen with the sent [results].
  void toResults(List<TaskResult> results);
}
