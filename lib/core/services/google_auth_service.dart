import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      drive.DriveApi.driveAppdataScope,
    ],
  );

  static GoogleSignInAccount? _currentUser;
  static GoogleSignInAccount? get currentUser => _currentUser;
  static bool get isSignedIn => _currentUser != null;

  static Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
    });
    try {
      _currentUser = await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('Silent sign-in failed: $e');
    }
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      debugPrint('Sign-in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  static Future<http.Client?> getAuthClient() async {
    if (_currentUser == null) return null;
    try {
      final headers = await _currentUser!.authHeaders;
      return _AuthenticatedClient(http.Client(), headers);
    } catch (e) {
      debugPrint('Auth client error: $e');
      return null;
    }
  }

  static Future<drive.DriveApi?> getDriveApi() async {
    final client = await getAuthClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  static String? get displayName => _currentUser?.displayName;
  static String? get email => _currentUser?.email;
  static String? get photoUrl => _currentUser?.photoUrl;
  static String? get userId => _currentUser?.id;
}

class _AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final Map<String, String> _headers;

  _AuthenticatedClient(this._inner, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
