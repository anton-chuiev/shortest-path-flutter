import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/presentation/common/theme/app_colors.dart';
import 'package:shortest_path/presentation/common/theme/app_dimens.dart';
import 'package:shortest_path/presentation/common/widgets/bottom_action_button.dart';
import 'package:shortest_path/presentation/common/widgets/error_dialog.dart';
import 'package:shortest_path/presentation/screens/process/process_cubit.dart';
import 'package:shortest_path/presentation/screens/process/process_routes.dart';
import 'package:shortest_path/presentation/screens/process/process_state.dart';

/// Screen 1.2: shows the calculation progress and sends the results.
///
/// Expects a [ProcessCubit] above it in the tree.
class ProcessPage extends StatelessWidget {
  const ProcessPage({super.key, required this.routes});

  final ProcessRoutes routes;

  static const double _indicatorSize = 120;
  static const double _indicatorStrokeWidth = 3;

  // Wording is taken from the mockup as is.
  static const String _finishedText =
      'All calculations has finished, you can send your results to server';

  /// One-off reactions to state changes; the UI itself is built in `builder`.
  void _onStateChanged(BuildContext context, ProcessState state) {
    switch (state) {
      case ProcessCalculationError(:final message) ||
          ProcessSendError(:final message):
        unawaited(showErrorDialog(context, message: message));
      case ProcessSent(:final results):
        routes.toResults(results);
      case ProcessCalculating() || ProcessCalculated() || ProcessSending():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process screen')),
      body: BlocConsumer<ProcessCubit, ProcessState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final (status, progress) = switch (state) {
            ProcessCalculating(:final progress) => ('Calculating...', progress),
            ProcessCalculationError(:final message, :final progress) => (
              message,
              progress,
            ),
            ProcessFinished() => (_finishedText, 1.0),
          };
          final textTheme = Theme.of(context).textTheme;
          return Column(
            children: [
              Expanded(
                child: Center(
                  // Scrolls only when the content does not fit: a small
                  // screen or a large system font size.
                  child: SingleChildScrollView(
                    // Stretched, so the divider spans the whole width,
                    // as on the mockup.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.medium,
                          ),
                          child: _StatusText(
                            status,
                            reserveSpaceFor: _finishedText,
                            style: textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          '${(progress * 100).floor()}%',
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const Divider(
                          height: AppSpacing.medium,
                          color: AppColors.divider,
                        ),
                        Center(
                          child: SizedBox.square(
                            dimension: _indicatorSize,
                            child: CircularProgressIndicator(
                              value: progress,
                              color: AppColors.progressIndicator,
                              strokeWidth: _indicatorStrokeWidth,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Hidden, but still taking its space while calculating: the
              // content above is centered in the remaining height and would
              // jump up when the button appears. Only the size is kept: the
              // hidden button can't be tapped, focused or read by a screen
              // reader (Visibility.maintain would keep all of that too).
              Visibility(
                visible: state is ProcessFinished,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: BottomActionButton(
                  label: 'Send results to server',
                  onPressed: () =>
                      unawaited(context.read<ProcessCubit>().send()),
                  isLoading: state is ProcessSending,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Centered status text that is at least as tall as [reserveSpaceFor].
///
/// The status changes from a short text to a longer one; without the
/// reserved height everything below it would shift down at that moment.
class _StatusText extends StatelessWidget {
  const _StatusText(
    this.text, {
    required this.reserveSpaceFor,
    required this.style,
  });

  final String text;

  /// The longest text this widget shows.
  final String reserveSpaceFor;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Invisible: only sets the height of the Stack. Not read by a screen
        // reader, which would otherwise announce the finished text while
        // the calculation is still running.
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Text(
            reserveSpaceFor,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        Text(text, style: style, textAlign: TextAlign.center),
      ],
    );
  }
}
