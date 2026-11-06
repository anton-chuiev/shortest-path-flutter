import 'package:flutter_test/flutter_test.dart';
import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/presentation/screens/preview/cell_type_resolver.dart';

void main() {
  /// Types of every cell, one string per row, so an expectation reads like
  /// the grid itself: `S` start, `E` end, `X` blocked, `P` path, `.` empty.
  List<String> typesOf({
    required List<String> field,
    required Point start,
    required Point end,
    required List<Point>? path,
  }) {
    final resolver = CellTypeResolver(
      TaskResult(
        task: Task(id: 'id', field: field, start: start, end: end),
        path: path,
      ),
    );
    return [
      for (var y = 0; y < field.length; y++)
        [
          for (var x = 0; x < field.length; x++)
            switch (resolver.typeAt(Point(x, y))) {
              CellType.start => 'S',
              CellType.end => 'E',
              CellType.blocked => 'X',
              CellType.path => 'P',
              CellType.empty => '.',
            },
        ].join(),
    ];
  }

  test('server task 1: path ends are shown as start and end, not path', () {
    final types = typesOf(
      field: const ['.X.', '.X.', '...'],
      start: const Point(2, 1),
      end: const Point(0, 2),
      path: const [Point(2, 1), Point(1, 2), Point(0, 2)],
    );

    expect(types, ['.X.', '.XS', 'EP.']);
  });

  test('no path: only start, end and blocked cells are marked', () {
    final types = typesOf(
      field: const ['.X.', 'XX.', '...'],
      start: const Point(2, 2),
      end: const Point(0, 0),
      path: null,
    );

    expect(types, ['EX.', 'XX.', '..S']);
  });

  test('start on a blocked cell is shown as start', () {
    final types = typesOf(
      field: const ['X.', '..'],
      start: const Point(0, 0),
      end: const Point(1, 1),
      path: null,
    );

    expect(types, ['S.', '.E']);
  });

  test('end on a blocked cell is shown as end', () {
    final types = typesOf(
      field: const ['..', '.X'],
      start: const Point(0, 0),
      end: const Point(1, 1),
      path: null,
    );

    expect(types, ['S.', '.E']);
  });

  test('start equals end: the cell is shown as start', () {
    final types = typesOf(
      field: const ['..', '..'],
      start: const Point(1, 0),
      end: const Point(1, 0),
      path: const [Point(1, 0)],
    );

    expect(types, ['.S', '..']);
  });

  test('start equals end on a blocked cell: the cell is shown as start', () {
    final types = typesOf(
      field: const ['X.', '..'],
      start: const Point(0, 0),
      end: const Point(0, 0),
      path: null,
    );

    expect(types, ['S.', '..']);
  });
}
