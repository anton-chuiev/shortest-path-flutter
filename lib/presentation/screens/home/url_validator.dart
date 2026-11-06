/// Outcome of [UrlValidator.validate].
sealed class UrlValidationResult {
  const UrlValidationResult();
}

final class ValidUrl extends UrlValidationResult {
  const ValidUrl(this.url);

  final Uri url;
}

final class InvalidUrl extends UrlValidationResult {
  const InvalidUrl(this.message);

  /// Ready to be shown under the text field.
  final String message;
}

/// Checks the API base URL typed on the Home screen.
///
/// Accepts absolute `http` / `https` URLs with a host. Query parameters are
/// allowed and kept as is. A URL without a scheme is rejected rather than
/// silently prefixed with `https://`.
class UrlValidator {
  const UrlValidator();

  static const _allowedSchemes = {'http', 'https'};

  UrlValidationResult validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const InvalidUrl('URL is required');
    }

    // Uri always stores the scheme in lowercase, so `HTTPS://...` passes too.
    final url = Uri.tryParse(trimmed);
    if (url == null ||
        !_allowedSchemes.contains(url.scheme) ||
        !_isValidHost(url.host)) {
      return const InvalidUrl('Please enter a valid URL');
    }
    return ValidUrl(url);
  }

  /// Uri.tryParse doesn't reject characters that are not allowed in a host
  /// (a space, `<`, non-ASCII letters): it percent-encodes them, e.g.
  /// `exa mple.com` becomes `exa%20mple.com`. Such a host cannot be resolved,
  /// so a `%` in it means the typed URL is invalid.
  static bool _isValidHost(String host) =>
      host.isNotEmpty && !host.contains('%');
}
