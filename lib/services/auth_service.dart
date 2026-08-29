import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  String? get currentEmail => _client.auth.currentUser?.email;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email.trim(), password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> deleteAccount() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw const AuthException('Session is required to delete the account.');
    }

    final response = await _client.functions.invoke(
      'delete-account',
      body: const {'confirmation': 'DELETE_NUMUW_ACCOUNT'},
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    final data = response.data;
    if (response.status < 200 || response.status >= 300) {
      throw AuthException(_functionMessage(data) ?? 'Account deletion failed.');
    }
    if (data is! Map || data['deleted'] != true) {
      throw AuthException(_functionMessage(data) ?? 'Account deletion was not confirmed.');
    }

    await _client.auth.signOut(scope: SignOutScope.local);
  }

  String? _functionMessage(Object? data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }
    return null;
  }

  Future<void> signOut() => _client.auth.signOut();
}
