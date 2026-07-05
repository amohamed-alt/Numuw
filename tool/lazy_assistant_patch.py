from pathlib import Path

path = Path('lib/screens/assistant_screen.dart')
text = path.read_text(encoding='utf-8')
old = """  final _assistant = AiAssistantService();
  final _careRepo = CareEventRepository();
"""
new = """  AiAssistantService? _assistantValue;
  CareEventRepository? _careRepoValue;

  AiAssistantService get _assistant =>
      _assistantValue ??= AiAssistantService();
  CareEventRepository get _careRepo =>
      _careRepoValue ??= CareEventRepository();
"""
if old in text:
    path.write_text(text.replace(old, new, 1), encoding='utf-8')
elif '_assistantValue' not in text:
    raise SystemExit('Assistant dependency block not found.')
