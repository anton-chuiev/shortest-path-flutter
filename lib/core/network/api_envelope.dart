import 'dart:convert';

import 'package:shortest_path/core/network/network_exception.dart';

/// Unwraps the envelope that wraps every API response, whatever the status:
///
/// ```json
/// { "error": false, "message": "OK", "data": ... }
/// ```
///
/// Returns `data` as decoded JSON (a `List`, `Map`, or primitive); mapping it
/// to models is the caller's job.
///
/// Throws [ServerException] when the server reports an error: `error: true`
/// (checked even on HTTP 200) or a status outside 2xx. Throws
/// [InvalidResponseException] when the body is not UTF-8 JSON in this shape.
Object? unwrapApiEnvelope({
  required int statusCode,
  required List<int> bodyBytes,
}) {
  final Object? json;
  try {
    // Decode as UTF-8 explicitly: http.Response.body falls back to Latin-1
    // when the server omits the charset.
    json = jsonDecode(utf8.decode(bodyBytes));
  } on FormatException {
    throw InvalidResponseException('Body is not UTF-8 JSON (HTTP $statusCode)');
  }

  switch (json) {
    case {
      'error': final bool error,
      'message': final String message,
      'data': final Object? data,
    }:
      final isSuccessStatus = statusCode >= 200 && statusCode < 300;
      if (error || !isSuccessStatus) {
        throw ServerException(statusCode: statusCode, message: message);
      }
      return data;
    default:
      throw InvalidResponseException(
        'Body is not the {error, message, data} envelope (HTTP $statusCode)',
      );
  }
}
