import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/core/network/cancellation_token.dart';
import 'package:shortest_path/core/network/network_exception.dart';
import 'package:shortest_path/domain/entities/grid.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/domain/pathfinding/path_finder.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';
import 'package:shortest_path/presentation/common/errors/network_error_message.dart';
import 'package:shortest_path/presentation/screens/process/process_state.dart';

/// Logic of the Process screen: solves the tasks, reporting progress, and
/// sends the results to the URL the tasks came from.
///
/// Closing the cubit (leaving the screen) stops the calculation and cancels
/// a request in flight.
class ProcessCubit extends Cubit<ProcessState> {
  /// Callers pass `repository:`, `url:` and `pathFinder:` — for a private
  /// named parameter Dart drops the underscore from the argument name.
  ProcessCubit({
    required this._repository,
    required this._url,
    required List<Task> tasks,
    this._pathFinder = const PathFinder(),
  }) : _tasks = List.unmodifiable(tasks),
       super(ProcessCalculating(done: 0, total: tasks.length));

  static const String _calculationErrorMessage =
      'Could not calculate the results';

  final TasksRepository _repository;
  final Uri _url;
  final List<Task> _tasks;
  final PathFinder _pathFinder;

  bool _isCalculationStarted = false;

  /// Token of the request in flight, cancelled in [close].
  CancellationToken? _sendCancellationToken;

  /// Solves the tasks one by one, updating the progress after each.
  ///
  /// Call it once, right after creating the cubit; later calls do nothing.
  Future<void> calculate() async {
    if (_isCalculationStarted) {
      return;
    }
    _isCalculationStarted = true;

    final results = <TaskResult>[];
    for (final task in _tasks) {
      final TaskResult result;
      try {
        result = await _solveInBackground(task, _pathFinder);
      } catch (error, stackTrace) {
        // Only malformed task data can get here (e.g. a row shorter than
        // the others). Everything is caught: such data fails with an Error
        // (RangeError), not an Exception.
        if (isClosed) {
          return;
        }
        developer.log(
          'Failed to solve task ${task.id}',
          name: 'ProcessCubit',
          error: error,
          stackTrace: stackTrace,
        );
        emit(
          ProcessCalculationError(
            _calculationErrorMessage,
            progress: results.length / _tasks.length,
          ),
        );
        return;
      }
      // The screen was closed while the task was being solved.
      if (isClosed) {
        return;
      }
      results.add(result);
      if (results.length < _tasks.length) {
        emit(ProcessCalculating(done: results.length, total: _tasks.length));
      }
    }
    emit(ProcessCalculated(List.unmodifiable(results)));
  }

  /// Sends the results; ignored until the calculation has finished and
  /// while a previous send is in flight.
  Future<void> send() async {
    final results = switch (state) {
      // The button is disabled in these states; this also covers a fast
      // double tap.
      ProcessCalculating() || ProcessSending() => null,
      // Nothing to send.
      ProcessCalculationError() => null,
      ProcessFinished(:final results) => results,
    };
    if (results == null) {
      return;
    }

    final cancellationToken = CancellationToken();
    _sendCancellationToken = cancellationToken;
    emit(ProcessSending(results));
    try {
      final checks = await _repository.submitResults(
        _url,
        results,
        cancellationToken: cancellationToken,
      );
      // Not shown in the UI (not in the task), but handy for checking the
      // algorithm: visible in the debug console and DevTools.
      final correctCount = checks.where((check) => check.correct).length;
      developer.log(
        'Server accepted $correctCount of ${checks.length} results as correct',
        name: 'ProcessCubit',
      );
      emit(ProcessSent(results));
    } on NetworkException catch (exception) {
      // `null` for a cancelled request: the cubit is closed, nothing to show.
      final message = networkErrorMessage(exception);
      if (message != null) {
        emit(ProcessSendError(results, message: message));
      }
    } finally {
      _sendCancellationToken = null;
    }
  }

  @override
  Future<void> close() {
    _sendCancellationToken?.cancel();
    return super.close();
  }

  /// Solves [task] on a separate isolate, so a large grid never freezes
  /// the UI.
  ///
  /// Static on purpose: a closure created in an instance method may capture
  /// `this`, and the cubit (with its stream controller) cannot be sent to
  /// another isolate.
  static Future<TaskResult> _solveInBackground(
    Task task,
    PathFinder pathFinder,
  ) {
    return Isolate.run(
      () => TaskResult(
        task: task,
        path: pathFinder.findPath(
          Grid(task.field),
          start: task.start,
          end: task.end,
        ),
      ),
    );
  }
}
