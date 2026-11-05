import 'package:shortest_path/domain/entities/point.dart';

/// Formats [path] as `(x,y)->(x,y)`: the format of `result.path` in the API.
///
/// The UI shows paths in the same format, so there is one formatter for both.
/// An empty path gives an empty string.
String formatPath(List<Point> path) =>
    path.map((point) => '(${point.x},${point.y})').join('->');
