import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';

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

  Future<UserResponse> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<UserResponse> updateEmail(String email) {
    return _client.auth.updateUser(UserAttributes(email: email.trim()));
  }

  Future<void> deleteAccount() async {
    if (_client.auth.currentSession == null) {
      throw const MissingSessionException();
    }

    final response = await _client.functions.invoke(
      'delete-account',
      body: const {'confirmation': 'DELETE_NUMUW_ACCOUNT'},
    );

    if (response.status < 200 || response.status >= 300) {
      final data = response.data;
      final message = data is Map ? data['message']?.toString() : null;
      throw AppException(
        message?.trim().isNotEmpty == true
            ? message!
            : 'تعذر حذف الحساب حاليًا. حاولي مرة أخرى.',
      );
    }

    final data = response.data;
    if (data is! Map || data['deleted'] != true) {
      throw const AppException('لم يتم تأكيد حذف الحساب. حاولي مرة أخرى.');
    }

    // The server deletes the auth user. Clear any locally cached session so
    // the app immediately returns to the signed-out flow even before the
    // auth-state stream receives its next event.
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  Future<void> signOut() => _client.auth.signOut();
}
