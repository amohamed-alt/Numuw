from pathlib import Path

path = Path('lib/screens/auth/sign_up_screen.dart')
text = path.read_text(encoding='utf-8')
if 'child: CheckboxListTile(' not in text:
    start = text.find('              CheckboxListTile(')
    end = text.find('              if (_error != null)', start)
    if start < 0 or end < 0:
        raise SystemExit('Checkbox block not found.')
    block = text[start:end].strip()
    wrapped = (
        '              Material(\n'
        '                color: Colors.transparent,\n'
        '                child: ' + block + '\n'
        '              ),\n'
    )
    path.write_text(text[:start] + wrapped + text[end:], encoding='utf-8')
