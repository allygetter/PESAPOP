// lib/features/owner/data/ai_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../domain/owner_models.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.read(apiServiceProvider));
});

class AiRepository {
  AiRepository(this._api);
  final ApiService _api;

  Future<String> chat(List<AIMessage> history) async {
    final res = await _api.post<Map<String, dynamic>>(ApiConstants.aiChat, data: {
      'messages': history
          .where((m) => !m.isLoading)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
    });
    return res['message'] as String;
  }
}
