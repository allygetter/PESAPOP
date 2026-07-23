// lib/features/owner/data/analytics_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../domain/owner_models.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.read(apiServiceProvider));
});

class AnalyticsRepository {
  AnalyticsRepository(this._api);
  final ApiService _api;

  Future<OwnerStats> getDashboard({String range = '30d'}) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.dashboard,
      params: {'range': range},
    );
    return OwnerStats.fromJson(data);
  }

  Future<Map<String, dynamic>> getProfitLoss(String month) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.profitLoss,
      params: {'month': month},
    );
  }
}
