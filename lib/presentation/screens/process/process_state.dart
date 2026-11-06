import 'package:equatable/equatable.dart';
import 'package:shortest_path/domain/entities/task_result.dart';

sealed class ProcessState extends Equatable {
  const ProcessState();

  @override
  List<Object?> get props => const [];
}

/// Tasks are being solved: [done] of [total] are finished.
final class ProcessCalculating extends ProcessState {
  const ProcessCalculating({required this.done, required this.total});

  final int done;
  final int total;

  /// Share of solved tasks, from 0 to 1.
  double get progress => total == 0 ? 1.0 : done / total;

  @override
  List<Object?> get props => [done, total];
}

/// Every task is solved; the results can be sent to the server.
///
/// The subclasses tell what happens with the [results] next.
sealed class ProcessFinished extends ProcessState {
  const ProcessFinished(this.results);

  /// One result per task, in the order the tasks came from the server.
  final List<TaskResult> results;

  @override
  List<Object?> get props => [results];
}

/// Results are ready and not being sent.
final class ProcessCalculated extends ProcessFinished {
  const ProcessCalculated(super.results);
}

/// Results are being sent; the button is disabled and shows a loader.
final class ProcessSending extends ProcessFinished {
  const ProcessSending(super.results);
}

/// Sending failed; [message] is shown in an error dialog and the results
/// can be sent again.
final class ProcessSendError extends ProcessFinished {
  const ProcessSendError(super.results, {required this.message});

  final String message;

  @override
  List<Object?> get props => [results, message];
}

/// Results are sent: the page opens the Result list screen.
///
/// The screen then looks the same as [ProcessCalculated], so after coming
/// back the results can be sent again.
final class ProcessSent extends ProcessFinished {
  const ProcessSent(super.results);
}
