import 'package:shortest_path/domain/entities/point.dart';

/// JSON form of a grid position: `{"x": 2, "y": 1}`.
///
/// In GET responses the coordinates are numbers.
final class PointDto {
  const PointDto({required this.x, required this.y});

  /// Throws [FormatException] when [json] is not a point.
  factory PointDto.fromJson(Object? json) => switch (json) {
    {'x': final int x, 'y': final int y} => PointDto(x: x, y: y),
    _ => throw FormatException('Not a point: $json'),
  };

  final int x;
  final int y;

  Point toEntity() => Point(x, y);
}
