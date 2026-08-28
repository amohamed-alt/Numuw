from pathlib import Path

path = Path('lib/services/ai_assistant_service.dart')
text = path.read_text(encoding='utf-8')

if "static const chatFunctionId = 'ai-assistant-chat';" not in text:
    text = text.replace(
        "  static const functionId = 'ai-assistant';\n",
        "  static const functionId = 'ai-assistant';\n  static const chatFunctionId = 'ai-assistant-chat';\n",
        1,
    )

chat_marker = """    return _call(
      mode: AiAssistantMode.chat,
      childId: child.id,
"""
chat_replacement = """    return _call(
      mode: AiAssistantMode.chat,
      childId: child.id,
      targetFunctionId: chatFunctionId,
"""
if 'targetFunctionId: chatFunctionId' not in text:
    if chat_marker not in text:
        raise SystemExit('Chat call marker not found.')
    text = text.replace(chat_marker, chat_replacement, 1)

call_marker = """  Future<AiAssistantResponse> _call({
    required AiAssistantMode mode,
    required String childId,
    required Map<String, dynamic> payload,
  }) async {
"""
call_replacement = """  Future<AiAssistantResponse> _call({
    required AiAssistantMode mode,
    required String childId,
    required Map<String, dynamic> payload,
    String? targetFunctionId,
  }) async {
"""
if 'String? targetFunctionId' not in text:
    if call_marker not in text:
        raise SystemExit('Assistant call marker not found.')
    text = text.replace(call_marker, call_replacement, 1)

text = text.replace(
    '        functionId: functionId,\n',
    '        functionId: targetFunctionId ?? functionId,\n',
    1,
)
path.write_text(text, encoding='utf-8')
