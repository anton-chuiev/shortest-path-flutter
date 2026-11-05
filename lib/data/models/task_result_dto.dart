import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/domain/pathfinding/path_formatter.dart';

/// JSON form of a task result in the POST body:
///
/// ```json
/// {"id": "...", "result": {"steps": [{"x": "2", "y": "1"}], "path": "(2,1)"}}
/// ```
///
/// Unlike in GET, coordinates are strings here. A task without a path is
/// sent with `"steps": []` and `"path": ""`, as the API schema allows.
final class TaskResultDto {
  const TaskResultDto({
    required this.id,
    required this.steps,
    required this.path,
  });

  factory TaskResultDto.fromEntity(TaskResult result) {
    final steps = result.path ?? const <Point>[];
    return TaskResultDto(
      id: result.task.id,
      steps: steps,
      path: formatPath(steps),
    );
  }

  final String id;
  final List<Point> steps;
  final String path;

  Map<String, Object> toJson() => {
    'id': id,
    'result': {
      'steps': [
        for (final step in steps) {'x': '${step.x}', 'y': '${step.y}'},
      ],
      'path': path,
    },
  };
}
