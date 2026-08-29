import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NumuwOrganicIconName {
  breastfeeding,
  bottle,
  sleep,
  diaper,
  food,
  medicine,
  vaccine,
  temperature,
  weight,
  height,
  headCircumference,
  growth,
  calendar,
  doctor,
  hospitalBag,
  tasks,
  shopping,
  camera,
  documents,
  aiAssistant,
  microphone,
  chat,
  family,
  father,
  pregnancy,
  newborn,
  babyItems,
  nutrition,
  water,
  motherHealth,
  relaxation,
  milestones,
  articles,
  tips,
  notifications,
  privacy,
  search,
  filter,
  edit,
  add,
  delete,
  share,
  download,
  more,
  settings,
  help,
  favorite,
  play,
  pause,
  done,
  cancel,
  error,
  home,
  account,
}

class NumuwOrganicIcon extends StatelessWidget {
  const NumuwOrganicIcon(
    this.name, {
    super.key,
    this.size = 28,
    this.semanticLabel,
  });

  final NumuwOrganicIconName name;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      NumuwOrganicSvg.source(name),
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}

abstract final class NumuwOrganicSvg {
  static const _ink = '#2F5D50';
  static const _sage = '#7FA68C';
  static const _mint = '#BFD9CB';
  static const _cream = '#FFF8EE';
  static const _sand = '#EEDFCB';
  static const _peach = '#F2B38E';
  static const _blue = '#A9C8D8';
  static const _lavender = '#C9C0DF';
  static const _coral = '#D96F62';

