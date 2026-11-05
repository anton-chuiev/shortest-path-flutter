import 'package:shortest_path/domain/entities/point.dart';

/// Square task grid: `.` cells are free, `X` cells are blocked.
///
/// The grid is assumed to be well-formed (square, 2…99 cells per side, only
/// `.` and `X`): the task description guarantees it, so it is not validated.
final class Grid {
  /// Takes the rows from top to bottom: `rows[y][x]` is one cell.
  const Grid(this._rows);

  static const String _blockedCell = 'X';

  /// Offsets `(dx, dy)` of the 8 adjacent cells: rows, columns, diagonals.
  static const List<(int, int)> _directions = [
    (-1, -1),
    (0, -1),
    (1, -1),
    (-1, 0),
    (1, 0),
    (-1, 1),
    (0, 1),
    (1, 1),
  ];

  final List<String> _rows;

  /// Number of cells per side.
  int get size => _rows.length;

  bool contains(Point point) =>
      point.x >= 0 && point.x < size && point.y >= 0 && point.y < size;

  /// [point] must be inside the grid (see [contains]).
  bool isBlocked(Point point) => _rows[point.y][point.x] == _blockedCell;

  /// Free cells one move away from [point], in any of the 8 directions.
  ///
  /// A diagonal move is allowed even between two blocked cells ("cutting the
  /// corner"): the server accepts such paths as correct.
  Iterable<Point> neighbours(Point point) sync* {
    for (final (dx, dy) in _directions) {
      final next = Point(point.x + dx, point.y + dy);
      if (contains(next) && !isBlocked(next)) {
        yield next;
      }
    }
  }
}
