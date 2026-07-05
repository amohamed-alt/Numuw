from pathlib import Path
import re

path = Path('lib/models/ai_assistant_response.dart')
text = path.read_text(encoding='utf-8')
replacement = """List<String> _normalizeMethods(Object? value) {
  final values = value is List ? value : [value];
  const aliases = <String, String>{
    'breast': 'breast',
    '\u0637\u0628\u064a\u0639\u064a': 'breast',
    '\u0631\u0636\u0627\u0639\u0629 \u0637\u0628\u064a\u0639\u064a\u0629': 'breast',
    'formula': 'formula',
    '\u0635\u0646\u0627\u0639\u064a': 'formula',
    '\u0631\u0636\u0627\u0639\u0629 \u0635\u0646\u0627\u0639\u064a\u0629': 'formula',
    'mixed': 'mixed',
    '\u0645\u062e\u062a\u0644\u0637': 'mixed',
    '\u0631\u0636\u0627\u0639\u0629 \u0645\u062e\u062a\u0644\u0637\u0629': 'mixed',
    'bottle': 'bottle',
    '\u0632\u062c\u0627\u062c\u0629': 'bottle',
  };
  return values
      .map(_string)
      .whereType<String>()
      .map((item) => aliases[item.toLowerCase()])
      .whereType<String>()
      .toSet()
      .toList(growable: false);
}

String? _normalizeSide"""
updated = re.sub(
    r'List<String> _normalizeMethods\(Object\? value\) \{.*?\n\}\n\nString\? _normalizeSide',
    replacement,
    text,
    count=1,
    flags=re.S,
)
if updated == text and 'const aliases = <String, String>' not in text:
    raise SystemExit('Normalization block not found.')
path.write_text(updated, encoding='utf-8')
