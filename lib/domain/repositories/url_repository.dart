/// Keeps the API URL the user last submitted, between app launches.
///
/// Storage is best-effort, so implementations never throw and never hang:
/// a failed or too slow read returns `null`, a failed or too slow write is
/// ignored. The app then works the same way, only without the restored URL.
/// This matters because [loadUrl] is awaited before the first frame and
/// [saveUrl] before the tasks request.
abstract interface class UrlRepository {
  /// The saved URL, or `null` if nothing is saved or it cannot be read in
  /// time.
  Future<Uri?> loadUrl();

  /// Saves [url], replacing the previously saved one.
  Future<void> saveUrl(Uri url);
}
