import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small wrapper for sensitive local values that must not live in
/// SharedPreferences. Supabase session persistence remains owned by Supabase.
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(storageNamespace: 'numuw_secure'),
  );

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clear() => _storage.deleteAll();
}
