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

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _makeSummary() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    try {
      final events = await _careRepo.fetchRecent(child.id, limit: 50);
      setState(() => _summary = _assistant.localSummary(child, events));
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _summary = readableError(error));
    }
  }

  Future<void> _saveQuestion() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _question.text.trim().isEmpty) return;
    try {
      await _questionRepo.add(childId: child.id, question: _question.text);
      _question.clear();
      setState(() => _message = 'تم حفظ السؤال للطبيب.');
    } catch (e, s) {
      logError(e, s);
      setState(() => _message = readableError(e));
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
              child: Text(
                _assistant.safetyNotice(),
                style: const TextStyle(
                  color: AppColors.peach,
                  fontWeight: FontWeight.w800,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص محلي للطبيب',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _summary ??
                        'اضغطي لإنشاء ملخص من بيانات ${child?.name ?? 'الطفل'} المسجلة. لا يتضمن تشخيصًا أو وصف علاج.',
                    style: const TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: child == null ? null : _makeSummary,
                    child: const Text('إنشاء ملخص'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حضّري سؤالًا للطبيب',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _question,
                    minLines: 2,
                    maxLines: 4,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: 'اكتبي السؤال',
                      filled: true,
                      fillColor: AppColors.mintLight.withValues(alpha: .25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: child == null ? null : _saveQuestion,
                    child: const Text('حفظ السؤال'),
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _message!,
                        style: const TextStyle(
                          color: AppColors.mint,
                          fontWeight: FontWeight.w800,
                        ),
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
