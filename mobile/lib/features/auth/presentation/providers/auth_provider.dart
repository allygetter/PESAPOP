// lib/features/auth/presentation/providers/auth_provider.dart
// UPDATED — uses real AuthRepository

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_models.dart';
import '../../../../services/storage_service.dart';

export '../../domain/auth_models.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref.read(storageServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo, this._storage) : super(const AuthState()) {
    _init();
  }

  final AuthRepository _repo;
  final StorageService _storage;

  Future<void> _init() async {
    final isFirst = await _storage.isFirstLaunch();
    final user = await _storage.getUser();
    final token = await _storage.getAccessToken();

    if (user != null && token != null) {
      final ppUser = PPUser.fromJson(user);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: ppUser,
        isFirstLaunch: false,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isFirstLaunch: isFirst,
      );
    }
  }

  Future<bool> requestOTP(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repo.requestOtp(phone);
      state = state.copyWith(status: AuthStatus.unauthenticated, pendingPhone: phone);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyOTP(String otp) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final res = await _repo.verifyOtp(state.pendingPhone ?? '', otp);

      // action == 'REGISTER' means new user
      if (res['action'] == 'REGISTER') {
        state = state.copyWith(status: AuthStatus.unauthenticated, pendingPhone: state.pendingPhone);
        return false; // caller navigates to register
      }

      final user = PPUser.fromJson(res['user'] as Map<String, dynamic>);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: _parseError(e));
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    // Email login not yet wired on backend — show error for now
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Email login coming soon. Use phone number.',
    );
    return false;
  }

  Future<bool> register({
    required String name,
    required String businessName,
    String? email,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final res = await _repo.register(
        name: name,
        phone: state.pendingPhone ?? '',
        businessName: businessName,
        email: email,
      );
      final user = PPUser.fromJson(res['user'] as Map<String, dynamic>);
      await _storage.markLaunched();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstLaunch: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: _parseError(e));
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    await _storage.markLaunched();
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated, isFirstLaunch: false);
  }

  void clearError() => state = state.copyWith(status: AuthStatus.unauthenticated);

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('400')) return 'Invalid request. Please check your details.';
      if (msg.contains('401')) return 'Session expired. Please log in again.';
      if (msg.contains('429')) return 'Too many attempts. Please wait a moment.';
      if (msg.contains('500')) return 'Server error. Please try again later.';
      if (msg.contains('SocketException') || msg.contains('connection')) {
        return 'No internet connection. Please check your network.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
