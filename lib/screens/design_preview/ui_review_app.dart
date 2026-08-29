import 'package:flutter/material.dart';

import '../../core/theme/numuw_theme.dart';
import '../../design/numuw_motion_widgets.dart';
import '../../design/numuw_organic_icons.dart';

class NumuwUiReviewApp extends StatefulWidget {
  const NumuwUiReviewApp({super.key});

  @override
  State<NumuwUiReviewApp> createState() => _NumuwUiReviewAppState();
}

class _NumuwUiReviewAppState extends State<NumuwUiReviewApp> {
  int _index = 0;
  bool _night = false;

  static const _tabs = <_ReviewTab>[
    _ReviewTab('اليوم', NumuwOrganicIconName.home),
    _ReviewTab('تسجيل', NumuwOrganicIconName.add),
    _ReviewTab('الطفل', NumuwOrganicIconName.newborn),
    _ReviewTab('العائلة', NumuwOrganicIconName.family),
    _ReviewTab('المساعد', NumuwOrganicIconName.aiAssistant),
    _ReviewTab('المزيد', NumuwOrganicIconName.more),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildNumuwTheme(night: _night),
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AnimatedSwitcher(
                  duration: NumuwMotionSpec.quick,
                  child: _screenFor(_index),
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _ReviewNavigation(
                  tabs: _tabs,
                  selectedIndex: _index,
                  onChanged: (value) => setState(() => _index = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _screenFor(int index) => switch (index) {
    0 => _HomeReview(onToggleNight: () => setState(() => _night = !_night)),
    1 => const _QuickLogReview(),
    2 => const _ChildReview(),
    3 => const _FamilyReview(),
    4 => const _AssistantReview(),
    _ => _MoreReview(night: _night, onToggleNight: () => setState(() => _night = !_night)),
  };
}

class _ReviewTab {
  const _ReviewTab(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;
}

class _ReviewNavigation extends StatelessWidget {
  const _ReviewNavigation({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<_ReviewTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: .55))),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: NumuwPressable(
                semanticLabel: tabs[i].label,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: NumuwMotionSpec.quick,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? scheme.primary.withValues(alpha: .10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NumuwOrganicIcon(
                        tabs[i].icon,
                        size: selectedIndex == i ? 29 : 25,
                        semanticLabel: tabs[i].label,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tabs[i].label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: selectedIndex == i ? FontWeight.w900 : FontWeight.w600,
                          color: selectedIndex == i ? scheme.primary : scheme.onSurfaceVariant,
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
  const _ReviewPage({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey('review-page'),
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
    children: children,
  );
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NumuwEntrance(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwOrganicIcon(icon, size: 46, semanticLabel: title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: .55)),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? const []
            : const [BoxShadow(color: Color(0x0D000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: child,
    );
    return onTap == null
        ? card
        : NumuwPressable(onTap: onTap, child: card);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      NumuwOrganicIcon(icon, size: 31, semanticLabel: label),
      const SizedBox(width: 8),
      Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
    ],
  );
}

class _HomeReview extends StatelessWidget {
  const _HomeReview({required this.onToggleNight});
  final VoidCallback onToggleNight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ReviewPage(children: [
      _ReviewHeader(
        title: 'صباح الخير يا ماما',
        subtitle: 'كل حاجة تخص سلمى النهارده في مكان واحد',
        icon: NumuwOrganicIconName.home,
        action: IconButton(
          tooltip: 'تغيير الوضع',
          onPressed: onToggleNight,
          icon: const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 30),
        ),
      ),
      const SizedBox(height: 16),
      _ReviewCard(
        child: Row(
          children: [
            const NumuwOrganicIcon(NumuwOrganicIconName.newborn, size: 66, semanticLabel: 'سلمى'),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سلمى', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text('3 شهور و12 يوم', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(value: .72, minHeight: 8),
                  ),
                  const SizedBox(height: 6),
                  Text('يوم متوازن', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const _SectionLabel('ملخص اليوم', NumuwOrganicIconName.calendar),
      const SizedBox(height: 11),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.25,
        children: const [
          _MetricReview('آخر رضعة', '10:40 ص', NumuwOrganicIconName.breastfeeding, '120 مل'),
          _MetricReview('النوم', '3 س 20 د', NumuwOrganicIconName.sleep, 'اليوم'),
          _MetricReview('الحفاضة', '11:15 ص', NumuwOrganicIconName.diaper, 'آخر تغيير'),
          _MetricReview('التطعيم', '12 سبتمبر', NumuwOrganicIconName.vaccine, 'القادم'),
        ],
      ),
      const SizedBox(height: 18),
      const _SectionLabel('اقتراحات اليوم', NumuwOrganicIconName.tips),
      const SizedBox(height: 11),
      Row(
        children: const [
          Expanded(child: _InsightReview('وقت البطن', '5 دقائق بهدوء', NumuwOrganicIconName.milestones)),
          SizedBox(width: 10),
          Expanded(child: _InsightReview('نصيحة صغيرة', 'تابعي نمط الرضعات', NumuwOrganicIconName.tips)),
        ],
      ),
      const SizedBox(height: 18),
      const _SectionLabel('النشاط الأخير', NumuwOrganicIconName.calendar),
      const SizedBox(height: 11),
      const _ReviewCard(
        child: Column(children: [
          _ActivityReview('رضاعة', '10:40 ص · 120 مل', NumuwOrganicIconName.breastfeeding),
          Divider(height: 22),
          _ActivityReview('حفاضة', '11:15 ص · مبللة', NumuwOrganicIconName.diaper),
          Divider(height: 22),
          _ActivityReview('نوم', 'من 8:10 إلى 9:35 ص', NumuwOrganicIconName.sleep),
        ]),
      ),
    ]);
  }
}

class _MetricReview extends StatelessWidget {
  const _MetricReview(this.title, this.value, this.icon, this.caption);
  final String title;
  final String value;
  final NumuwOrganicIconName icon;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ReviewCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            NumuwOrganicIcon(icon, size: 38, semanticLabel: title),
            const Spacer(),
            Text(caption, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ]),
          const Spacer(),
          Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}

class _InsightReview extends StatelessWidget {
  const _InsightReview(this.title, this.body, this.icon);
  final String title;
  final String body;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NumuwOrganicIcon(icon, size: 38, semanticLabel: title),
      const SizedBox(height: 9),
      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.45)),
    ]),
  );
}

class _ActivityReview extends StatelessWidget {
  const _ActivityReview(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    NumuwOrganicIcon(icon, size: 42, semanticLabel: title),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ])),
  ]);
}

