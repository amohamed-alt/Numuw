import 'package:flutter/material.dart';

import 'core/theme/numuw_theme.dart';
import 'design/numuw_motion_widgets.dart';
import 'design/numuw_organic_icons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NumuwReviewApp());
}

class NumuwReviewApp extends StatefulWidget {
  const NumuwReviewApp({super.key});

  @override
  State<NumuwReviewApp> createState() => _NumuwReviewAppState();
}

class _NumuwReviewAppState extends State<NumuwReviewApp> {
  int index = 0;
  bool night = false;

  static const tabs = <(String, NumuwOrganicIconName)>[
    ('اليوم', NumuwOrganicIconName.home),
    ('تسجيل', NumuwOrganicIconName.add),
    ('الطفل', NumuwOrganicIconName.newborn),
    ('العائلة', NumuwOrganicIconName.family),
    ('المساعد', NumuwOrganicIconName.aiAssistant),
    ('المزيد', NumuwOrganicIconName.more),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildNumuwTheme(night: night),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SizedBox.expand(
                  child: AnimatedSwitcher(
                    duration: NumuwMotionSpec.quick,
                    child: _page(index),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _ReviewNav(
                  selected: index,
                  onChanged: (value) => setState(() => index = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(int value) => switch (value) {
    0 => _HomePage(onNight: () => setState(() => night = !night)),
    1 => const _QuickLogPage(),
    2 => const _ChildPage(),
    3 => const _FamilyPage(),
    4 => const _AssistantPage(),
    _ => _MorePage(night: night, onNight: () => setState(() => night = !night)),
  };
}

class _ReviewNav extends StatelessWidget {
  const _ReviewNav({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('review-navigation'),
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 9),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: .45))),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _NumuwReviewAppState.tabs.length; i++)
            Expanded(
              child: NumuwPressable(
                semanticLabel: _NumuwReviewAppState.tabs[i].$1,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: NumuwMotionSpec.quick,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: selected == i ? scheme.primary.withValues(alpha: .11) : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NumuwOrganicIcon(
                        _NumuwReviewAppState.tabs[i].$2,
                        size: selected == i ? 28 : 24,
                        semanticLabel: _NumuwReviewAppState.tabs[i].$1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _NumuwReviewAppState.tabs[i].$1,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected == i ? FontWeight.w900 : FontWeight.w600,
                          color: selected == i ? scheme.primary : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.subtitle, required this.icon, required this.children, this.action});
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: ValueKey(title),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        NumuwEntrance(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumuwOrganicIcon(icon, size: 48, semanticLabel: title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                      if (action != null) action!,
                    ]),
                    const SizedBox(height: 3),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withValues(alpha: .45)),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? const [BoxShadow(color: Color(0x0C000000), blurRadius: 22, offset: Offset(0, 8))]
            : const [],
      ),
      child: child,
    );
    return onTap == null ? card : NumuwPressable(onTap: onTap, child: card);
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    NumuwOrganicIcon(icon, size: 31, semanticLabel: label),
    const SizedBox(width: 8),
    Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
  ]);
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onNight});
  final VoidCallback onNight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Page(
      title: 'صباح الخير يا ماما',
      subtitle: 'كل حاجة تخص سلمى النهارده في مكان واحد',
      icon: NumuwOrganicIconName.home,
      action: IconButton(onPressed: onNight, tooltip: 'الوضع الليلي', icon: const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 30)),
      children: [
        _Card(child: Row(children: [
          const NumuwOrganicIcon(NumuwOrganicIconName.newborn, size: 66, semanticLabel: 'سلمى'),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('سلمى', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            Text('3 شهور و12 يوم', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(99), child: const LinearProgressIndicator(value: .72, minHeight: 8)),
            const SizedBox(height: 5),
            Text('يوم متوازن', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
          ])),
        ])),
        const SizedBox(height: 18),
        const _Section('ملخص اليوم', NumuwOrganicIconName.calendar),
        const SizedBox(height: 11),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: const [
            _Metric('آخر رضعة', '10:40 ص', '120 مل', NumuwOrganicIconName.breastfeeding),
            _Metric('النوم', '3 س 20 د', 'اليوم', NumuwOrganicIconName.sleep),
            _Metric('الحفاضة', '11:15 ص', 'آخر تغيير', NumuwOrganicIconName.diaper),
            _Metric('التطعيم', '12 سبتمبر', 'القادم', NumuwOrganicIconName.vaccine),
          ],
        ),
        const SizedBox(height: 18),
        const _Section('النشاط الأخير', NumuwOrganicIconName.calendar),
        const SizedBox(height: 11),
        const _Card(child: Column(children: [
          _RowItem('رضاعة', '10:40 ص · 120 مل', NumuwOrganicIconName.breastfeeding),
          Divider(height: 22),
          _RowItem('حفاضة', '11:15 ص · مبللة', NumuwOrganicIconName.diaper),
          Divider(height: 22),
          _RowItem('نوم', '8:10 إلى 9:35 ص', NumuwOrganicIconName.sleep),
        ])),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.title, this.value, this.caption, this.icon);
  final String title;
  final String value;
  final String caption;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [NumuwOrganicIcon(icon, size: 39, semanticLabel: title), const Spacer(), Text(caption, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]),
      const Spacer(),
      Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
    ]));
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    NumuwOrganicIcon(icon, size: 43, semanticLabel: title),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
    ])),
  ]);
}

