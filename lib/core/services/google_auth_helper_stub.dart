/// Stub for web builds — desktop Google Sign-In is never invoked on web.
Future<String?> signInWithGoogleDesktop({
  required String clientId,
  String? clientSecret,
  required String scopes,
}) async {
  throw UnsupportedError(
    'signInWithGoogleDesktop is not available on this platform.',
  );
}
