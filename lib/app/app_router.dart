import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shortest_path/presentation/home/home_routes.dart';
import 'package:shortest_path/presentation/preview/preview_page.dart';
import 'package:shortest_path/presentation/process/process_page.dart';
import 'package:shortest_path/presentation/process/process_routes.dart';
import 'package:shortest_path/presentation/results/results_page.dart';
import 'package:shortest_path/presentation/results/results_routes.dart';

/// Single place that knows how screens are connected.
///
/// Each page depends only on its own routes interface; this class
/// implements all of them. It drives the app's [Navigator] through
/// [navigatorKey], so callers don't need a [BuildContext].
class AppRouter implements HomeRoutes, ProcessRoutes, ResultsRoutes {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void toProcess() => _push(ProcessPage(routes: this));

  @override
  void toResults() => _push(ResultsPage(routes: this));

  @override
  void toPreview() => _push(const PreviewPage());

  void _push(Widget page) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw StateError('AppRouter.navigatorKey is not attached to a Navigator');
    }
    // The returned Future completes when the page is popped; nobody awaits
    // a result from these screens, so it is intentionally not awaited.
    unawaited(navigator.push(MaterialPageRoute<void>(builder: (_) => page)));
  }
}
