import 'package:equatable/equatable.dart';
import 'package:shortest_path/domain/entities/point.dart';

/// A shortest-path task received from the API.
final class Task extends Equatable {
  const Task({
    required this.id,
    required this.field,
    required this.start,
    required this.end,
  });

  /// Server id of the task; the result is sent back with it.
  final String id;

  /// Grid rows from top to bottom: `field[y][x]` is one cell,
  /// `.` is free and `X` is blocked.
  final List<String> field;

  final Point start;
  final Point end;

  @override
  List<Object?> get props => [id, field, start, end];
}
