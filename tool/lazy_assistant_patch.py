from pathlib import Path

path = Path('lib/screens/assistant_screen.dart')
if not path.exists():
    raise SystemExit('Assistant screen is missing.')
