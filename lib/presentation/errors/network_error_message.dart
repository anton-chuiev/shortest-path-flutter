import 'package:shortest_path/core/network/network_exception.dart';

/// Text shown to the user when a request fails.
///
/// Returns `null` for [RequestCancelledException]: the request was cancelled
/// on purpose (the screen was closed), so there is nothing to show.
String? networkErrorMessage(NetworkException exception) => switch (exception) {
  // Covers both "no network" and "no such host": they can't be told apart
  // reliably, so the text points at both causes.
  ConnectionException() =>
    'Could not connect to the server. Check the URL and your internet '
        'connection.',
  RequestTimeoutException() => 'Request timed out',
  InvalidResponseException() => 'Unexpected server response',
  // The server's own text is meant for the user (e.g. rate limit, validation).
  ServerException(:final message) when message.trim().isNotEmpty => message,
  ServerException(:final statusCode) => 'Server error (HTTP $statusCode)',
  RequestCancelledException() => null,
};
