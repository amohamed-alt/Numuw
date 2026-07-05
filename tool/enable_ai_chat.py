from pathlib import Path

service_path = Path('lib/services/ai_assistant_service.dart')
service = service_path.read_text(encoding='utf-8')
if 'Future<AiAssistantResponse> chat({' not in service:
    marker = '  Future<AiAssistantResponse> dailySummary({' 
    chat = '''  Future<AiAssistantResponse> chat({
    required ChildProfile child,
    required List<CareEvent> events,
    required String question,
    required DateTime now,
    required Locale locale,
  }) {
    final text = question.trim();
    if (text.isEmpty) {
      throw const LocalValidationException('اكتبي سؤالك أولًا.');
    }
    if (text.length > 700) {
      throw const LocalValidationException(
        'السؤال طويل جدًا. اختصريه وحاولي مرة أخرى.',
      );
    }
    if (containsEmergencyKeyword(text)) {
      throw const EmergencyDetectedException();
    }
    return _call(
      mode: AiAssistantMode.chat,
      childId: child.id,
      payload: {
        ...AiContextBuilder.dailySummary(
          child: child,
          events: events,
          now: now,
          locale: _localeTag(locale),
          timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
        ),
        'question': text,
      },
    );
  }

'''
    service = service.replace(marker, chat + marker, 1)
    service_path.write_text(service, encoding='utf-8')

screen_path = Path('lib/screens/assistant_screen.dart')
screen = screen_path.read_text(encoding='utf-8')
screen = screen.replace("import '../repositories/doctor_question_repository.dart';\n", '')
screen = screen.replace('  final _questionRepo = DoctorQuestionRepository();\n', '')
old = '''      if (text.contains('لخّصي') || text.contains('ملخص')) {
        final events = await _careRepo.fetchRecent(child.id, limit: 50);
        final response = await _assistant.dailySummary(
          child: child,
          events: events,
          now: now,
          locale: locale,
        );
        if (mounted) setState(() => _messages.add(_Message(false, _responseText(response))));
      } else {
        await _questionRepo.add(childId: child.id, question: text);
        if (mounted) {
          setState(() => _messages.add(const _Message(false,
              'تم حفظ السؤال. يمكنك مراجعته من ملف الطفل وإضافته إلى التقرير.')));
        }
      }'''
new = '''      final events = await _careRepo.fetchRecent(child.id, limit: 50);
      final response = text.contains('لخّصي') || text.contains('ملخص')
          ? await _assistant.dailySummary(
              child: child,
              events: events,
              now: now,
              locale: locale,
            )
          : await _assistant.chat(
              child: child,
              events: events,
              question: text,
              now: now,
              locale: locale,
            );
      if (mounted) {
        setState(() => _messages.add(_Message(false, _responseText(response))));
      }'''
if old not in screen:
    raise SystemExit('Assistant send block not found')
screen_path.write_text(screen.replace(old, new, 1), encoding='utf-8')
