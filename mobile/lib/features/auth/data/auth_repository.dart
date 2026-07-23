// lib/features/auth/data/auth_repository.dart
// Replaces all mock delays in auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider), ref.read(storageServiceProvider));
});

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiService _api;
  final StorageService _storage;

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    return _api.post<Map<String, dynamic>>(ApiConstants.requestOtp, data: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiConstants.verifyOtp,
      data: {'phone': phone, 'code': code},
    );
    // If user already exists, tokens are returned
    if (res.containsKey('accessToken')) {
      await _storage.saveTokens(res['accessToken'], res['refreshToken']);
      await _storage.saveUser(res['user'] as Map<String, dynamic>);
    }
    return res;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String businessName,
    String? email,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(ApiConstants.register, data: {
      'name': name, 'phone': phone, 'businessName': businessName, 'email': email,
    });
    await _storage.saveTokens(res['accessToken'], res['refreshToken']);
    await _storage.saveUser(res['user'] as Map<String, dynamic>);
    return res;
  }

  Future<void> logout() async {
    try { await _api.post<dynamic>(ApiConstants.logout); } catch (_) {}
    await _storage.clearAll();
  }

  Future<Map<String, dynamic>> getMe() async {
    return _api.get<Map<String, dynamic>>(ApiConstants.me);
  }
}
