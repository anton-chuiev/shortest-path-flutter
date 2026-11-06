import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortest_path/domain/repositories/url_repository.dart';

/// [UrlRepository] backed by the platform key-value storage:
/// `NSUserDefaults` on iOS, DataStore Preferences on Android.
class UrlRepositoryImpl implements UrlRepository {
  const UrlRepositoryImpl(this._preferences);

  static const _urlKey = 'api_url';

  /// The storage is local and answers in milliseconds; the limit only guards
  /// against a platform channel that never replies.
  static const _timeout = Duration(seconds: 1);

  final SharedPreferencesAsync _preferences;

  @override
  Future<Uri?> loadUrl() async {
    try {
      final value = await _preferences.getString(_urlKey).timeout(_timeout);
      return value == null ? null : Uri.tryParse(value);
    } catch (error, stackTrace) {
      // Everything is caught, not only Exception: the contract promises no
      // throws, and a throw here would stop the app before its first frame.
      // The failure is still logged with its stack trace.
      _logFailure('read', error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveUrl(Uri url) async {
    try {
      await _preferences.setString(_urlKey, url.toString()).timeout(_timeout);
    } catch (error, stackTrace) {
      // Everything is caught, as in [loadUrl].
      _logFailure('write', error, stackTrace);
    }
  }

  static void _logFailure(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      'Failed to $operation the saved URL',
      name: 'UrlRepository',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
