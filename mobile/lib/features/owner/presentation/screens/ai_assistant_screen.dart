// lib/features/owner/presentation/screens/ai_assistant_screen.dart
// PESAPOP AI — PESA AI Chat Assistant

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pp_bottom_nav.dart';
import '../providers/owner_provider.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  static const _suggestions = [
    'What was my profit last month?',
    'Which products should I reorder?',
    'Who are my top customers?',
    'Forecast revenue for next month',
    'Why did sales drop last week?',
    'Show payment method breakdown',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send([String? text]) async {
    final msg = (text ?? _controller.text).trim();
    if (msg.isEmpty) return;
    _controller.clear();
    HapticFeedback.lightImpact();
    await ref.read(aiMessagesProvider.notifier).sendMessage(msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = ref.watch(aiMessagesProvider);

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final surf2 = isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec = isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;

    final showSuggestions = messages.length <= 1;

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(children: [

          // ── Header ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(PPSpacing.screenH, 14, PPSpacing.screenH, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: surf,
                        borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textPrimary)),
              ),
              const SizedBox(width: 12),
              // AI avatar
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C47FF), Color(0xFF00C896)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PESA AI', style: PPTypography.headingSM.copyWith(color: textPrimary)),
                Text('Your business advisor', style: PPTypography.bodyXS.copyWith(color: textSec)),
              ])),
              GestureDetector(
                onTap: () => ref.read(aiMessagesProvider.notifier).clearChat(),
                child: Icon(Icons.refresh_rounded, color: textSec, size: 20),
              ),
            ]),
          ),

          const SizedBox(height: 12),
          Divider(color: border, thickness: 1, height: 1),

          // ── Messages ────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                PPSpacing.screenH, 16, PPSpacing.screenH, 16,
              ),
              itemCount: messages.length + (showSuggestions ? 1 : 0),
              itemBuilder: (context, i) {
                if (showSuggestions && i == messages.length) {
                  return _SuggestionChips(
                    suggestions: _suggestions,
                    textSec: textSec,
                    surf2: surf2,
                    border: border,
                    onTap: _send,
                  );
                }
                final msg = messages[i];
                return _MessageBubble(
                  message: msg,
                  isDark: isDark,
                  surf: surf,
                  surf2: surf2,
                  border: border,
                  textPrimary: textPrimary,
                  textSec: textSec,
                );
              },
            ),
          ),

          // ── Input bar ───────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              PPSpacing.screenH, 10, PPSpacing.screenH,
              PPSpacing.base + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? PPColors.darkSurface : PPColors.lightSurface,
              border: Border(top: BorderSide(color: border)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 110),
                  decoration: BoxDecoration(
                    color: surf2,
                    borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                    border: Border.all(color: border),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: PPTypography.bodyMD.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask about your business...',
                      hintStyle: PPTypography.bodyMD.copyWith(color: textSec),
                      border: InputBorder.none, enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      isDense: true, filled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C47FF), Color(0xFF00C896)],
                    ),
                    borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: PPBottomNav(
        items: ownerNavItems,
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) context.go('/owner');
          if (i == 1) context.push('/owner/reports');
          if (i == 4) context.push('/settings');
        },
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message, required this.isDark, required this.surf,
    required this.surf2, required this.border, required this.textPrimary, required this.textSec,
  });
  final AIMessage message;
  final bool isDark;
  final Color surf, surf2, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C47FF), Color(0xFF00C896)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? PPColors.brand : surf,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(PPSpacing.radiusMD),
                  topRight: const Radius.circular(PPSpacing.radiusMD),
                  bottomLeft: Radius.circular(isUser ? PPSpacing.radiusMD : 4),
                  bottomRight: Radius.circular(isUser ? 4 : PPSpacing.radiusMD),
                ),
                border: isUser ? null : Border.all(color: border),
              ),
              child: message.isLoading
                  ? _TypingIndicator(isDark: isDark)
                  : _parseMarkdown(message.content, isUser, textPrimary),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _parseMarkdown(String text, bool isUser, Color textPrimary) {
    // Very basic bold parsing: **text** → bold
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: PPTypography.bodyMD.copyWith(
          color: isUser ? Colors.black : textPrimary,
          fontWeight: i.isOdd ? FontWeight.w600 : FontWeight.w400,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// ── Typing indicator ──────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.isDark});
  final bool isDark;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
        final offset = ((_controller.value + i * 0.3) % 1.0);
        final opacity = offset < 0.5 ? offset * 2 : (1 - offset) * 2;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Opacity(
            opacity: opacity.clamp(0.2, 1.0),
            child: Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(color: PPColors.brand, shape: BoxShape.circle),
            ),
          ),
        );
      })),
    );
  }
}

// ── Suggestion chips ──────────────────────────────────────────
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.suggestions, required this.textSec,
      required this.surf2, required this.border, required this.onTap});
  final List<String> suggestions;
  final Color textSec, surf2, border;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Try asking:',
            style: PPTypography.labelMD.copyWith(color: textSec)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8,
            children: suggestions.map((s) => GestureDetector(
              onTap: () => onTap(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: surf2,
                  borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                  border: Border.all(color: border),
                ),
                child: Text(s, style: PPTypography.labelMD.copyWith(color: textSec)),
              ),
            )).toList()),
      ]),
    );
  }
}
