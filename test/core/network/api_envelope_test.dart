import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shortest_path/core/network/api_envelope.dart';
import 'package:shortest_path/core/network/network_exception.dart';

void main() {
  Object? unwrap(int statusCode, String body) =>
      unwrapApiEnvelope(statusCode: statusCode, bodyBytes: utf8.encode(body));

  group('success', () {
    test('200 with error: false returns data', () {
      final data = unwrap(
        200,
        '{"error": false, "message": "OK", "data": [{"id": "1"}]}',
      );

      expect(data, [
        {'id': '1'},
      ]);
    });

    test('any 2xx status counts as success', () {
      final data = unwrap(201, '{"error": false, "message": "OK", "data": {}}');

      expect(data, <String, Object?>{});
    });
  });

  group('server error', () {
    test('200 with error: true (as in the Swagger example)', () {
      expect(
        () => unwrap(200, '{"error": true, "message": "Oops", "data": []}'),
        throwsA(const ServerException(statusCode: 200, message: 'Oops')),
      );
    });

    test('429 with message', () {
      expect(
        () => unwrap(
          429,
          '{"error": true, "message": "Too many requests", "data": {}}',
        ),
        throwsA(
          const ServerException(statusCode: 429, message: 'Too many requests'),
        ),
      );
    });

    test('500 with validation message', () {
      expect(
        () => unwrap(
          500,
          '{"error": true, "message": "Not valid test count result", '
          '"data": {}}',
        ),
        throwsA(
          const ServerException(
            statusCode: 500,
            message: 'Not valid test count result',
          ),
        ),
      );
    });

    test('300, right above the 2xx range, is an error', () {
      expect(
        () => unwrap(300, '{"error": false, "message": "", "data": {}}'),
        throwsA(const ServerException(statusCode: 300, message: '')),
      );
    });

    test('non-2xx status with error: false is still an error', () {
      expect(
        () => unwrap(500, '{"error": false, "message": "", "data": {}}'),
        throwsA(const ServerException(statusCode: 500, message: '')),
      );
    });

    test('message is decoded as UTF-8', () {
      expect(
        () => unwrap(
          500,
          '{"error": true, "message": "Помилка сервера", "data": {}}',
        ),
        throwsA(
          const ServerException(statusCode: 500, message: 'Помилка сервера'),
        ),
      );
    });
  });

  group('invalid response', () {
    for (final (description, body) in const [
      ('HTML page', '<!DOCTYPE html><html><body>Hello</body></html>'),
      ('JSON object without the envelope', '{"tasks": []}'),
      ('JSON array', '[1, 2, 3]'),
      (
        'envelope field of a wrong type',
        '{"error": "false", "message": "OK", "data": []}',
      ),
      ('empty body', ''),
    ]) {
      test(description, () {
        expect(
          () => unwrap(200, body),
          throwsA(isA<InvalidResponseException>()),
        );
      });
    }

    test('body that is not UTF-8', () {
      expect(
        () => unwrapApiEnvelope(statusCode: 200, bodyBytes: const [0xFF, 0xFE]),
        throwsA(isA<InvalidResponseException>()),
      );
    });
  });
}
