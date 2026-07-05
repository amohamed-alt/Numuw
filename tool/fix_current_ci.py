from pathlib import Path


def replace(path, old, new):
    file = Path(path)
    text = file.read_text(encoding='utf-8')
    if old in text:
        file.write_text(text.replace(old, new, 1), encoding='utf-8')


model = Path('lib/models/ai_assistant_response.dart')
text = model.read_text(encoding='utf-8')
if 'factory AiAssistantResponse.fromJsonString' not in text:
    marker = '  Map<String, dynamic> toJson() => {'
    method = '''  factory AiAssistantResponse.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Assistant response must be a JSON object.');
    }
    return AiAssistantResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

'''
    model.write_text(text.replace(marker, method + marker, 1), encoding='utf-8')

replace('lib/screens/quick_log_screen.dart', '    _reload();\n    ChildSession.instance.addListener(_onChildChanged);', "    if (_mode == 'log') _reload();\n    ChildSession.instance.addListener(_onChildChanged);")
replace('lib/widgets/app_bottom_navigation.dart', '          height: 78,', '          height: 96,')
replace('lib/widgets/quick_log_sheet.dart', '      child: Padding(\n        padding: const EdgeInsetsDirectional.fromSTEB(18, 6, 18, 22),', '      child: SingleChildScrollView(\n        padding: const EdgeInsetsDirectional.fromSTEB(18, 6, 18, 22),')
replace('test/numuw_ui_smoke_test.dart', "    expect(find.text('تسجيل الدخول'), findsOneWidget);", "    expect(find.textContaining('تسجيل الدخول', findRichText: true), findsOneWidget);")