class _QuickLogPage extends StatelessWidget {
  const _QuickLogPage();
  @override
  Widget build(BuildContext context) => _Page(
    title: 'تسجيل سريع',
    subtitle: 'سجلي أهم أحداث يوم سلمى بأقل عدد من الخطوات',
    icon: NumuwOrganicIconName.add,
    children: [
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.12,
        children: const [
          _Action('رضاعة', 'ابدئي مؤقت أو سجلي كمية', NumuwOrganicIconName.breastfeeding),
          _Action('شفط', 'الجهة والكمية', NumuwOrganicIconName.pumping),
          _Action('نوم', 'ابدئي أو أنهي جلسة', NumuwOrganicIconName.sleep),
          _Action('حفاضة', 'مبللة أو متسخة', NumuwOrganicIconName.diaper),
          _Action('طعام', 'النوع والكمية', NumuwOrganicIconName.food),
          _Action('دواء', 'الاسم والجرعة', NumuwOrganicIconName.medicine),
          _Action('حرارة', 'سجلي القراءة', NumuwOrganicIconName.temperature),
          _Action('ملاحظة', 'أي حاجة مهمة', NumuwOrganicIconName.notes),
        ],
      ),
      const SizedBox(height: 16),
      const _Card(child: _RowItem('رضاعة شغالة الآن', '12:34 دقيقة · الجهة اليمنى', NumuwOrganicIconName.breastfeeding)),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => _Card(
    onTap: () {},
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NumuwOrganicIcon(icon, size: 48, semanticLabel: title),
      const Spacer(),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      Text(subtitle, maxLines: 2, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  );
}

class _ChildPage extends StatelessWidget {
  const _ChildPage();
  @override
  Widget build(BuildContext context) => const _Page(
    title: 'سلمى',
    subtitle: '3 شهور و12 يوم · ملف الطفل',
    icon: NumuwOrganicIconName.newborn,
    children: [
      _Section('النمو', NumuwOrganicIconName.growth),
      SizedBox(height: 10),
      _Card(child: Row(children: [
        NumuwOrganicIcon(NumuwOrganicIconName.growth, size: 50), SizedBox(width: 12),
        Expanded(child: _Stat('الوزن', '6.2 كجم', '+320 جم')),
        Expanded(child: _Stat('الطول', '61 سم', '+2 سم')),
      ])),
      SizedBox(height: 18),
      _Section('التطعيمات', NumuwOrganicIconName.vaccine),
      SizedBox(height: 10),
      _Card(child: Column(children: [
        _RowItem('تطعيم الشهرين', 'تم في 12 أغسطس', NumuwOrganicIconName.done),
        Divider(height: 22),
        _RowItem('تطعيم 4 شهور', 'متبقي 14 يوم', NumuwOrganicIconName.vaccine),
      ])),
      SizedBox(height: 18),
      _Section('محطات النمو', NumuwOrganicIconName.milestones),
      SizedBox(height: 10),
      _Card(child: Column(children: [
        _RowItem('ترفع الرأس بثبات', 'تم تحقيقها', NumuwOrganicIconName.done),
        Divider(height: 22),
        _RowItem('تتبع الأشياء بعينيها', 'قيد المتابعة', NumuwOrganicIconName.milestones),
      ])),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.delta);
  final String label;
  final String value;
  final String delta;
  @override
  Widget build(BuildContext context) => Column(children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), Text(delta, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11))]);
}

