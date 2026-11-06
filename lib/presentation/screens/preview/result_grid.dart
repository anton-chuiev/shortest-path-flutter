import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shortest_path/domain/entities/point.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/presentation/common/theme/app_colors.dart';
import 'package:shortest_path/presentation/screens/preview/cell_type_resolver.dart';

/// Square grid of [result]: cells colored by their [CellType], with the
/// `(x,y)` coordinates inside every cell.
///
/// Fills the square it is given. A grid with more than 4 cells per side can
/// be zoomed in and panned.
///
/// Painted in two layers. Cells and lines are painted once. Coordinates are
/// painted only for the cells on screen, and only once they are large enough
/// to read: a 99×99 grid does not lay out 9801 labels before it is shown,
/// its labels appear as it is zoomed in.
class ResultGrid extends StatefulWidget {
  const ResultGrid({super.key, required this.result});

  final TaskResult result;

  @override
  State<ResultGrid> createState() => _ResultGridState();
}

class _ResultGridState extends State<ResultGrid> {
  /// Cells across the width at the maximum zoom: the mockup shows a 4×4
  /// grid, so a cell is never zoomed in beyond its size on the mockup.
  static const int _cellsAcrossAtMaxZoom = 4;

  /// Current zoom and pan; the labels layer repaints when it changes.
  final TransformationController _transformation = TransformationController();

  /// Labels laid out on earlier frames, reused while their cells stay on
  /// screen.
  final _LabelCache _labels = _LabelCache();

  late CellTypeResolver _cells;

  @override
  void initState() {
    super.initState();
    _cells = CellTypeResolver(widget.result);
  }

  @override
  void didUpdateWidget(ResultGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != widget.result) {
      _cells = CellTypeResolver(widget.result);
      _labels.clear();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The label style comes from the theme: labels cached with the old
    // style must not be reused.
    _labels.clear();
  }

  @override
  void dispose() {
    _transformation.dispose();
    _labels.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellsPerSide = widget.result.task.field.length;
    final maxScale = cellsPerSide / _cellsAcrossAtMaxZoom;

    final Widget grid = Stack(
      fit: StackFit.expand,
      children: [
        // Painted once: zooming and panning only transform this layer.
        RepaintBoundary(
          child: CustomPaint(
            painter: _CellsPainter(cells: _cells, cellsPerSide: cellsPerSide),
          ),
        ),
        // Repainted on every zoom or pan step, without the cells layer.
        RepaintBoundary(
          child: CustomPaint(
            painter: _LabelsPainter(
              cells: _cells,
              cellsPerSide: cellsPerSide,
              labelStyle:
                  Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
              transformation: _transformation,
              cache: _labels,
            ),
          ),
        ),
      ],
    );

    return AspectRatio(
      aspectRatio: 1,
      // A small grid is not wrapped at all: zooming would add nothing, and
      // the viewer's gestures could compete with the iOS back swipe. Its
      // transformation then stays the identity.
      child: maxScale > 1
          ? InteractiveViewer(
              transformationController: _transformation,
              minScale: 1,
              maxScale: maxScale,
              child: grid,
            )
          : grid,
    );
  }
}

/// Paints the cell colors and the thin lines between the cells.
class _CellsPainter extends CustomPainter {
  _CellsPainter({required this.cells, required this.cellsPerSide});

  final CellTypeResolver cells;
  final int cellsPerSide;

  @override
  void paint(Canvas canvas, Size size) {
    final n = cellsPerSide;
    final cellSize = size.width / n;
    final fill = Paint();
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        canvas.drawRect(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
          fill..color = cells.typeAt(Point(x, y)).color,
        );
      }
    }

    // Width 0 is a "hairline": one physical pixel at any zoom level.
    final line = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 0;
    for (var i = 0; i <= n; i++) {
      final offset = i * cellSize;
      canvas
        ..drawLine(Offset(offset, 0), Offset(offset, size.height), line)
        ..drawLine(Offset(0, offset), Offset(size.width, offset), line);
    }
  }

  /// A new resolver is made only for a new result.
  @override
  bool shouldRepaint(_CellsPainter oldDelegate) =>
      oldDelegate.cells != cells || oldDelegate.cellsPerSide != cellsPerSide;
}

/// Paints the `(x,y)` coordinates of the cells that are on screen and large
/// enough to read at the current zoom.
class _LabelsPainter extends CustomPainter {
  _LabelsPainter({
    required this.cells,
    required this.cellsPerSide,
    required this.labelStyle,
    required this.transformation,
    required this.cache,
  }) : _darkStyle = _labelStyleOf(labelStyle, AppColors.onCell),
       _lightStyle = _labelStyleOf(labelStyle, AppColors.onBlockedCell),
       super(repaint: transformation);

  final CellTypeResolver cells;
  final int cellsPerSide;

  /// Base style of the coordinates (from the theme); a label that does not
  /// fit a cell is scaled down as a whole.
  final TextStyle labelStyle;

  /// Zoom and pan of the grid; a change repaints the labels.
  final TransformationController transformation;

  final _LabelCache cache;

