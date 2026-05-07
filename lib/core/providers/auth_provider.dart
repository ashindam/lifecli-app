import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_auth_service.dart';

class AuthState {
  final bool isSignedIn;
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isSignedIn = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isSignedIn,
    bool? isLoading,
    User? user,
    String? error,
  }) => AuthState(
    isSignedIn: isSignedIn ?? this.isSignedIn,
    isLoading: isLoading ?? this.isLoading,
    user: user ?? this.user,
    error: error,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = GoogleAuthService.currentUser;
    state = AuthState(isSignedIn: user != null, user: user);
  }

  Future<bool> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await GoogleAuthService.signIn();
      if (user != null) {
        state = AuthState(isSignedIn: true, user: user);
        return true;
      }
      state = const AuthState(isSignedIn: false, error: 'Sign-in cancelled');
      return false;
    } catch (e) {
      state = AuthState(isSignedIn: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await GoogleAuthService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_mode');
    state = const AuthState();
  }

  String? get displayName => state.user?.displayName;
  String? get email => state.user?.email;
  String? get photoUrl => state.user?.photoURL;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
