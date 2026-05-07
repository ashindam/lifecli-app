import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;

  static Future<void> init() async {
    // Firebase automatically restores the session — nothing extra needed
  }

  static Future<User?> signIn() async {
    try {
      if (kIsWeb) {
        // Web: use Firebase popup sign-in
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      } else {
        // Mobile: use google_sign_in + Firebase credential
        final googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile', drive.DriveApi.driveAppdataScope],
        );
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      debugPrint('Sign-in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }

  static Future<http.Client?> getAuthClient() async {
    if (_auth.currentUser == null) return null;
    try {
      final token = await _auth.currentUser!.getIdToken();
      if (token == null) return null;
      return _AuthenticatedClient(
          http.Client(), {'Authorization': 'Bearer $token'});
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

  static String? get displayName => _auth.currentUser?.displayName;
  static String? get email => _auth.currentUser?.email;
  static String? get photoUrl => _auth.currentUser?.photoURL;
  static String? get userId => _auth.currentUser?.uid;
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
