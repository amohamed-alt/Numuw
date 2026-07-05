from pathlib import Path

path = Path('lib/models/ai_assistant_response.dart')
if path.exists():
    text = path.read_text(encoding='utf-8')
    block = """  factory AiAssistantResponse.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Assistant response must be a JSON object.');
    }
    return AiAssistantResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

"""
    summary_start = text.find('class AiSummarySection')
    response_start = text.find('class AiAssistantResponse')
    misplaced = text.find(block, summary_start, response_start)
    if misplaced >= 0:
        text = text[:misplaced] + text[misplaced + len(block):]
        response_start = text.find('class AiAssistantResponse')
        marker = text.find("  Map<String, dynamic> toJson() => {\n    'message': message,", response_start)
        if marker < 0:
            raise SystemExit('AiAssistantResponse toJson marker not found.')
        text = text[:marker] + block + text[marker:]
        path.write_text(text, encoding='utf-8')

service_path = Path('lib/services/ai_assistant_service.dart')
if service_path.exists():
    service = service_path.read_text(encoding='utf-8')
    if "static const chatFunctionId = 'ai-assistant-chat';" not in service:
        service = service.replace(
            "  static const functionId = 'ai-assistant';\n",
            "  static const functionId = 'ai-assistant';\n  static const chatFunctionId = 'ai-assistant-chat';\n",
            1,
        )
    if 'targetFunctionId: chatFunctionId' not in service:
        service = service.replace(
            "    return _call(\n      mode: AiAssistantMode.chat,\n      childId: child.id,\n",
            "    return _call(\n      mode: AiAssistantMode.chat,\n      childId: child.id,\n      targetFunctionId: chatFunctionId,\n",
            1,
        )
    if 'String? targetFunctionId' not in service:
        service = service.replace(
            "    required Map<String, dynamic> payload,\n  }) async {",
            "    required Map<String, dynamic> payload,\n    String? targetFunctionId,\n  }) async {",
            1,
        )
    service = service.replace(
        '        functionId: functionId,\n',
        '        functionId: targetFunctionId ?? functionId,\n',
        1,
    )
    service_path.write_text(service, encoding='utf-8')