class _QuickLogReview extends StatelessWidget {
  const _QuickLogReview();

  @override
  Widget build(BuildContext context) => _ReviewPage(children: [
    const _ReviewHeader(
      title: 'تسجيل سريع',
      subtitle: 'أكتر الحاجات اللي بتسجليها خلال اليوم بضغطة واحدة',
      icon: NumuwOrganicIconName.add,
    ),
    const SizedBox(height: 16),
    GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 11,
      mainAxisSpacing: 11,
      childAspectRatio: 1.25,
      children: const [
        _QuickAction('رضاعة', NumuwOrganicIconName.breastfeeding, 'ابدئي مؤقت أو سجلي كمية'),
        _QuickAction('شفط', NumuwOrganicIconName.bottle, 'كمية ومدة الجلسة'),
        _QuickAction('نوم', NumuwOrganicIconName.sleep, 'ابدئي أو أوقفي المؤقت'),
        _QuickAction('حفاضة', NumuwOrganicIconName.diaper, 'مبللة أو متسخة'),
        _QuickAction('طعام', NumuwOrganicIconName.food, 'الوجبة والتفاعل'),
        _QuickAction('دواء', NumuwOrganicIconName.medicine, 'تسجيل فقط حسب الطبيب'),
        _QuickAction('حرارة', NumuwOrganicIconName.temperature, 'قراءة وملاحظة'),
        _QuickAction('ملاحظة', NumuwOrganicIconName.edit, 'أي تفصيل مهم'),
      ],
    ),
    const SizedBox(height: 20),
    const _SectionLabel('رضاعة جارية', NumuwOrganicIconName.breastfeeding),
    const SizedBox(height: 11),
    _ReviewCard(
      child: Column(children: [
        const NumuwOrganicIcon(NumuwOrganicIconName.breastfeeding, size: 64, semanticLabel: 'رضاعة جارية'),
        const SizedBox(height: 8),
        Text('12:48', textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 5),
        Text('الثدي الأيمن · مستمرة الآن', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.stop_rounded), label: const Text('إيقاف وحفظ')),
      ]),
    ),
  ]);
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.label, this.icon, this.subtitle);
  final String label;
  final NumuwOrganicIconName icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    onTap: () {},
    padding: const EdgeInsets.all(13),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NumuwOrganicIcon(icon, size: 45, semanticLabel: label),
      const Spacer(),
      Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.3)),
    ]),
  );
}

