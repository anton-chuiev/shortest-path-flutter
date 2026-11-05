import 'package:equatable/equatable.dart';

/// A cell position on a task grid.
///
/// [x] is the column (left to right), [y] is the row (top to bottom);
/// `(0, 0)` is the top-left cell.
final class Point extends Equatable {
  const Point(this.x, this.y);

  final int x;
  final int y;

  @override
  List<Object?> get props => [x, y];
}
