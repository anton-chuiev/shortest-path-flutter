import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shortest_path/core/network/api_envelope.dart';
import 'package:shortest_path/core/network/cancellation_token.dart';
import 'package:shortest_path/core/network/network_exception.dart';

/// Turns the decoded `data` of a response (a `Map`, `List`, `String`, `num`,
/// `bool` or `null`) into a model.
///
/// May throw [FormatException] or fail an `as` cast ([TypeError]) when the
/// JSON has an unexpected shape: [ApiClient] reports both as
/// [InvalidResponseException].
///
/// Not named `JsonDecoder`: `dart:convert` already has a class with that name.
typedef DataDecoder<T> = T Function(Object? json);

/// JSON client for the Webspark API.
///
/// [get] and [post] unwrap the response envelope (see [unwrapApiEnvelope])
/// and pass its `data` to the caller's [DataDecoder]. Any failure — network,
/// timeout, server error, malformed response, cancellation — is reported as
/// a [NetworkException].
class ApiClient {
  /// Callers pass the time limit as `timeout:` — for a private named
  /// parameter Dart drops the underscore from the argument name.
  ApiClient(this._client, {this._timeout = const Duration(seconds: 15)});

  final http.Client _client;

  /// Limit for the whole exchange: connecting, sending and reading the body.
  final Duration _timeout;

  Future<T> get<T>(
    Uri url, {
    required DataDecoder<T> decode,
    CancellationToken? cancellationToken,
  }) {
    return _send(
      _HttpMethod.get,
      url,
      decode: decode,
      cancellationToken: cancellationToken,
    );
  }

  /// Sends [body] encoded as JSON. [body] must be JSON-encodable
  /// (maps, lists, strings, numbers, booleans, null).
  Future<T> post<T>(
    Uri url, {
    required Object body,
    required DataDecoder<T> decode,
    CancellationToken? cancellationToken,
  }) {
    return _send(
      _HttpMethod.post,
      url,
      body: body,
      decode: decode,
      cancellationToken: cancellationToken,
    );
  }

  Future<T> _send<T>(
    _HttpMethod method,
    Uri url, {
    Object? body,
    required DataDecoder<T> decode,
    CancellationToken? cancellationToken,
  }) async {
    _throwIfCancelled(cancellationToken);

    // The request is aborted by whichever comes first: the time limit or
    // the caller's cancellation. Unlike Future.timeout, aborting actually
    // closes the connection instead of just ignoring the late response.
    final timeoutReached = Completer<void>();
    final request = http.AbortableRequest(
      method.value,
      url,
      abortTrigger: Future.any([
        timeoutReached.future,
        if (cancellationToken != null) cancellationToken.whenCancelled,
      ]),
    )..headers['Accept'] = 'application/json';
    if (body != null) {
      request
        // Set before the body so http keeps this type and adds the charset.
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
    }

    // Started only once the request is built: the limit covers the network
    // exchange alone, and if jsonEncode throws there is no timer to clean up.
    final timer = Timer(_timeout, timeoutReached.complete);
    final http.Response response;
    try {
      final streamed = await _client.send(request);
      response = await http.Response.fromStream(streamed);
    } on http.RequestAbortedException {
      // Must come before ClientException: it is a subtype of it.
      // Aborted either by the caller or by the timer; tell which.
      _throwIfCancelled(cancellationToken);
      throw RequestTimeoutException(_timeout);
    } on http.ClientException catch (error) {
      throw ConnectionException(error);
    } on IOException catch (error) {
      // TLS errors (HandshakeException) are not wrapped by http.
      throw ConnectionException(error);
    } finally {
      timer.cancel();
    }

    // The token may have been cancelled after the last byte had arrived:
    // a cancelled request never delivers a result.
    _throwIfCancelled(cancellationToken);

    final data = unwrapApiEnvelope(
      statusCode: response.statusCode,
      bodyBytes: response.bodyBytes,
    );

    try {
      return decode(data);
    } on FormatException catch (error) {
      throw InvalidResponseException('data has an unexpected shape: $error');
    } on TypeError catch (error) {
      // A failed `as` cast inside decode. Only errors from decode are caught
      // here; bugs elsewhere in the client still crash loudly.
      throw InvalidResponseException('data has an unexpected shape: $error');
    }
  }

  void _throwIfCancelled(CancellationToken? cancellationToken) {
    if (cancellationToken?.isCancelled ?? false) {
      throw const RequestCancelledException();
    }
  }
}

enum _HttpMethod {
  get('GET'),
  post('POST');

  const _HttpMethod(this.value);

  final String value;
}
