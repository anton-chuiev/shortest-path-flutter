import 'dart:collection';

import 'package:shortest_path/domain/entities/grid.dart';
import 'package:shortest_path/domain/entities/point.dart';

/// Finds a shortest path on a [Grid] with breadth-first search (BFS).
///
/// One move goes to an adjacent free cell in any of the 8 directions, and
/// every move costs the same. BFS reaches cells in order of their distance
/// from the start, so the first time it reaches the end, it does so along a
/// shortest path. When several shortest paths exist, any one is returned.
final class PathFinder {
  const PathFinder();

  /// Returns the cells from [start] to [end], both included, or `null` when
  /// [end] is unreachable or [start] / [end] is a blocked cell.
  ///
  /// When [start] equals [end], the path is that single cell.
  List<Point>? findPath(Grid grid, {required Point start, required Point end}) {
    if (grid.isBlocked(start) || grid.isBlocked(end)) {
      return null;
    }

    // Every reached cell → the cell it was reached from (`null` for start).
    // Its keys double as the set of visited cells.
    final cameFrom = <Point, Point?>{start: null};
    final queue = Queue<Point>.of([start]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == end) {
        return _buildPath(cameFrom, end);
      }
      for (final next in grid.neighbours(current)) {
        if (!cameFrom.containsKey(next)) {
          cameFrom[next] = current;
          queue.add(next);
        }
      }
    }
    return null;
  }

  /// Walks back from [end] to the start and returns the path start-first.
  static List<Point> _buildPath(Map<Point, Point?> cameFrom, Point end) {
    final reversedPath = <Point>[];
    for (Point? cell = end; cell != null; cell = cameFrom[cell]) {
      reversedPath.add(cell);
    }
    return List.unmodifiable(reversedPath.reversed);
  }
}
