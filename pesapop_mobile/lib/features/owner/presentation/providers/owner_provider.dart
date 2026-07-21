// lib/features/owner/presentation/providers/owner_provider.dart
// UPDATED — uses real AnalyticsRepository and AiRepository

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/analytics_repository.dart';
import '../../data/ai_repository.dart';
import '../../domain/owner_models.dart';

export '../../domain/owner_models.dart';

// Live dashboard stats from API
final ownerStatsProvider = FutureProvider.autoDispose.family<OwnerStats, String>((ref, range) {
  return ref.read(analyticsRepositoryProvider).getDashboard(range: range);
});

// Default 30d range shortcut used by screens
final ownerDashboardProvider = FutureProvider.autoDispose<OwnerStats>((ref) {
  return ref.read(analyticsRepositoryProvider).getDashboard(range: '30d');
});

// ── AI chat ────────────────────────────────────────────────────
final aiMessagesProvider = StateNotifierProvider<AIMessagesNotifier, List<AIMessage>>((ref) {
  return AIMessagesNotifier(ref.read(aiRepositoryProvider));
});

class AIMessagesNotifier extends StateNotifier<List<AIMessage>> {
  AIMessagesNotifier(this._repo) : super([
    const AIMessage(
      role: 'assistant',
      content: "👋 Hi! I'm PESA AI, your business advisor. Ask me anything about your sales, stock, customers, or finances.",
    ),
  ]);

  final AiRepository _repo;

  Future<void> sendMessage(String text) async {
    state = [...state, AIMessage(role: 'user', content: text)];
    state = [...state, const AIMessage(role: 'assistant', content: '', isLoading: true)];

    try {
      final response = await _repo.chat(state.where((m) => !m.isLoading).toList());
      state = [
        ...state.where((m) => !m.isLoading),
        AIMessage(role: 'assistant', content: response),
      ];
    } catch (e) {
      state = [
        ...state.where((m) => !m.isLoading),
        AIMessage(role: 'assistant', content: 'Sorry, I had trouble connecting. Please try again.'),
      ];
    }
  }

  void clearChat() => state = [state.first];
}

final ownerNavIndexProvider = StateProvider<int>((ref) => 0);
