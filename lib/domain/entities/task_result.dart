import 'package:equatable/equatable.dart';
import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/entities/task.dart';

/// Outcome of solving one [Task].
final class TaskResult extends Equatable {
  const TaskResult({required this.task, required this.path});

  final Task task;

  /// Cells from `task.start` to `task.end`, both included;
  /// `null` when there is no path.
  final List<Point>? path;

  @override
  List<Object?> get props => [task, path];
}
