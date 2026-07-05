import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../models/ai_assistant_response.dart';
import '../repositories/care_event_repository.dart';
import '../services/ai_assistant_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({
    super.key,
    AiAssistantService? assistant,
    CareEventRepository? careRepository,
  }) : _assistant = assistant,
       _careRepository = careRepository;

  final AiAssistantService? _assistant;
  final CareEventRepository? _careRepository;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  AiAssistantService? _assistant;
  CareEventRepository? _careRepo;
  final _input = TextEditingController();
  final List<_Message> _messages = [];
  bool _loading = false;
  String? _error;

  AiAssistantService get _assistantService =>
      widget._assistant ?? (_assistant ??= AiAssistantService());

  CareEventRepository get _careRepository =>
      widget._careRepository ?? (_careRepo ??= CareEventRepository());

  static const suggestions = [
    'طفلي نام أقل من المعتاد النهارده، أراجع إيه؟',
    'لخّصي لي نوم طفلي هذا الأسبوع.',
    'جهّزي لي أسئلة لزيارة الطبيب.',
    'اقترحي نشاطًا مناسبًا لعمر طفلي.',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final child = ChildSession.instance.selectedChild;
    final text = (preset ?? _input.text).trim();
    if (child == null || text.isEmpty || _loading) return;
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    setState(() {
      _messages.add(_Message(true, text));
      _input.clear();
      _loading = true;
      _error = null;
    });
    try {
      final events = await _careRepository.fetchRecent(child.id, limit: 50);
      final response = text.contains('لخّصي') || text.contains('ملخص')
          ? await _assistantService.dailySummary(
              child: child,
              events: events,
              now: now,
              locale: locale,
            )
          : await _assistantService.chat(
              child: child,
              events: events,
              question: text,
              now: now,
              locale: locale,
            );
      if (mounted) {
        setState(() => _messages.add(_Message(false, _responseText(response))));
      }
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _responseText(AiAssistantResponse response) {
    final parts = <String>[];
    final message = response.message.trim();
    if (message.isNotEmpty) parts.add(message);
    for (final section in response.sections) {
      final title = section.title.trim();
      final items = section.items
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (title.isEmpty && items.isEmpty) continue;
      if (title.isNotEmpty) parts.add(title);
      if (items.isNotEmpty) parts.add(items.map((item) => '• $item').join('\n'));
    }
    final disclaimer = response.disclaimer?.trim();
    if (disclaimer != null && disclaimer.isNotEmpty) parts.add(disclaimer);
    return parts.isEmpty
        ? 'لم يصلني ملخص واضح. جرّبي مرة أخرى بعد قليل.'
        : parts.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    final accent = numuwAccentColor();
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: .24)),
                    ),
                    child: Icon(Icons.nightlight_round, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اسألي نُمُوّ',
                          style: TextStyle(
                            color: numuwTextColor(),
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'مساعدة يومية من تسجيلات طفلك',
                          style: TextStyle(
                            color: numuwSecondaryTextColor(),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.add_comment_outlined,
                    onPressed: () => setState(() {
                      _messages.clear();
                      _error = null;
                    }),
                    badge: false,
                    size: 44,
                    radius: 14,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: numuwBorderColor()),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                children: [
                  if (_messages.isEmpty) ...[
                    _Card(
                      child: Text(
                        'أنا نُمُوّ، مساعدتك اليومية. يمكنني مراجعة تسجيلات ${child?.name ?? 'طفلك'}، تبسيط المعلومات، ومساعدتك في تجهيز أسئلة للزيارة.',
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 15,
                          height: 1.75,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsetsDirectional.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.blue.withValues(alpha: .24),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'لا ترسلي معلومات شخصية غير ضرورية أو صورًا حساسة.',
                              style: TextStyle(
                                color: numuwTextColor(),
                                fontSize: 13,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'أسئلة مقترحة',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...suggestions.map(
                      (text) => _Suggestion(
                        text: text,
                        onTap: child == null ? null : () => _send(text),
                      ),
                    ),
                  ] else ...[
                    ..._messages.map((m) => _Bubble(message: m)),
                    if (_loading)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _Card(child: const LoadingDots()),
                      ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    ErrorMessageCard(message: _error!),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 10),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 8, 7),
                decoration: BoxDecoration(
                  color: numuwSurfaceColor(),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: numuwBorderColor()),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: numuwSecondaryTextColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        enabled: child != null && !_loading,
                        minLines: 1,
                        maxLines: 4,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'اكتبي سؤالك...',
                          border: InputBorder.none,
                          filled: false,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    InkWell(
                      onTap: child == null || _loading ? null : () => _send(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _loading
                            ? const Padding(
                                padding: EdgeInsets.all(13),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(16),
    decoration: BoxDecoration(
      color: numuwSurfaceColor(),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: numuwBorderColor()),
    ),
    child: child,
  );
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.text, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 10),
    child: Material(
      color: numuwSurfaceColor(),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: numuwBorderColor()),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: numuwSecondaryTextColor()),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final user = message.user;
    return Align(
      alignment: user
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 292),
        margin: const EdgeInsetsDirectional.only(bottom: 10),
        padding: const EdgeInsetsDirectional.fromSTEB(15, 12, 15, 12),
        decoration: BoxDecoration(
          color: user ? numuwAccentColor() : numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(18),
          border: user ? null : Border.all(color: numuwBorderColor()),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: user ? Colors.white : numuwTextColor(),
            fontSize: 14,
            height: 1.65,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Message {
  const _Message(this.user, this.text);
  final bool user;
  final String text;
}
