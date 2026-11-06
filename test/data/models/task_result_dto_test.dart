import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shortest_path/data/models/task_result_dto.dart';
import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/entities/task_result.dart';

void main() {
  const task1 = Task(
    id: '7d785c38-cd54-4a98-ab57-44e50ae646c1',
    field: ['.X.', '.X.', '...'],
    start: Point(2, 1),
    end: Point(0, 2),
  );
  const task2 = Task(
    id: '88746d24-bf68-4dea-a6b6-4a8fefb47eb9',
    field: ['XXX.', 'X..X', 'X..X', '.XXX'],
    start: Point(0, 3),
    end: Point(3, 0),
  );

  Map<String, Object> toJson(TaskResult result) =>
      TaskResultDto.fromEntity(result).toJson();

  test('POST body for the server tasks matches the accepted reference', () {
    // Sent by hand to https://flutter.webspark.dev/flutter/api on 2026-11-05
    // for the two tasks its GET returned; the server answered `correct: true`
    // for both.
    const referenceBody = '''
[
  {
    "id": "7d785c38-cd54-4a98-ab57-44e50ae646c1",
    "result": {
      "steps": [{"x":"2","y":"1"},{"x":"1","y":"2"},{"x":"0","y":"2"}],
      "path": "(2,1)->(1,2)->(0,2)"
    }
  },
  {
    "id": "88746d24-bf68-4dea-a6b6-4a8fefb47eb9",
    "result": {
      "steps": [{"x":"0","y":"3"},{"x":"1","y":"2"},{"x":"2","y":"1"},{"x":"3","y":"0"}],
      "path": "(0,3)->(1,2)->(2,1)->(3,0)"
    }
  }
]''';
    const results = [
      TaskResult(task: task1, path: [Point(2, 1), Point(1, 2), Point(0, 2)]),
      TaskResult(
        task: task2,
        path: [Point(0, 3), Point(1, 2), Point(2, 1), Point(3, 0)],
      ),
    ];

    // `equals` compares the decoded JSON deeply, so a coordinate sent as
    // the number 2 instead of the string "2" fails the test.
    expect(results.map(toJson).toList(), jsonDecode(referenceBody));
  });

  test('no path: empty steps and empty path string', () {
    const endBlocked = Task(
      id: 'no-path',
      field: ['..', '.X'],
      start: Point(0, 0),
      end: Point(1, 1),
    );
    const result = TaskResult(task: endBlocked, path: null);

    expect(toJson(result), {
      'id': endBlocked.id,
      'result': {'steps': <Object>[], 'path': ''},
    });
  });

  test('start equals end: one step', () {
    const sameCell = Task(
      id: 'same-cell',
      field: ['..', '..'],
      start: Point(1, 0),
      end: Point(1, 0),
    );
    const result = TaskResult(task: sameCell, path: [Point(1, 0)]);

    expect(toJson(result), {
      'id': sameCell.id,
      'result': {
        'steps': [
          {'x': '1', 'y': '0'},
        ],
        'path': '(1,0)',
      },
    });
  });
}
