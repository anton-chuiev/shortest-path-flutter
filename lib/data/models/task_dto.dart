import 'package:shortest_path/data/models/point_dto.dart';
import 'package:shortest_path/domain/entities/task.dart';

/// JSON form of a task in the GET response:
///
/// ```json
/// {"id": "...", "field": [".X.", "..."], "start": {...}, "end": {...}}
/// ```
final class TaskDto {
  const TaskDto({
    required this.id,
    required this.field,
    required this.start,
    required this.end,
  });

  /// Throws [FormatException] when [json] is not a task.
  factory TaskDto.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'field': final List<Object?> field,
      'start': final Object? start,
      'end': final Object? end,
    } =>
      TaskDto(
        id: id,
        field: _parseRows(field),
        start: PointDto.fromJson(start),
        end: PointDto.fromJson(end),
      ),
    _ => throw FormatException('Not a task: $json'),
  };

  final String id;
  final List<String> field;
  final PointDto start;
  final PointDto end;

  Task toEntity() =>
      Task(id: id, field: field, start: start.toEntity(), end: end.toEntity());

  /// Checks every row eagerly, so a bad row fails here, inside the decoder,
  /// and not later when the grid is read.
  static List<String> _parseRows(List<Object?> rows) => List.unmodifiable([
    for (final row in rows)
      row is String ? row : throw FormatException('Not a grid row: $row'),
  ]);
}
