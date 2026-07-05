from pathlib import Path

path = Path('lib/models/ai_assistant_response.dart')
text = path.read_text(encoding='utf-8')
block = """  factory AiAssistantResponse.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Assistant response must be a JSON object.');
    }
    return AiAssistantResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

"""

if text.count(block) != 1:
    raise SystemExit('Expected exactly one JSON string constructor block.')

text = text.replace(block, '', 1)
marker = """  Map<String, dynamic> toJson() => {
    'message': message,
"""
if marker not in text:
    raise SystemExit('AiAssistantResponse toJson marker not found.')

path.write_text(text.replace(marker, block + marker, 1), encoding='utf-8')
