from pathlib import Path

path = Path('lib/screens/assistant_screen.dart')
text = path.read_text(encoding='utf-8')
old = "  final _assistant = AiAssistantService();\n  final _careRepo = CareEventRepository();\n"
new = "  AiAssistantService? _assistantValue;\n  CareEventRepository? _careRepoValue;\n\n  AiAssistantService get _assistant =>\n      _assistantValue ??= AiAssistantService();\n  CareEventRepository get _careRepo =>\n      _careRepoValue ??= CareEventRepository();\n"
if old in text:
    path.write_text(text.replace(old, new, 1), encoding='utf-8')
