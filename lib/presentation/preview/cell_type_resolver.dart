import 'package:shortest_path/domain/entities/grid.dart';
import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/entities/task_result.dart';

/// What a cell of a solved task's grid is shown as on the Preview screen.
enum CellType { start, end, blocked, path, empty }

/// Tells the [CellType] of every cell of a [TaskResult]'s grid.
///
/// Plain Dart (no Flutter): the priority of the types is a display rule
/// of screen 1.4, so it lives in presentation, next to the grid widget.
final class CellTypeResolver {
  CellTypeResolver(TaskResult result)
    : _grid = Grid(result.task.field),
      _start = result.task.start,
      _end = result.task.end,
      _path = {...?result.path};

  final Grid _grid;
  final Point _start;
  final Point _end;

  /// Cells of the path; a set, so a lookup does not scan the whole path.
  final Set<Point> _path;

  /// Type of the cell at [point], which must be inside the grid.
  ///
  /// When a cell fits several types, the first one in this order wins:
  /// start, end, blocked, path, empty. So a start on a blocked cell is still
  /// shown as the start, and the path's ends are not shown as path cells.
  CellType typeAt(Point point) {
    if (point == _start) return CellType.start;
    if (point == _end) return CellType.end;
    if (_grid.isBlocked(point)) return CellType.blocked;
    if (_path.contains(point)) return CellType.path;
    return CellType.empty;
  }
}
