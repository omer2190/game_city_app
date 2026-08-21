// Conditional import: desktop uses dart:io for local OAuth server,
// web uses the stub which is never actually called (web uses signInWithPopup).
export 'google_auth_helper_stub.dart'
    if (dart.library.io) 'google_auth_helper_desktop.dart';