  // Two styles for all labels, made once instead of one per cell.
  final TextStyle _darkStyle;
  final TextStyle _lightStyle;

  /// Share of a cell's width the longest label may take.
  static const double _labelWidthFactor = 0.8;

  /// Labels smaller than this on screen (logical pixels) are not painted:
  /// they could not be read anyway.
  static const double _minReadableFontSize = 4;

  /// Font size of a style that does not set one.
  static const double _defaultFontSize = 14;

  /// Width of the longest label, `(n-1,n-1)`, in the base style; measured
  /// once per painter, not on every zoom step.
  late final double _widestLabelWidth = _measureWidth(
    '(${cellsPerSide - 1},${cellsPerSide - 1})',
  );

  /// [base] with [color] and digits of equal width ("tabular figures").
  ///
  /// With equal-width digits the last cell's label `(n-1,n-1)` is surely the
  /// widest one, which [_widestLabelWidth] relies on. The iOS system font
  /// has digits of different widths by default; Roboto on Android does not.
  static TextStyle _labelStyleOf(TextStyle base, Color color) => base.copyWith(
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final n = cellsPerSide;
    final cellSize = size.width / n;
    final matrix = transformation.value;

    // Labels are scaled on the canvas instead of getting a smaller font
    // size: the theme style has a fixed letter spacing, which would not
    // shrink with the font and would push the characters apart.
    final labelScale = math.min(
      1.0,
      cellSize * _labelWidthFactor / _widestLabelWidth,
    );
    final fontSize = labelStyle.fontSize ?? _defaultFontSize;
    final onScreenFontSize = fontSize * labelScale * matrix.getMaxScaleOnAxis();
    if (onScreenFontSize < _minReadableFontSize) {
      cache.clear();
      return;
    }

    // The part of the grid on screen, in grid coordinates.
    final visible = MatrixUtils.inverseTransformRect(
      matrix,
      Offset.zero & size,
    );
    final firstX = _cellIndex(visible.left, cellSize, n);
    final lastX = _cellIndex(visible.right, cellSize, n);
    final firstY = _cellIndex(visible.top, cellSize, n);
    final lastY = _cellIndex(visible.bottom, cellSize, n);

    for (var y = firstY; y <= lastY; y++) {
      for (var x = firstX; x <= lastX; x++) {
        final point = Point(x, y);
        final label = cache.putIfAbsent(
          point,
          () => _layOut(
            '($x,$y)',
            // Dark text would be hidden on the black blocked cell.
            cells.typeAt(point) == CellType.blocked ? _lightStyle : _darkStyle,
          ),
        );
        canvas
          ..save()
          ..translate((x + 0.5) * cellSize, (y + 0.5) * cellSize)
          ..scale(labelScale);
        label.paint(canvas, Offset(-label.width / 2, -label.height / 2));
        canvas.restore();
      }
    }

    // Labels of the cells that left the screen are not needed any more.
    cache.retainWhere(
      (point) =>
          point.x >= firstX &&
          point.x <= lastX &&
          point.y >= firstY &&
          point.y <= lastY,
    );
  }

  /// Index of the cell containing [offset], clamped to the grid.
  static int _cellIndex(double offset, double cellSize, int n) =>
      math.max(0, math.min(n - 1, (offset / cellSize).floor()));

  double _measureWidth(String text) {
    final painter = _layOut(text, _darkStyle);
    final width = painter.width;
    painter.dispose();
    return width;
  }

  /// The label size follows the cell, not the system font size: a larger
  /// font would not fit a cell; the grid can be zoomed instead.
  static TextPainter _layOut(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();

  /// Zoom and pan repaint through `repaint: transformation`; a new painter
  /// repaints only when its data changed.
  @override
  bool shouldRepaint(_LabelsPainter oldDelegate) =>
      oldDelegate.cells != cells ||
      oldDelegate.cellsPerSide != cellsPerSide ||
      oldDelegate.labelStyle != labelStyle ||
      oldDelegate.transformation != transformation ||
      oldDelegate.cache != cache;
}

/// Laid-out labels by cell, owned by the grid's state.
///
/// Laying out text is the costly part of painting the labels; a label is
/// laid out once and reused while its cell stays on screen.
final class _LabelCache {
  final Map<Point, TextPainter> _labels = {};

  TextPainter putIfAbsent(Point point, TextPainter Function() layOut) =>
      _labels.putIfAbsent(point, layOut);

  /// Drops (and frees) the labels of the cells [keep] returns false for.
  void retainWhere(bool Function(Point point) keep) {
    _labels.removeWhere((point, label) {
      if (keep(point)) return false;
      label.dispose();
      return true;
    });
  }

  /// Drops (and frees) all labels.
  void clear() {
    for (final label in _labels.values) {
      label.dispose();
    }
    _labels.clear();
  }
}

/// Cell colors, given in the task description.
extension on CellType {
  Color get color => switch (this) {
    CellType.start => AppColors.startCell,
    CellType.end => AppColors.endCell,
    CellType.blocked => AppColors.blockedCell,
    CellType.path => AppColors.pathCell,
    CellType.empty => AppColors.emptyCell,
  };
}
