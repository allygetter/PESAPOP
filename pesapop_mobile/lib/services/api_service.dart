// lib/services/api_service.dart
// PESAPOP AI — Central HTTP client (Dio)

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      _LogInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    final res = await _dio.get(path, queryParameters: params);
    return res.data as T;
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    final res = await _dio.post(path, data: data);
    return res.data as T;
  }

  Future<T> put<T>(String path, {dynamic data}) async {
    final res = await _dio.put(path, data: data);
    return res.data as T;
  }

  Future<T> delete<T>(String path) async {
    final res = await _dio.delete(path);
    return res.data as T;
  }
}

// ── Auth interceptor — attaches JWT, refreshes on 401 ────────
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _refreshing = false;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_refreshing) {
      _refreshing = true;
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          final res = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
          final newToken = res.data['accessToken'];
          await _storage.write(key: 'access_token', value: newToken);
          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retried = await _dio.fetch(err.requestOptions);
          handler.resolve(retried);
          return;
        }
      } catch (_) {
        // Refresh failed — clear tokens, user must re-login
        await _storage.deleteAll();
      } finally {
        _refreshing = false;
      }
    }
    handler.next(err);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // In production, send to error tracking (e.g. Sentry)
    // ignore: avoid_print
    print('[API ERROR] ${err.requestOptions.method} ${err.requestOptions.path} → ${err.response?.statusCode}');
    handler.next(err);
  }
}
