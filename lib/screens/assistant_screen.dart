import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/doctor_question_repository.dart';
import '../services/report_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _assistant = const AssistantService();
  final _careRepo = CareEventRepository();
  final _questionRepo = DoctorQuestionRepository();
  final _input = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  String? _notice;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _makeSummary() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    setState(() {
      _loading = true;
      _notice = null;
    });
    try {
      final events = await _careRepo.fetchRecent(child.id, limit: 50);
      final summary = _assistant.localSummary(child, events);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage.user('أنشئي لي ملخصاً من بيانات ${child.name} للطبيب'),
        );
        _messages.add(_ChatMessage.assistant(summary));
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _notice = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveQuestion() async {
    final child = ChildSession.instance.selectedChild;
    final text = _input.text.trim();
    if (child == null || text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage.user(text));
      _loading = true;
      _notice = null;
      _input.clear();
    });
    try {
      await _questionRepo.add(childId: child.id, question: text);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage.assistant(
            'تم حفظ السؤال للطبيب. يمكنك مراجعته من ملف الطفل وتضمينه في التقرير.',
          ),
        );
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _notice = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _prepareQuestion() {
    _input.text = 'أريد سؤال الطبيب عن ';
    _input.selection = TextSelection.collapsed(offset: _input.text.length);
  }

  void _showEmergencyNotice() {
    setState(
      () => _notice =
          'في الطوارئ أو صعوبة التنفس أو خمول شديد تواصلي مع الطبيب أو الطوارئ فوراً.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumuwEntrance(
              child: NumuwAppBar(
                title: 'اسألي',
                subtitle: 'رتّبي بياناتك وأسئلتك للطبيب بأمان',
                trailing: const NumuwOrganicIcon(
                  NumuwOrganicIconName.aiAssistant,
                  size: 42,
                  semanticLabel: 'مساعد نمو الذكي',
                ),
              ),
            ),
            const SizedBox(height: 14),
            NumuwEntrance(
              child: NumuwPlantProgress(
                progress: _messages.isEmpty ? .28 : .62,
                label: _messages.isEmpty ? 'جاهزة للمساعدة' : 'المحادثة تتقدم',
              ),
            ),
            const SizedBox(height: 16),
            NumuwEntrance(child: WarningBanner(message: _assistant.safetyNotice())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AssistantActionCard(
                    icon: NumuwOrganicIconName.documents,
                    title: 'ملخص للطبيب',
                    subtitle: 'من آخر التسجيلات',
                    color: AppColors.mint,
                    background: AppColors.mintLight,
                    onTap: child == null ? null : _makeSummary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AssistantActionCard(
                    icon: NumuwOrganicIconName.doctor,
                    title: 'صياغة سؤال',
                    subtitle: 'احفظيه للتقرير',
                    color: AppColors.blue,
                    background: AppColors.blueLight,
                    onTap: _prepareQuestion,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _AssistantActionCard(
              icon: NumuwOrganicIconName.error,
              title: 'تنبيه الطوارئ',
              subtitle: 'المساعد لا يشخّص ولا يؤكد السلامة الطبية',
              color: AppColors.danger,
              background: AppColors.peachLight,
              onTap: _showEmergencyNotice,
              wide: true,
            ),
            const SizedBox(height: 16),
            NumuwEntrance(
              child: NumuwCard(
                padding: const EdgeInsetsDirectional.all(14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 230),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_messages.isEmpty)
                        _EmptyConversation(childName: child?.name)
                      else
                        ..._messages.map((message) => _Bubble(message)),
                      if (_loading) ...[
                        const SizedBox(height: 10),
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: LoadingDots(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Composer(
              controller: _input,
              loading: _loading,
              enabled: child != null,
              onSend: _saveQuestion,
            ),
            if (_notice != null) ...[
              const SizedBox(height: 12),
              NumuwEntrance(
                child: InfoBanner(
                  message: _notice!,
                  icon: Icons.info_outline_rounded,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssistantActionCard extends StatelessWidget {
  const _AssistantActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
    this.wide = false,
  });

  final NumuwOrganicIconName icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback? onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return NumuwPressable(
      onTap: onTap,
      semanticLabel: title,
      child: NumuwCard(
        padding: EdgeInsetsDirectional.fromSTEB(14, wide ? 13 : 15, 14, 14),
        child: Row(
          children: [
            Container(
              width: wide ? 42 : 46,
              height: wide ? 42 : 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: NumuwOrganicIcon(
                icon,
                size: wide ? 36 : 40,
                semanticLabel: title,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: color,
                      fontSize: wide ? 14 : 13,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.childName});

  final String? childName;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const NumuwOrganicIcon(
        NumuwOrganicIconName.aiAssistant,
        size: 58,
        semanticLabel: 'مساعد نمو',
      ),
      const SizedBox(height: 12),
      Text(
        'كيف أقدر أساعدك اليوم؟',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          height: 1.25,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        'يمكنني تنظيم ملخص من بيانات ${childName ?? 'الطفل'} أو حفظ أسئلتك للطبيب. التحليل الطبي الشخصي غير مفعّل حتى يتوفر خادم آمن.',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: numuwSecondaryTextColor(),
          fontSize: 13,
          height: 1.65,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.loading,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool loading;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => NumuwCard(
    padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled && !loading,
            minLines: 1,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.start,
            decoration: const InputDecoration(
              hintText: 'اكتبي سؤالك للطبيب...',
              border: InputBorder.none,
              isDense: true,
            ),
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        NumuwPressable(
          onTap: enabled && !loading ? onSend : null,
          semanticLabel: 'إرسال السؤال',
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const NumuwOrganicIcon(
                    NumuwOrganicIconName.chat,
                    size: 34,
                    semanticLabel: 'إرسال',
                  ),
          ),
        ),
      ],
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.message);
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.role == 'user';
    return NumuwEntrance(
      child: Align(
        alignment: user
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 282),
          margin: const EdgeInsetsDirectional.only(bottom: 10),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: user ? AppColors.mint : numuwSurfaceColor(),
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(18),
              topEnd: const Radius.circular(18),
              bottomStart: Radius.circular(user ? 18 : 5),
              bottomEnd: Radius.circular(user ? 5 : 18),
            ),
            border: user ? null : Border.all(color: numuwBorderColor()),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.text,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: user ? Colors.white : numuwTextColor(),
              height: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage(this.role, this.text);
  factory _ChatMessage.user(String text) => _ChatMessage('user', text);
  factory _ChatMessage.assistant(String text) =>
      _ChatMessage('assistant', text);
  final String role;
  final String text;
}