class _FamilyPage extends StatelessWidget {
  const _FamilyPage();
  @override
  Widget build(BuildContext context) => _Page(
    title: 'العائلة',
    subtitle: 'المتابعة المشتركة بدون لخبطة في الصلاحيات',
    icon: NumuwOrganicIconName.family,
    children: [
      const _Card(child: Column(children: [
        _RowItem('أنتِ', 'مالك الملف · كل الصلاحيات', NumuwOrganicIconName.mother),
        Divider(height: 22),
        _RowItem('بابا', 'ولي أمر · التسجيل والمتابعة', NumuwOrganicIconName.father),
      ])),
      const SizedBox(height: 18),
      const _Section('دعوة فرد من العائلة', NumuwOrganicIconName.share),
      const SizedBox(height: 10),
      _Card(child: Column(children: [
        const TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني')),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('إنشاء دعوة'))),
      ])),
      const SizedBox(height: 18),
      const _Section('مهام مشتركة', NumuwOrganicIconName.tasks),
      const SizedBox(height: 10),
      const _Card(child: Column(children: [
        _RowItem('شراء حفاضات', 'مسندة لبابا · اليوم', NumuwOrganicIconName.tasks),
        Divider(height: 22),
        _RowItem('تجهيز شنطة الطبيب', 'غداً 5:00 م', NumuwOrganicIconName.calendar),
      ])),
    ],
  );
}

class _AssistantPage extends StatelessWidget {
  const _AssistantPage();
  @override
  Widget build(BuildContext context) => _Page(
    title: 'مساعد نُمُوّ',
    subtitle: 'للتنظيم والتلخيص، وليس بديلاً عن الطبيب',
    icon: NumuwOrganicIconName.aiAssistant,
    children: [
      const _Card(child: _RowItem('سلامة أولاً', 'في أي حالة طارئة تواصلي مع الطوارئ فوراً ولا تنتظري رد المساعد.', NumuwOrganicIconName.privacy)),
      const SizedBox(height: 14),
      const _Bubble(text: 'لخصي يوم سلمى عشان أبعت للدكتور.', mine: true),
      const SizedBox(height: 9),
      const _Bubble(text: 'تم تسجيل 5 رضعات، 4 حفاضات و3 ساعات و20 دقيقة نوم. أقدر أرتبهم في تقرير واضح للطبيب بدون تشخيص أو تعديل علاج.', mine: false),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ActionChip(onPressed: () {}, avatar: const NumuwOrganicIcon(NumuwOrganicIconName.aiAssistant, size: 24), label: const Text('ملخص اليوم')),
        ActionChip(onPressed: () {}, avatar: const NumuwOrganicIcon(NumuwOrganicIconName.report, size: 24), label: const Text('تقرير الطبيب')),
        ActionChip(onPressed: () {}, avatar: const NumuwOrganicIcon(NumuwOrganicIconName.doctor, size: 24), label: const Text('صياغة سؤال')),
      ]),
      const SizedBox(height: 16),
      const TextField(decoration: InputDecoration(hintText: 'اكتبي سؤالك هنا...')),
    ],
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});
  final String text;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: mine ? scheme.surface : scheme.primary.withValues(alpha: .10),
          border: Border.all(color: scheme.outline.withValues(alpha: .45)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(height: 1.55)),
      ),
    );
  }
}

class _MorePage extends StatelessWidget {
  const _MorePage({required this.night, required this.onNight});
  final bool night;
  final VoidCallback onNight;

  @override
  Widget build(BuildContext context) => _Page(
    title: 'المزيد',
    subtitle: 'الحساب، التقارير، الخصوصية وإعدادات نُمُوّ',
    icon: NumuwOrganicIconName.more,
    children: [
      const _Card(child: Column(children: [
        _RowItem('تقارير الطبيب', 'PDF', NumuwOrganicIconName.report),
        Divider(height: 22),
        _RowItem('الإشعارات', 'مفعلة', NumuwOrganicIconName.notifications),
        Divider(height: 22),
        _RowItem('الخصوصية والأمان', 'محمي', NumuwOrganicIconName.privacy),
        Divider(height: 22),
        _RowItem('الاشتراك', 'Premium', NumuwOrganicIconName.premium),
      ])),
      const SizedBox(height: 16),
      _Card(onTap: onNight, child: Row(children: [
        const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 42),
        const SizedBox(width: 11),
        const Expanded(child: Text('الوضع الليلي', style: TextStyle(fontWeight: FontWeight.w900))),
        Switch(value: night, onChanged: (_) => onNight()),
      ])),
    ],
  );
}
