import 'dart:async';

/// Lets the owner of a request abort it while it is in flight.
///
/// Typical use: a Cubit creates a token for each request it starts and calls
/// [cancel] in `close()`, so leaving the screen aborts the request.
/// Cancellation is one-way: once cancelled, a token stays cancelled.
class CancellationToken {
  final Completer<void> _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  /// Completes when [cancel] is called; never completes otherwise.
  Future<void> get whenCancelled => _completer.future;

  /// Cancels the token. Calling it again has no effect.
  void cancel() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