class _ChildReview extends StatelessWidget {
  const _ChildReview();

  @override
  Widget build(BuildContext context) => _ReviewPage(children: [
    const _ReviewHeader(title: 'سلمى', subtitle: '3 شهور و12 يوم · متابعة النمو والصحة', icon: NumuwOrganicIconName.newborn),
    const SizedBox(height: 16),
    _ReviewCard(
      child: Row(children: [
        const NumuwOrganicIcon(NumuwOrganicIconName.growth, size: 62, semanticLabel: 'النمو'),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('النمو', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const _ValueLine('الوزن', '5.8 كجم'),
          const _ValueLine('الطول', '60 سم'),
          const _ValueLine('محيط الرأس', '39.5 سم'),
        ])),
      ]),
    ),
    const SizedBox(height: 14),
    const _ReviewCard(child: Column(children: [
      _FeatureLine('التطعيمات', 'التالي 12 سبتمبر', NumuwOrganicIconName.vaccine),
      Divider(height: 24),
      _FeatureLine('المهارات', '4 مكتملة · 2 قادمة', NumuwOrganicIconName.milestones),
      Divider(height: 24),
      _FeatureLine('أسئلة الطبيب', '3 أسئلة محفوظة', NumuwOrganicIconName.doctor),
      Divider(height: 24),
      _FeatureLine('تقارير الطبيب', 'ملخص أسبوعي جاهز', NumuwOrganicIconName.documents),
    ])),
  ]);
}

class _ValueLine extends StatelessWidget {
  const _ValueLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
      Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
    ]),
  );
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    NumuwOrganicIcon(icon, size: 44, semanticLabel: title),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ])),
    Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
  ]);
}

class _FamilyReview extends StatelessWidget {
  const _FamilyReview();

  @override
  Widget build(BuildContext context) => _ReviewPage(children: [
    const _ReviewHeader(title: 'مشاركة العائلة', subtitle: 'خلي المتابعة مشتركة وآمنة بين أفراد الأسرة', icon: NumuwOrganicIconName.family),
    const SizedBox(height: 16),
    _ReviewCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('أفراد العائلة', NumuwOrganicIconName.family),
      const SizedBox(height: 14),
      const _MemberReview('ماما', 'مالك ملف الطفل', NumuwOrganicIconName.motherHealth),
      const Divider(height: 24),
      const _MemberReview('بابا', 'ولي أمر', NumuwOrganicIconName.father),
      const Divider(height: 24),
      const _MemberReview('الجدة', 'متابعة فقط', NumuwOrganicIconName.account),
    ])),
    const SizedBox(height: 14),
    _ReviewCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel('دعوة جديدة', NumuwOrganicIconName.share),
      const SizedBox(height: 12),
      TextField(decoration: InputDecoration(hintText: 'البريد الإلكتروني اختياري', prefixIcon: Padding(padding: const EdgeInsets.all(10), child: const NumuwOrganicIcon(NumuwOrganicIconName.account, size: 26)))),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('إنشاء كود دعوة'))),
    ])),
  ]);
}

class _MemberReview extends StatelessWidget {
  const _MemberReview(this.name, this.role, this.icon);
  final String name;
  final String role;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    NumuwOrganicIcon(icon, size: 44, semanticLabel: name),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      Text(role, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ])),
    const NumuwOrganicIcon(NumuwOrganicIconName.done, size: 26),
  ]);
}

class _AssistantReview extends StatelessWidget {
  const _AssistantReview();

