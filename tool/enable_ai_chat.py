from pathlib import Path

service = Path('lib/services/ai_assistant_service.dart').read_text(encoding='utf-8')
screen = Path('lib/screens/assistant_screen.dart').read_text(encoding='utf-8')

if 'Future<AiAssistantResponse> chat({' not in service:
    raise SystemExit('AI chat service method is missing.')
if '_assistant.chat(' not in screen:
    raise SystemExit('Assistant screen is not connected to AI chat.')
