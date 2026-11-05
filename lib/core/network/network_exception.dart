import 'package:equatable/equatable.dart';

/// Every way a request to the API can fail.
///
/// The class is sealed, so a `switch` over a [NetworkException] must handle
/// every subtype: adding a new one makes the compiler point at each place
/// that has to deal with it.
///
/// Exceptions compare by value (see [props]), so tests can expect a concrete
/// one, e.g. `throwsA(const ServerException(statusCode: 500, message: ''))`.
/// Debug-only details (`cause`, `reason`) are left out of the comparison.
sealed class NetworkException extends Equatable implements Exception {
  const NetworkException();

  @override
  List<Object?> get props => const [];
}

/// The server could not be reached: no internet, DNS failure, refused
/// connection, TLS handshake error, connection dropped mid-response.
final class ConnectionException extends NetworkException {
  const ConnectionException(this.cause);

  /// The underlying error, kept for debugging. Not meant for the user.
  final Object cause;

  @override
  String toString() => 'ConnectionException: $cause';
}

/// No complete response arrived within the client's time limit.
final class RequestTimeoutException extends NetworkException {
  const RequestTimeoutException(this.timeout);

  final Duration timeout;

  @override
  List<Object?> get props => [timeout];

  @override
  String toString() => 'RequestTimeoutException: no response in $timeout';
}

/// The server answered with an error envelope: `error: true` or a non-2xx
/// HTTP status (for example 429 or 500).
final class ServerException extends NetworkException {
  const ServerException({required this.statusCode, required this.message});

  final int statusCode;

  /// Text from the server, intended to be shown to the user. May be empty.
  final String message;

  @override
  List<Object?> get props => [statusCode, message];

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// The response is not the API's JSON envelope, for example an HTML page
/// of an unrelated site.
final class InvalidResponseException extends NetworkException {
  const InvalidResponseException(this.reason);

  /// What exactly was wrong, kept for debugging. Not meant for the user.
  final String reason;

  @override
  String toString() => 'InvalidResponseException: $reason';
}

/// The request was cancelled through its CancellationToken.
///
/// This is not a failure from the user's point of view: callers should
/// ignore it rather than show an error.
final class RequestCancelledException extends NetworkException {
  const RequestCancelledException();

  @override
  String toString() => 'RequestCancelledException';
}