  @override
  Widget build(BuildContext context) => _ReviewPage(children: [
    const _ReviewHeader(title: 'مساعد نُمُوّ', subtitle: 'يساعدك تنظمي المعلومات وتجهزي أسئلتك للطبيب', icon: NumuwOrganicIconName.aiAssistant),
    const SizedBox(height: 16),
    const _ReviewCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _AssistantBubble('أهلاً يا ماما 👋\nاسأليني عن سجل سلمى، أو خليني أجهز لك ملخص اليوم.', false),
      SizedBox(height: 10),
      _AssistantBubble('لخصي لي رضعات اليوم وهل فيه حاجة محتاجة أسأل عنها الطبيب؟', true),
      SizedBox(height: 10),
      _AssistantBubble('سلمى عندها 5 رضعات مسجلة اليوم بإجمالي 510 مل. أقدر أرتب لك الأوقات والكميات في نقاط واضحة للطبيب، لكن مش هغيّر أي جرعة أو أقدم تشخيص.', false),
    ])),
    const SizedBox(height: 14),
    Wrap(spacing: 8, runSpacing: 8, children: const [
      _SuggestionChip('ملخص اليوم', NumuwOrganicIconName.documents),
      _SuggestionChip('سؤال للطبيب', NumuwOrganicIconName.doctor),
      _SuggestionChip('سجل الرضاعة', NumuwOrganicIconName.breastfeeding),
    ]),
    const SizedBox(height: 14),
    _ReviewCard(child: Row(children: [
      const Expanded(child: TextField(decoration: InputDecoration(hintText: 'اكتبي سؤالك هنا...', border: InputBorder.none))),
      const SizedBox(width: 8),
      NumuwPressable(
        semanticLabel: 'إرسال',
        onTap: () {},
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.center,
          child: const NumuwOrganicIcon(NumuwOrganicIconName.chat, size: 31, semanticLabel: 'إرسال'),
        ),
      ),
    ])),
  ]);
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble(this.text, this.mine);
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: mine ? scheme.primary.withValues(alpha: .12) : scheme.surfaceContainerHighest.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55)),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      NumuwOrganicIcon(icon, size: 26, semanticLabel: label),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
    ]),
  );
}

class _MoreReview extends StatelessWidget {
  const _MoreReview({required this.night, required this.onToggleNight});
  final bool night;
  final VoidCallback onToggleNight;

  @override
  Widget build(BuildContext context) => _ReviewPage(children: [
    const _ReviewHeader(title: 'المزيد', subtitle: 'إعداداتك وكل أدوات نُمُوّ الإضافية', icon: NumuwOrganicIconName.more),
    const SizedBox(height: 16),
    _ReviewCard(child: Column(children: [
      const _FeatureLine('الحمل', 'متابعة أسبوعية وتحضير للولادة', NumuwOrganicIconName.pregnancy),
      const Divider(height: 24),
      const _FeatureLine('التغذية', 'وجبات وأفكار مناسبة للعمر', NumuwOrganicIconName.nutrition),
      const Divider(height: 24),
      const _FeatureLine('صحة الأم', 'راحة ومتابعة يومية بسيطة', NumuwOrganicIconName.motherHealth),
      const Divider(height: 24),
      const _FeatureLine('المحتوى الأسبوعي', 'مقالات ونصائح قصيرة', NumuwOrganicIconName.articles),
      const Divider(height: 24),
      const _FeatureLine('التقارير', 'PDF منظم للطبيب', NumuwOrganicIconName.documents),
    ])),
    const SizedBox(height: 14),
    _ReviewCard(child: Column(children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 40),
        title: const Text('الوضع الليلي'),
        subtitle: Text(night ? 'مفعل' : 'غير مفعل'),
        trailing: Switch(value: night, onChanged: (_) => onToggleNight()),
      ),
      const Divider(height: 16),
      const _FeatureLine('الإشعارات', 'الرضعات والأدوية والتطعيمات', NumuwOrganicIconName.notifications),
      const Divider(height: 24),
      const _FeatureLine('الخصوصية', 'إدارة البيانات والحساب', NumuwOrganicIconName.privacy),
      const Divider(height: 24),
      const _FeatureLine('المساعدة', 'الأسئلة الشائعة والدعم', NumuwOrganicIconName.help),
    ])),
    const SizedBox(height: 16),
    Center(
      child: Text(
        'UI Review Candidate · Natural Organic',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  ]);
}
