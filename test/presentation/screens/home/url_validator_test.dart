import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shortest_path/presentation/screens/home/url_validator.dart';

void main() {
  const validator = UrlValidator();

  Matcher isValidUrl(String expected) =>
      isA<ValidUrl>().having((r) => r.url.toString(), 'url', expected);

  Matcher isInvalidUrl(String message) =>
      isA<InvalidUrl>().having((r) => r.message, 'message', message);

  // Quotes the input and escapes `\n` / `\t`, so every test name stays on
  // one line in the test output.
  String nameOf(String input) => jsonEncode(input);

  group('valid', () {
    for (final (input, expected) in const [
      (
        'https://flutter.webspark.dev/flutter/api',
        'https://flutter.webspark.dev/flutter/api',
      ),
      (
        'http://flutter.webspark.dev/flutter/api',
        'http://flutter.webspark.dev/flutter/api',
      ),
      (
        'https://flutter.webspark.dev/flutter/api?a=1&b=two',
        'https://flutter.webspark.dev/flutter/api?a=1&b=two',
      ),
      ('  https://example.com/api \n', 'https://example.com/api'),
      ('HTTPS://example.com', 'https://example.com'),
      ('http://localhost:8080/api', 'http://localhost:8080/api'),
      // `%` is only rejected in the host: encoded path and query are fine.
      (
        'https://example.com/a%20b?q=%D0%B0',
        'https://example.com/a%20b?q=%D0%B0',
      ),
    ]) {
      test(nameOf(input), () {
        expect(validator.validate(input), isValidUrl(expected));
      });
    }

    test('keeps query parameters', () {
      final result = validator.validate('https://example.com/api?a=1&b=two');

      expect(
        result,
        isA<ValidUrl>().having(
          (r) => r.url.queryParameters,
          'queryParameters',
          {'a': '1', 'b': 'two'},
        ),
      );
    });
  });

  group('required', () {
    for (final input in const ['', '   ', '\n\t']) {
      test(nameOf(input), () {
        expect(validator.validate(input), isInvalidUrl('URL is required'));
      });
    }
  });

  group('invalid', () {
    for (final input in const [
      'flutter.webspark.dev/flutter/api', // no scheme
      'ftp://example.com', // scheme other than http / https
      'mailto:user@example.com',
      'https://', // no host
      'https:///api',
      'https://exa mple.com', // space in the host
      'https://exa<mple.com',
      'https://приклад.укр', // non-ASCII host
      'not a url',
      'https://example.com:port', // Uri.tryParse returns null
    ]) {
      test(nameOf(input), () {
        expect(
          validator.validate(input),
          isInvalidUrl('Please enter a valid URL'),
        );
      });
    }
  });
}
