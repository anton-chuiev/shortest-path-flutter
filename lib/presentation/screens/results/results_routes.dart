import 'package:shortest_path/domain/entities/task_result.dart';

/// Navigation actions available from the Result list screen.
abstract interface class ResultsRoutes {
  /// Opens the Preview screen for one [result].
  void toPreview(TaskResult result);
}
