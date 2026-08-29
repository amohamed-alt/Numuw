import 'package:flutter/material.dart';

import 'core/theme/numuw_theme.dart';
import 'design/numuw_motion_widgets.dart';
import 'design/numuw_organic_icons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NumuwReviewFixedApp());
}

class NumuwReviewFixedApp extends StatefulWidget {
  const NumuwReviewFixedApp({super.key});

  @override
  State<NumuwReviewFixedApp> createState() => _NumuwReviewFixedAppState();
}

class _NumuwReviewFixedAppState extends State<NumuwReviewFixedApp> {
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
                child: _BottomNav(
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
        0 => _ReviewPage(
            key: const ValueKey('home-page'),
            title: 'صباح الخير يا ماما',
            subtitle: 'كل حاجة تخص سلمى النهارده في مكان واحد',
            icon: NumuwOrganicIconName.home,
            action: IconButton(
              onPressed: () => setState(() => night = !night),
              icon: const NumuwOrganicIcon(
                NumuwOrganicIconName.relaxation,
                size: 30,
              ),
            ),
            children: const [
              _HeroCard(),
              SizedBox(height: 18),
              _Section('ملخص اليوم', NumuwOrganicIconName.calendar),
              SizedBox(height: 10),
              _MetricGrid(),
              SizedBox(height: 18),
              _Section('النشاط الأخير', NumuwOrganicIconName.calendar),
              SizedBox(height: 10),
              _Card(
                child: Column(
                  children: [
                    _RowItem('رضاعة', '10:40 ص · 120 مل', NumuwOrganicIconName.breastfeeding),
                    Divider(height: 22),
                    _RowItem('حفاضة', '11:15 ص · مبللة', NumuwOrganicIconName.diaper),
                    Divider(height: 22),
                    _RowItem('نوم', '8:10 إلى 9:35 ص', NumuwOrganicIconName.sleep),
                  ],
                ),
              ),
            ],
          ),
        1 => const _ReviewPage(
            key: ValueKey('quick-log-page'),
            title: 'تسجيل سريع',
            subtitle: 'سجلي أهم أحداث يوم سلمى بأقل عدد من الخطوات',
            icon: NumuwOrganicIconName.add,
            children: [
              _ActionGrid(),
              SizedBox(height: 16),
              _Card(
                child: _RowItem(
                  'رضاعة شغالة الآن',
                  '12:34 دقيقة · الجهة اليمنى',
                  NumuwOrganicIconName.breastfeeding,
                ),
              ),
            ],
          ),
        2 => const _ReviewPage(
            key: ValueKey('child-page'),
            title: 'سلمى',
            subtitle: '3 شهور و12 يوم · ملف الطفل',
            icon: NumuwOrganicIconName.newborn,
            children: [
              _Section('النمو', NumuwOrganicIconName.growth),
              SizedBox(height: 10),
              _Card(
                child: Row(
                  children: [
                    NumuwOrganicIcon(NumuwOrganicIconName.growth, size: 52),
                    SizedBox(width: 12),
                    Expanded(child: _Stat('الوزن', '6.2 كجم')),
                    Expanded(child: _Stat('الطول', '61 سم')),
                  ],
                ),
              ),
              SizedBox(height: 18),
              _Section('التطعيمات', NumuwOrganicIconName.vaccine),
              SizedBox(height: 10),
              _Card(
                child: Column(
                  children: [
                    _RowItem('تطعيم الشهرين', 'تم في 12 أغسطس', NumuwOrganicIconName.done),
                    Divider(height: 22),
                    _RowItem('تطعيم 4 شهور', 'متبقي 14 يوم', NumuwOrganicIconName.vaccine),
                  ],
                ),
              ),
              SizedBox(height: 18),
              _Section('محطات النمو', NumuwOrganicIconName.milestones),
              SizedBox(height: 10),
              _Card(
                child: _RowItem('ترفع الرأس بثبات', 'تم تحقيقها', NumuwOrganicIconName.milestones),
              ),
            ],
          ),
        3 => _ReviewPage(
            key: const ValueKey('family-page'),
            title: 'العائلة',
            subtitle: 'متابعة مشتركة بصلاحيات واضحة',
            icon: NumuwOrganicIconName.family,
            children: [
              const _Card(
                child: Column(
                  children: [
                    _RowItem('أنتِ', 'مالك الملف · كل الصلاحيات', NumuwOrganicIconName.account),
                    Divider(height: 22),
                    _RowItem('بابا', 'ولي أمر · التسجيل والمتابعة', NumuwOrganicIconName.father),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _Section('دعوة فرد من العائلة', NumuwOrganicIconName.share),
              const SizedBox(height: 10),
              _Card(
                child: Column(
                  children: [
                    const TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني')),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('إنشاء دعوة'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        4 => _ReviewPage(
            key: const ValueKey('assistant-page'),
            title: 'مساعد نُمُوّ',
            subtitle: 'للتنظيم والتلخيص، وليس بديلاً عن الطبيب',
            icon: NumuwOrganicIconName.aiAssistant,
            children: [
              const _Card(
                child: _RowItem(
                  'سلامة أولاً',
                  'في أي حالة طارئة تواصلي مع الطوارئ فوراً.',
                  NumuwOrganicIconName.privacy,
                ),
              ),
              const SizedBox(height: 14),
              const _Bubble('لخصي يوم سلمى عشان أبعت للدكتور.', true),
              const SizedBox(height: 9),
              const _Bubble(
                'تم تسجيل 5 رضعات، 4 حفاضات و3 ساعات و20 دقيقة نوم. أقدر أرتبهم في ملخص واضح بدون تشخيص أو تغيير علاج.',
                false,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    onPressed: () {},
                    avatar: const NumuwOrganicIcon(NumuwOrganicIconName.aiAssistant, size: 24),
                    label: const Text('ملخص اليوم'),
                  ),
                  ActionChip(
                    onPressed: () {},
                    avatar: const NumuwOrganicIcon(NumuwOrganicIconName.documents, size: 24),
                    label: const Text('تقرير الطبيب'),
                  ),
                  ActionChip(
                    onPressed: () {},
                    avatar: const NumuwOrganicIcon(NumuwOrganicIconName.doctor, size: 24),
                    label: const Text('صياغة سؤال'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(hintText: 'اكتبي سؤالك هنا...')),
            ],
          ),
        _ => _ReviewPage(
            key: const ValueKey('more-page'),
            title: 'المزيد',
            subtitle: 'الحساب، التقارير، الخصوصية وإعدادات نُمُوّ',
            icon: NumuwOrganicIconName.more,
            children: [
              const _Card(
                child: Column(
                  children: [
                    _RowItem('تقارير الطبيب', 'PDF', NumuwOrganicIconName.documents),
                    Divider(height: 22),
                    _RowItem('الإشعارات', 'مفعلة', NumuwOrganicIconName.notifications),
                    Divider(height: 22),
                    _RowItem('الخصوصية والأمان', 'محمي', NumuwOrganicIconName.privacy),
                    Divider(height: 22),
                    _RowItem('الاشتراك', 'Premium', NumuwOrganicIconName.favorite),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Card(
                child: Row(
                  children: [
                    const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 42),
                    const SizedBox(width: 11),
                    const Expanded(child: Text('الوضع الليلي', style: TextStyle(fontWeight: FontWeight.w900))),
                    Switch(value: night, onChanged: (_) => setState(() => night = !night)),
                  ],
                ),
              ),
            ],
          ),
      };
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onChanged});
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
          for (var i = 0; i < _NumuwReviewFixedAppState.tabs.length; i++)
            Expanded(
              child: NumuwPressable(
                semanticLabel: _NumuwReviewFixedAppState.tabs[i].$1,
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
                        _NumuwReviewFixedAppState.tabs[i].$2,
                        size: selected == i ? 28 : 24,
                        semanticLabel: _NumuwReviewFixedAppState.tabs[i].$1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _NumuwReviewFixedAppState.tabs[i].$1,
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

class _ReviewPage extends StatelessWidget {
  const _ReviewPage({super.key, required this.title, required this.subtitle, required this.icon, required this.children, this.action});
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
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
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
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
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context) => _Card(
        child: Row(
          children: [
            const NumuwOrganicIcon(NumuwOrganicIconName.newborn, size: 66),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سلمى', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const Text('3 شهور و12 يوم'),
                  const SizedBox(height: 10),
                  ClipRRect(borderRadius: BorderRadius.circular(99), child: const LinearProgressIndicator(value: .72, minHeight: 8)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;
  @override
  Widget build(BuildContext context) => Row(children: [
        NumuwOrganicIcon(icon, size: 31),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      ]);
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();
  @override
  Widget build(BuildContext context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: const [
          _Metric('آخر رضعة', '10:40 ص', NumuwOrganicIconName.breastfeeding),
          _Metric('النوم', '3 س 20 د', NumuwOrganicIconName.sleep),
          _Metric('الحفاضة', '11:15 ص', NumuwOrganicIconName.diaper),
          _Metric('التطعيم', '12 سبتمبر', NumuwOrganicIconName.vaccine),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric(this.title, this.value, this.icon);
  final String title;
  final String value;
  final NumuwOrganicIconName icon;
  @override
  Widget build(BuildContext context) => _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          NumuwOrganicIcon(icon, size: 38),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();
  @override
  Widget build(BuildContext context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
        children: const [
          _Action('رضاعة', NumuwOrganicIconName.breastfeeding),
          _Action('شفط', NumuwOrganicIconName.bottle),
          _Action('نوم', NumuwOrganicIconName.sleep),
          _Action('حفاضة', NumuwOrganicIconName.diaper),
          _Action('طعام', NumuwOrganicIconName.food),
          _Action('دواء', NumuwOrganicIconName.medicine),
          _Action('حرارة', NumuwOrganicIconName.temperature),
          _Action('ملاحظة', NumuwOrganicIconName.edit),
        ],
      );
}

class _Action extends StatelessWidget {
  const _Action(this.title, this.icon);
  final String title;
  final NumuwOrganicIconName icon;
  @override
  Widget build(BuildContext context) => _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          NumuwOrganicIcon(icon, size: 48),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          Text('تسجيل سريع', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        ]),
      );
}

class _RowItem extends StatelessWidget {
  const _RowItem(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;
  @override
  Widget build(BuildContext context) => Row(children: [
        NumuwOrganicIcon(icon, size: 42),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        ])),
      ]);
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w900))]);
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text, this.mine);
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
