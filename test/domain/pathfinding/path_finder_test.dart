import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shortest_path/domain/entities/grid.dart';
import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/pathfinding/path_finder.dart';

void main() {
  const pathFinder = PathFinder();

  List<Point>? findPath(
    List<String> rows, {
    required Point start,
    required Point end,
  }) => pathFinder.findPath(Grid(rows), start: start, end: end);

  group('known tasks with a single shortest path', () {
    test('example from the task description', () {
      final path = findPath(
        const ['.X.', '.X.', '...'],
        start: const Point(1, 2),
        end: const Point(2, 0),
      );

      expect(path, const [Point(1, 2), Point(2, 1), Point(2, 0)]);
    });

    test('server task 1: passes a blocked cell diagonally', () {
      final path = findPath(
        const ['.X.', '.X.', '...'],
        start: const Point(2, 1),
        end: const Point(0, 2),
      );

      expect(path, const [Point(2, 1), Point(1, 2), Point(0, 2)]);
    });

    test('server task 2: reachable only by diagonal moves', () {
      final path = findPath(
        const ['XXX.', 'X..X', 'X..X', '.XXX'],
        start: const Point(0, 3),
        end: const Point(3, 0),
      );

      expect(path, const [Point(0, 3), Point(1, 2), Point(2, 1), Point(3, 0)]);
    });
  });

  test('cuts the corner between two blocked cells', () {
    final path = findPath(
      const ['.X', 'X.'],
      start: const Point(0, 0),
      end: const Point(1, 1),
    );

    expect(path, const [Point(0, 0), Point(1, 1)]);
  });

  group('edge cases', () {
    test('start equals end: the path is that single cell', () {
      final path = findPath(
        const ['..', '..'],
        start: const Point(1, 0),
        end: const Point(1, 0),
      );

      expect(path, const [Point(1, 0)]);
    });

    test('start on a blocked cell: no path', () {
      final path = findPath(
        const ['X.', '..'],
        start: const Point(0, 0),
        end: const Point(1, 1),
      );

      expect(path, isNull);
    });

    test('end on a blocked cell: no path', () {
      final path = findPath(
        const ['..', '.X'],
        start: const Point(0, 0),
        end: const Point(1, 1),
      );

      expect(path, isNull);
    });

    test('start equals end on a blocked cell: no path', () {
      final path = findPath(
        const ['X.', '..'],
        start: const Point(0, 0),
        end: const Point(0, 0),
      );

      expect(path, isNull);
    });

    test('end is walled off: no path', () {
      final path = findPath(
        const ['.X.', 'XX.', '...'],
        start: const Point(2, 2),
        end: const Point(0, 0),
      );

      expect(path, isNull);
    });
  });

  group('several shortest paths: any valid one of minimal length', () {
    test('open grid', () {
      const rows = ['...', '...', '...'];
      const start = Point(0, 0);
      const end = Point(2, 0);

      final path = findPath(rows, start: start, end: end);

      expectValidPath(path, rows: rows, start: start, end: end);
      expect(path, hasLength(3));
    });

    test('detour around a wall', () {
      // The only way through column 1 is the bottom cell (1,3).
      const rows = ['.X..', '.X..', '.X..', '....'];
      const start = Point(0, 0);
      const end = Point(2, 0);

      final path = findPath(rows, start: start, end: end);

      expectValidPath(path, rows: rows, start: start, end: end);
      expect(path, hasLength(7));
    });
  });

  test('99x99 grid: walled-off end in the far corner, no path', () {
    // (98,98) is surrounded by blocked (97,97), (98,97) and (97,98), so BFS
    // has to visit every other cell before giving up.
    final rows = List.filled(99, '.' * 99)
      ..[97] = '${'.' * 97}XX'
      ..[98] = '${'.' * 97}X.';

    final path = findPath(
      rows,
      start: const Point(0, 0),
      end: const Point(98, 98),
    );

    expect(path, isNull);
  });

  group('99x99 grid without blocked cells', () {
    // With 8 directions and no obstacles the minimal number of moves is
    // max(|dx|, |dy|), so the path has one cell more.
    final rows = List.filled(99, '.' * 99);

    for (final (start, end) in const [
      (Point(0, 0), Point(98, 98)),
      (Point(98, 0), Point(0, 98)),
      (Point(50, 50), Point(50, 0)),
      (Point(10, 70), Point(90, 5)),
    ]) {
      test('from (${start.x},${start.y}) to (${end.x},${end.y})', () {
        final path = findPath(rows, start: start, end: end);

        final dx = (end.x - start.x).abs();
        final dy = (end.y - start.y).abs();
        expectValidPath(path, rows: rows, start: start, end: end);
        expect(path, hasLength(max(dx, dy) + 1));
      });
    }
  });
}

/// Checks that [path] goes from [start] to [end] over free cells of [rows],
/// one move (to any of the 8 adjacent cells) at a time.
///
/// Reads [rows] directly rather than through `Grid`, so the check does not
/// depend on the code under test.
void expectValidPath(
  List<Point>? path, {
  required List<String> rows,
  required Point start,
  required Point end,
}) {
  expect(path, isNotNull, reason: 'a path exists');
  final cells = path!;
  expect(cells.first, start, reason: 'starts at start');
  expect(cells.last, end, reason: 'ends at end');

  for (final cell in cells) {
    final inside =
        cell.y >= 0 &&
        cell.y < rows.length &&
        cell.x >= 0 &&
        cell.x < rows[cell.y].length;
    expect(inside, isTrue, reason: '(${cell.x},${cell.y}) is inside the grid');
    expect(
      rows[cell.y][cell.x],
      '.',
      reason: '(${cell.x},${cell.y}) is not blocked',
    );
  }

  for (var i = 1; i < cells.length; i++) {
    final dx = (cells[i].x - cells[i - 1].x).abs();
    final dy = (cells[i].y - cells[i - 1].y).abs();
    expect(
      dx <= 1 && dy <= 1 && (dx + dy) > 0,
      isTrue,
      reason: 'step $i moves to an adjacent cell',
    );
  }
}
