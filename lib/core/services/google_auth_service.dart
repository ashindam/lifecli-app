import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _initialized = false;

  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;

  // Holds the last sign-in error so the UI can display it
  static String? lastError;

  static Future<void> init() async {
    if (!kIsWeb && !_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
  }

  static Future<User?> signIn() async {
    lastError = null;
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      } else {
        await init();

        GoogleSignInAccount? googleAccount;

        // 1. Try silent/lightweight sign-in first (won't show UI)
        try {
          final lightweightFuture =
              GoogleSignIn.instance.attemptLightweightAuthentication();
          if (lightweightFuture != null) {
            googleAccount = await lightweightFuture;
          }
        } catch (e) {
          // Silent auth failed or not available — fall through to interactive
          debugPrint('Lightweight sign-in skipped: $e');
        }

        // 2. Full interactive sign-in (shows Google sheet to user)
        if (googleAccount == null) {
          googleAccount = await GoogleSignIn.instance.authenticate();
        }

        // 3. Exchange Google token for Firebase credential
        final idToken = googleAccount.authentication.idToken;
        if (idToken == null) {
          lastError = 'Google did not return an ID token. Try again.';
          debugPrint('Sign-in error: $lastError');
          return null;
        }

        final credential = GoogleAuthProvider.credential(idToken: idToken);
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      lastError = '${e.code}: ${e.message}';
      debugPrint('FirebaseAuth error: $lastError');
      return null;
    } catch (e) {
      lastError = e.toString();
      debugPrint('Sign-in error: $lastError');
      return null;
    }
  }

  static Future<void> signOut() async {
    lastError = null;
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
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
