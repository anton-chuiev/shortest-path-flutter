import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/domain/pathfinding/path_formatter.dart';

/// Text shown for [result] on the Result list and Preview screens:
/// the path as `(x,y)->(x,y)`, or `No path found` when there is none.
String resultPathText(TaskResult result) => switch (result.path) {
  final path? => formatPath(path),
  null => 'No path found',
};
