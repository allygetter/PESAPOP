// lib/services/storage_service.dart
// Secure local token + user storage

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Tokens ───────────────────────────────────
  Future<void> saveTokens(String access, String refresh) async {
    await Future.wait([
      _secure.write(key: 'access_token', value: access),
      _secure.write(key: 'refresh_token', value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _secure.read(key: 'access_token');
  Future<String?> getRefreshToken() => _secure.read(key: 'refresh_token');

  Future<void> clearTokens() async {
    await Future.wait([
      _secure.delete(key: 'access_token'),
      _secure.delete(key: 'refresh_token'),
    ]);
  }

  // ── User ─────────────────────────────────────
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _secure.write(key: 'user', value: json.encode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _secure.read(key: 'user');
    return raw != null ? json.decode(raw) as Map<String, dynamic> : null;
  }

  Future<void> clearUser() => _secure.delete(key: 'user');

  // ── First launch ─────────────────────────────
  Future<bool> isFirstLaunch() async {
    final v = await _secure.read(key: 'launched');
    return v == null;
  }

  Future<void> markLaunched() => _secure.write(key: 'launched', value: '1');

  // ── Full clear (logout) ───────────────────────
  Future<void> clearAll() => _secure.deleteAll();
}
