import 'package:equatable/equatable.dart';
import 'package:shortest_path/domain/entities/task.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => const [];
}

/// Waiting for the user to submit a URL.
final class HomeIdle extends HomeState {
  const HomeIdle();
}

/// The typed URL is not valid; [message] is shown under the text field.
final class HomeInvalid extends HomeState {
  const HomeInvalid(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Tasks are being loaded; input and the button are disabled.
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Loading failed; [message] is shown in an error dialog.
final class HomeLoadError extends HomeState {
  const HomeLoadError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Tasks are loaded: the page opens the Process screen.
///
/// The screen then looks the same as [HomeIdle]; the next submit starts over.
final class HomeLoaded extends HomeState {
  const HomeLoaded({required this.url, required this.tasks});

  /// The URL the tasks came from; results are sent to it too.
  final Uri url;
  final List<Task> tasks;

  @override
  List<Object?> get props => [url, tasks];
}