  static String source(NumuwOrganicIconName name) {
    final body = switch (name) {
      NumuwOrganicIconName.breastfeeding => _breastfeeding,
      NumuwOrganicIconName.bottle => _bottle,
      NumuwOrganicIconName.sleep => _sleep,
      NumuwOrganicIconName.diaper => _diaper,
      NumuwOrganicIconName.food => _food,
      NumuwOrganicIconName.medicine => _medicine,
      NumuwOrganicIconName.vaccine => _vaccine,
      NumuwOrganicIconName.temperature => _temperature,
      NumuwOrganicIconName.weight => _weight,
      NumuwOrganicIconName.height => _height,
      NumuwOrganicIconName.headCircumference => _head,
      NumuwOrganicIconName.growth => _growth,
      NumuwOrganicIconName.calendar => _calendar,
      NumuwOrganicIconName.doctor => _doctor,
      NumuwOrganicIconName.hospitalBag => _hospitalBag,
      NumuwOrganicIconName.tasks => _tasks,
      NumuwOrganicIconName.shopping => _shopping,
      NumuwOrganicIconName.camera => _camera,
      NumuwOrganicIconName.documents => _documents,
      NumuwOrganicIconName.aiAssistant => _ai,
      NumuwOrganicIconName.microphone => _microphone,
      NumuwOrganicIconName.chat => _chat,
      NumuwOrganicIconName.family => _family,
      NumuwOrganicIconName.father => _father,
      NumuwOrganicIconName.pregnancy => _pregnancy,
      NumuwOrganicIconName.newborn => _newborn,
      NumuwOrganicIconName.babyItems => _babyItems,
      NumuwOrganicIconName.nutrition => _nutrition,
      NumuwOrganicIconName.water => _water,
      NumuwOrganicIconName.motherHealth => _motherHealth,
      NumuwOrganicIconName.relaxation => _relaxation,
      NumuwOrganicIconName.milestones => _milestones,
      NumuwOrganicIconName.articles => _articles,
      NumuwOrganicIconName.tips => _tips,
      NumuwOrganicIconName.notifications => _notifications,
      NumuwOrganicIconName.privacy => _privacy,
      NumuwOrganicIconName.search => _search,
      NumuwOrganicIconName.filter => _filter,
      NumuwOrganicIconName.edit => _edit,
      NumuwOrganicIconName.add => _add,
      NumuwOrganicIconName.delete => _delete,
      NumuwOrganicIconName.share => _share,
      NumuwOrganicIconName.download => _download,
      NumuwOrganicIconName.more => _more,
      NumuwOrganicIconName.settings => _settings,
      NumuwOrganicIconName.help => _help,
      NumuwOrganicIconName.favorite => _favorite,
      NumuwOrganicIconName.play => _play,
      NumuwOrganicIconName.pause => _pause,
      NumuwOrganicIconName.done => _done,
      NumuwOrganicIconName.cancel => _cancel,
      NumuwOrganicIconName.error => _error,
      NumuwOrganicIconName.home => _home,
      NumuwOrganicIconName.account => _account,
    };

    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
      <circle cx="32" cy="32" r="30" fill="$_cream"/>
      $body
    </svg>''';
  }

  static const _leaf = '''
    <path d="M47 46c5-8 11-9 14-7-2 7-7 11-14 10" fill="$_mint"/>
    <path d="M49 47c3-3 6-5 10-7" stroke="$_sage" stroke-width="2" stroke-linecap="round"/>
  ''';

  static const _breastfeeding = '''
    <path d="M18 43c0-13 6-24 16-24 7 0 12 5 12 12 0 6-4 10-9 12" fill="$_peach" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    <circle cx="31" cy="20" r="6" fill="$_sand" stroke="$_ink" stroke-width="2.2"/>
    <circle cx="39" cy="37" r="6" fill="$_blue" stroke="$_ink" stroke-width="2.2"/>
    <path d="M28 36c4-4 8-5 13-3M24 31c4 7 9 12 16 14" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _bottle = '''
    <path d="M26 14h12v8l4 5v22a5 5 0 0 1-5 5H27a5 5 0 0 1-5-5V27l4-5v-8Z" fill="$_blue" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M27 10h10v5H27z" fill="$_peach" stroke="$_ink" stroke-width="2.2"/>
    <path d="M25 37h14M25 42h14" stroke="$_cream" stroke-width="2.2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _sleep = '''
    <path d="M42 15a18 18 0 1 0 7 32A20 20 0 0 1 42 15Z" fill="$_lavender" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="m49 18 2 4 4 .6-3 3 .7 4.2-3.7-2-3.8 2 .8-4.2-3.1-3 4.2-.6 1.9-4Z" fill="$_peach"/>
    $_leaf
  ''';

  static const _diaper = '''
    <path d="M16 20h32v17c0 10-7 17-16 17s-16-7-16-17V20Z" fill="$_mint" stroke="$_ink" stroke-width="2.4"/>
    <path d="M16 25c6 1 10 4 12 10h8c2-6 6-9 12-10M25 21v6M39 21v6" stroke="$_ink" stroke-width="2.2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _food = '''
    <path d="M15 38c2 11 8 16 17 16s15-5 17-16H15Z" fill="$_peach" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M35 34 48 18" stroke="$_ink" stroke-width="3" stroke-linecap="round"/>
    <circle cx="50" cy="16" r="4" fill="$_blue" stroke="$_ink" stroke-width="2"/>
    <path d="M22 34c3-6 7-9 12-8 4 1 7 4 8 8" fill="$_sand"/>
    $_leaf
  ''';

  static const _medicine = '''
    <rect x="20" y="15" width="24" height="38" rx="6" fill="$_sage" stroke="$_ink" stroke-width="2.4"/>
    <path d="M24 10h16v7H24z" fill="$_sand" stroke="$_ink" stroke-width="2.2"/>
    <path d="M32 27v14M25 34h14" stroke="$_cream" stroke-width="3.2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _vaccine = '''
    <path d="m19 43 24-24 6 6-24 24-6-6Z" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <path d="m40 17 7-7M47 24l7-7M18 48l-5 5M17 38l9 9" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    <path d="M27 35 22 30M32 30l-5-5M37 25l-5-5" stroke="$_cream" stroke-width="2"/>
    $_leaf
  ''';

  static const _temperature = '''
    <path d="M29 14a5 5 0 0 1 10 0v24a11 11 0 1 1-10 0V14Z" fill="$_cream" stroke="$_ink" stroke-width="2.5"/>
    <path d="M34 22v21" stroke="$_coral" stroke-width="4" stroke-linecap="round"/>
    <circle cx="34" cy="46" r="6" fill="$_coral"/>
    $_leaf
  ''';

  static const _weight = '''
    <path d="M14 24h36l-4 28H18l-4-28Z" fill="$_mint" stroke="$_ink" stroke-width="2.5" stroke-linejoin="round"/>
    <path d="M24 24a8 8 0 0 1 16 0" stroke="$_ink" stroke-width="2.5"/>
    <path d="M32 31v7l5-3" stroke="$_ink" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>
    $_leaf
  ''';

  static const _height = '''
    <rect x="26" y="9" width="12" height="46" rx="3" fill="$_sand" stroke="$_ink" stroke-width="2.4"/>
    <path d="M27 16h7M27 23h4M27 30h7M27 37h4M27 44h7" stroke="$_ink" stroke-width="2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _head = '''
    <path d="M18 38c0-13 6-23 17-23 10 0 17 8 17 19 0 7-3 13-9 17H24c-4-3-6-8-6-13Z" fill="$_sand" stroke="$_ink" stroke-width="2.4"/>
    <path d="M15 30c10-3 24-3 38 0" stroke="$_blue" stroke-width="3" stroke-dasharray="3 3" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _growth = '''
    <path d="M14 49h38" stroke="$_ink" stroke-width="2.5" stroke-linecap="round"/>
    <rect x="18" y="35" width="7" height="14" rx="2" fill="$_mint"/>
    <rect x="29" y="28" width="7" height="21" rx="2" fill="$_blue"/>
    <rect x="40" y="19" width="7" height="30" rx="2" fill="$_peach"/>
    <path d="m18 31 11-8 9 2 10-12" stroke="$_ink" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>
    $_leaf
  ''';

  static const _calendar = '''
    <rect x="13" y="17" width="38" height="35" rx="6" fill="$_cream" stroke="$_ink" stroke-width="2.4"/>
    <path d="M13 27h38M22 12v10M42 12v10" stroke="$_ink" stroke-width="2.5" stroke-linecap="round"/>
    <path d="m25 39 5 5 10-11" stroke="$_coral" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    $_leaf
  ''';

  static const _doctor = '''
    <circle cx="32" cy="20" r="8" fill="$_sand" stroke="$_ink" stroke-width="2.4"/>
    <path d="M18 52c1-12 6-19 14-19s13 7 14 19" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <path d="M24 34c0 8 2 12 8 12s8-4 8-12M20 40h-5v8h7" stroke="$_ink" stroke-width="2.2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _hospitalBag = '''
    <rect x="13" y="22" width="38" height="30" rx="6" fill="$_lavender" stroke="$_ink" stroke-width="2.5"/>
    <path d="M24 22v-5a8 8 0 0 1 16 0v5M32 31v13M25 37h14" stroke="$_ink" stroke-width="2.8" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _tasks = '''
    <rect x="18" y="13" width="31" height="40" rx="5" fill="$_cream" stroke="$_ink" stroke-width="2.4"/>
    <path d="M25 13v-3h15v3M24 27l3 3 5-6M35 27h8M24 39l3 3 5-6M35 39h8" stroke="$_ink" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
    $_leaf
  ''';

  static const _shopping = '''
    <path d="M16 25h32l-4 26H20l-4-26Z" fill="$_peach" stroke="$_ink" stroke-width="2.4"/>
    <path d="M24 25c0-8 3-12 8-12s8 4 8 12" stroke="$_ink" stroke-width="2.4"/>
    <path d="M32 33c4-4 8-4 11-2-1 6-5 9-11 10-6-1-10-4-11-10 3-2 7-2 11 2Z" fill="$_cream"/>
    $_leaf
  ''';

  static const _camera = '''
    <path d="M14 24a5 5 0 0 1 5-5h8l3-5h8l3 5h4a5 5 0 0 1 5 5v23a5 5 0 0 1-5 5H19a5 5 0 0 1-5-5V24Z" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <circle cx="32" cy="35" r="9" fill="$_cream" stroke="$_ink" stroke-width="2.4"/>
    <circle cx="32" cy="35" r="4" fill="$_sage"/>
    $_leaf
  ''';

  static const _documents = '''
    <rect x="18" y="16" width="28" height="36" rx="4" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <rect x="23" y="11" width="28" height="36" rx="4" fill="$_cream" stroke="$_ink" stroke-width="2.4"/>
    <path d="M29 22h15M29 29h15M29 36h10" stroke="$_sage" stroke-width="2.3" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _ai = '''
    <rect x="13" y="17" width="38" height="34" rx="12" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <path d="M24 17v-5M40 17v-5M32 12V8" stroke="$_ink" stroke-width="2.2" stroke-linecap="round"/>
    <circle cx="25" cy="32" r="3" fill="$_ink"/><circle cx="39" cy="32" r="3" fill="$_ink"/>
    <path d="M25 41c4 3 10 3 14 0" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _microphone = '''
    <rect x="25" y="12" width="14" height="28" rx="7" fill="$_lavender" stroke="$_ink" stroke-width="2.4"/>
    <path d="M19 31c0 9 5 14 13 14s13-5 13-14M32 45v9M24 54h16" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _chat = '''
    <path d="M13 18h38v26a7 7 0 0 1-7 7H29l-9 6 2-6h-2a7 7 0 0 1-7-7V18Z" fill="$_lavender" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <circle cx="24" cy="34" r="2.5" fill="$_ink"/><circle cx="32" cy="34" r="2.5" fill="$_ink"/><circle cx="40" cy="34" r="2.5" fill="$_ink"/>
    $_leaf
  ''';

  static const _family = '''
    <circle cx="24" cy="22" r="7" fill="$_peach" stroke="$_ink" stroke-width="2.2"/>
    <circle cx="41" cy="22" r="7" fill="$_blue" stroke="$_ink" stroke-width="2.2"/>
    <circle cx="32" cy="37" r="5" fill="$_sand" stroke="$_ink" stroke-width="2.2"/>
    <path d="M13 52c1-10 5-16 11-16M51 52c-1-10-5-16-10-16M23 52c1-7 4-11 9-11s8 4 9 11" stroke="$_ink" stroke-width="2.5" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _father = '''
    <circle cx="31" cy="18" r="8" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <circle cx="38" cy="37" r="6" fill="$_sand" stroke="$_ink" stroke-width="2.2"/>
    <path d="M17 52c1-15 6-23 14-23 7 0 11 5 13 14M25 37c4 5 8 8 14 9" stroke="$_ink" stroke-width="2.5" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _pregnancy = '''
    <circle cx="29" cy="17" r="7" fill="$_sand" stroke="$_ink" stroke-width="2.3"/>
    <path d="M20 51c-2-12 0-25 9-25 6 0 10 4 11 10 6 2 8 8 6 15H20Z" fill="$_peach" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M37 38c-3 0-6 2-6 5s3 5 6 5 6-2 6-5-3-5-6-5Z" fill="$_cream"/>
    $_leaf
  ''';

  static const _newborn = '''
    <path d="M14 35c6-12 13-18 21-18 9 0 15 6 15 14 0 12-9 20-21 20-7 0-12-5-15-16Z" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <circle cx="37" cy="28" r="7" fill="$_sand" stroke="$_ink" stroke-width="2.2"/>
    <path d="M30 22c2-4 5-6 8-6" stroke="$_ink" stroke-width="2.1" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _babyItems = '''
    <path d="M19 22h9l4 6 4-6h9l5 9-7 5v16H21V36l-7-5 5-9Z" fill="$_blue" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M28 22c0 4 1 6 4 6s4-2 4-6" stroke="$_ink" stroke-width="2.2"/>
    $_leaf
  ''';

  static const _nutrition = '''
    <circle cx="24" cy="34" r="11" fill="$_peach" stroke="$_ink" stroke-width="2.3"/>
    <circle cx="39" cy="34" r="10" fill="$_sage" stroke="$_ink" stroke-width="2.3"/>
    <path d="M27 21c-1-6 2-10 7-11M35 15c3-3 7-4 10-2-1 5-5 7-10 7" stroke="$_ink" stroke-width="2.2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _water = '''
    <path d="M32 10c10 13 15 21 15 29a15 15 0 1 1-30 0c0-8 5-16 15-29Z" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>
    <path d="M23 41c1 5 4 8 9 8" stroke="$_cream" stroke-width="2.4" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _motherHealth = '''
    <path d="M32 50S13 39 13 25c0-7 5-11 11-11 4 0 7 2 8 6 1-4 4-6 8-6 7 0 11 4 11 11 0 14-19 25-19 25Z" fill="$_peach" stroke="$_ink" stroke-width="2.4"/>
    <path d="M21 33h7l3-7 4 13 3-6h6" stroke="$_cream" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>
    $_leaf
  ''';

  static const _relaxation = '''
    <path d="M32 47c-9-4-14-11-14-19 7 0 12 3 14 9 2-6 7-9 14-9 0 8-5 15-14 19Z" fill="$_lavender" stroke="$_ink" stroke-width="2.3"/>
    <path d="M32 47c-6-7-7-15 0-26 7 11 6 19 0 26Z" fill="$_blue" stroke="$_ink" stroke-width="2.3"/>
    <path d="M32 47v7" stroke="$_ink" stroke-width="2.3" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _milestones = '''
    <path d="M15 51c4-8 10-13 17-13s13 5 17 13" fill="$_mint" stroke="$_ink" stroke-width="2.3"/>
    <path d="M24 37c-3-7-1-14 5-18 6 4 8 11 5 18M34 29c3-7 8-10 14-9 0 7-4 12-12 15M27 29c-6-2-10-6-11-12 7-1 12 3 15 10" stroke="$_ink" stroke-width="2.2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _articles = '''
    <path d="M12 17h18c4 0 7 3 7 7v29H19c-4 0-7-3-7-7V17ZM52 17H34c-4 0-7 3-7 7v29h18c4 0 7-3 7-7V17Z" fill="$_cream" stroke="$_ink" stroke-width="2.3" stroke-linejoin="round"/>
    <path d="M18 27h11M18 34h11M35 27h11M35 34h11" stroke="$_sage" stroke-width="2" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _tips = '''
    <path d="M21 30a11 11 0 1 1 22 0c0 6-4 8-6 12H27c-2-4-6-6-6-12Z" fill="$_sand" stroke="$_ink" stroke-width="2.4"/>
    <path d="M27 47h10M29 52h6" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    <path d="M32 12V7M14 30H9M55 30h-5M18 16l-4-4M46 16l4-4" stroke="$_peach" stroke-width="2.4" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _notifications = '''
    <path d="M19 43h26l-4-7V25c0-6-4-11-9-11s-9 5-9 11v11l-4 7Z" fill="$_sand" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M27 47c1 5 9 5 10 0" stroke="$_ink" stroke-width="2.4" stroke-linecap="round"/>
    $_leaf
  ''';

  static const _privacy = '''
    <path d="M32 10c8 6 14 7 19 8v13c0 12-7 20-19 24-12-4-19-12-19-24V18c5-1 11-2 19-8Z" fill="$_blue" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>
    <rect x="25" y="29" width="14" height="12" rx="3" fill="$_cream" stroke="$_ink" stroke-width="2"/>
    <path d="M28 29v-3a4 4 0 0 1 8 0v3" stroke="$_ink" stroke-width="2"/>
    $_leaf
  ''';

  static const _search = '''<circle cx="29" cy="29" r="14" stroke="$_ink" stroke-width="3"/><path d="m39 39 11 11" stroke="$_ink" stroke-width="3" stroke-linecap="round"/>$_leaf''';
  static const _filter = '''<path d="M13 19h38M20 32h24M27 45h10" stroke="$_ink" stroke-width="3" stroke-linecap="round"/><circle cx="25" cy="19" r="4" fill="$_peach"/><circle cx="39" cy="32" r="4" fill="$_blue"/><circle cx="31" cy="45" r="4" fill="$_mint"/>$_leaf''';
  static const _edit = '''<path d="m18 44 3-12 20-20 10 10-20 20-13 2Z" fill="$_sand" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/><path d="m37 16 10 10" stroke="$_ink" stroke-width="2.4"/>$_leaf''';
  static const _add = '''<circle cx="32" cy="32" r="18" fill="$_sage" stroke="$_ink" stroke-width="2.4"/><path d="M32 22v20M22 32h20" stroke="$_cream" stroke-width="3" stroke-linecap="round"/>$_leaf''';
  static const _delete = '''<path d="M20 21h24l-2 31H22l-2-31Z" fill="$_sand" stroke="$_ink" stroke-width="2.4"/><path d="M17 21h30M26 21v-6h12v6M28 29v14M36 29v14" stroke="$_ink" stroke-width="2.3" stroke-linecap="round"/>$_leaf''';
  static const _share = '''<circle cx="19" cy="32" r="6" fill="$_mint" stroke="$_ink" stroke-width="2.2"/><circle cx="44" cy="18" r="6" fill="$_peach" stroke="$_ink" stroke-width="2.2"/><circle cx="44" cy="46" r="6" fill="$_blue" stroke="$_ink" stroke-width="2.2"/><path d="m24 29 14-8M24 35l14 8" stroke="$_ink" stroke-width="2.4"/>$_leaf''';
  static const _download = '''<path d="M32 12v29M22 31l10 10 10-10M17 48h30" stroke="$_ink" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>$_leaf''';
  static const _more = '''<circle cx="18" cy="32" r="4" fill="$_ink"/><circle cx="32" cy="32" r="4" fill="$_ink"/><circle cx="46" cy="32" r="4" fill="$_ink"/>$_leaf''';
  static const _settings = '''<circle cx="32" cy="32" r="8" fill="$_sand" stroke="$_ink" stroke-width="2.4"/><path d="M32 12v6M32 46v6M12 32h6M46 32h6M18 18l4 4M42 42l4 4M46 18l-4 4M22 42l-4 4" stroke="$_ink" stroke-width="3" stroke-linecap="round"/>$_leaf''';
  static const _help = '''<circle cx="32" cy="31" r="18" fill="$_blue" stroke="$_ink" stroke-width="2.4"/><path d="M26 26c0-4 3-7 7-7 5 0 8 3 8 7 0 7-8 6-8 13M33 47h.01" stroke="$_cream" stroke-width="3" stroke-linecap="round"/>$_leaf''';
  static const _favorite = '''<path d="M32 50S13 39 13 25c0-7 5-11 11-11 4 0 7 2 8 6 1-4 4-6 8-6 7 0 11 4 11 11 0 14-19 25-19 25Z" fill="$_peach" stroke="$_ink" stroke-width="2.4"/>$_leaf''';
  static const _play = '''<circle cx="32" cy="32" r="18" fill="$_mint" stroke="$_ink" stroke-width="2.4"/><path d="m28 23 13 9-13 9V23Z" fill="$_ink"/>$_leaf''';
  static const _pause = '''<circle cx="32" cy="32" r="18" fill="$_lavender" stroke="$_ink" stroke-width="2.4"/><path d="M26 23v18M38 23v18" stroke="$_ink" stroke-width="4" stroke-linecap="round"/>$_leaf''';
  static const _done = '''<circle cx="32" cy="32" r="19" fill="$_sage" stroke="$_ink" stroke-width="2.4"/><path d="m22 32 7 7 14-16" stroke="$_cream" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>$_leaf''';
  static const _cancel = '''<circle cx="32" cy="32" r="19" fill="$_sand" stroke="$_ink" stroke-width="2.4"/><path d="m24 24 16 16M40 24 24 40" stroke="$_ink" stroke-width="3" stroke-linecap="round"/>$_leaf''';
  static const _error = '''<path d="m32 11 22 40H10L32 11Z" fill="$_peach" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/><path d="M32 25v12M32 44h.01" stroke="$_cream" stroke-width="3.2" stroke-linecap="round"/>$_leaf''';
  static const _home = '''<path d="m13 31 19-17 19 17v20H38V39H26v12H13V31Z" fill="$_mint" stroke="$_ink" stroke-width="2.4" stroke-linejoin="round"/>$_leaf''';
  static const _account = '''<circle cx="32" cy="23" r="9" fill="$_sand" stroke="$_ink" stroke-width="2.4"/><path d="M16 52c1-11 7-17 16-17s15 6 16 17" fill="$_blue" stroke="$_ink" stroke-width="2.4"/>$_leaf''';
}
