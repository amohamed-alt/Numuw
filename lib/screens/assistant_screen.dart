import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/doctor_question_repository.dart';
import '../services/report_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _assistant = const AssistantService();
  final _careRepo = CareEventRepository();
  final _questionRepo = DoctorQuestionRepository();
  final _question = TextEditingController();
  String? _summary;
  String? _message;
  bool _loading = false;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _makeSummary() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    setState(() => _loading = true);
    try {
      final events = await _careRepo.fetchRecent(child.id, limit: 50);
      setState(() => _summary = _assistant.localSummary(child, events));
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _summary = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveQuestion() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _question.text.trim().isEmpty) return;
    try {
      await _questionRepo.add(childId: child.id, question: _question.text);
      _question.clear();
      setState(() => _message = 'تم حفظ السؤال للطبيب.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _message = readableError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    return Scaffold(
      body: AppPage(
        child: Column(
          children: [
            const AppHeader(
              title: 'اسألي المساعد',
              subtitle: 'واجهة آمنة لتنظيم البيانات والأسئلة',
            ),
            const SizedBox(height: 22),
            SoftCard(
              color: AppColors.peachLight,
              borderColor: AppColors.peachLight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(
                    icon: '⚠️',
                    background: AppColors.surface,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _assistant.safetyNotice(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w800,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              radius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص محلي للطبيب',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mintLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _summary ??
                          'اضغطي لإنشاء ملخص من بيانات ${child?.name ?? 'الطفل'} المسجلة. لا يتضمن تشخيصًا أو وصف علاج.',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        height: 1.7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'إنشاء ملخص',
                    loading: _loading,
                    onPressed: child == null ? null : _makeSummary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              radius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حضّري سؤالًا للطبيب',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _question,
                    label: 'اكتبي السؤال',
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'حفظ السؤال',
                    onPressed: child == null ? null : _saveQuestion,
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 10),
                    InfoBanner(message: _message!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
