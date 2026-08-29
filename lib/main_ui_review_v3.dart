import 'package:flutter/material.dart';

import 'core/theme/numuw_theme.dart';
import 'design/numuw_motion_widgets.dart';
import 'design/numuw_organic_icons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NumuwUiReviewV3());
}

class NumuwUiReviewV3 extends StatefulWidget {
  const NumuwUiReviewV3({super.key});

  @override
  State<NumuwUiReviewV3> createState() => _NumuwUiReviewV3State();
}

class _NumuwUiReviewV3State extends State<NumuwUiReviewV3> {
  int _index = 0;
  bool _night = false;

  static const _tabs = [
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
      theme: buildNumuwTheme(night: _night),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SizedBox.expand(
                  child: AnimatedSwitcher(
                    duration: NumuwMotionSpec.quick,
                    child: _buildPage(),
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
                constraints: const BoxConstraints(maxWidth: 480),
                child: _ReviewNav(
                  tabs: _tabs,
                  selected: _index,
                  onChanged: (value) => setState(() => _index = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage() => switch (_index) {
        0 => _HomePage(onToggleTheme: () => setState(() => _night = !_night)),
        1 => const _QuickLogPage(),
        2 => const _ChildPage(),
        3 => const _FamilyPage(),
        4 => const _AssistantPage(),
        _ => _MorePage(
            night: _night,
            onToggleTheme: () => setState(() => _night = !_night),
          ),
      };
}

class _ReviewNav extends StatelessWidget {
  const _ReviewNav({required this.tabs, required this.selected, required this.onChanged});
  final List<(String, NumuwOrganicIconName)> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('review-navigation'),
      padding: const EdgeInsets.fromLTRB(4, 7, 4, 9),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: .42))),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == selected;
          return Expanded(
            child: NumuwPressable(
              semanticLabel: tabs[i].$1,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: NumuwMotionSpec.quick,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: active ? scheme.primary.withValues(alpha: .10) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NumuwOrganicIcon(
                      tabs[i].$2,
                      size: active ? 27 : 23,
                      semanticLabel: tabs[i].$1,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        tabs[i].$1,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                          color: active ? scheme.primary : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    this.action,
  });
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
              NumuwOrganicIcon(icon, size: 46, semanticLabel: title),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (action != null) ...[const SizedBox(width: 6), action!],
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: scheme.outline.withValues(alpha: .42)),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? const [BoxShadow(color: Color(0x0C000000), blurRadius: 20, offset: Offset(0, 7))]
            : const [],
      ),
      child: child,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          NumuwOrganicIcon(icon, size: 30, semanticLabel: label),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
}

class _RowItem extends StatelessWidget {
  const _RowItem(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwOrganicIcon(icon, size: 40, semanticLabel: title),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  softWrap: true,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) => _Page(
        key: const ValueKey('home-page'),
        title: 'صباح الخير يا ماما',
        subtitle: 'كل حاجة تخص سلمى النهارده في مكان واحد',
        icon: NumuwOrganicIconName.home,
        action: IconButton(
          onPressed: onToggleTheme,
          tooltip: 'الوضع الليلي',
          icon: const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 29),
        ),
        children: const [
          _BabyHero(),
          SizedBox(height: 18),
          _Section('ملخص اليوم', NumuwOrganicIconName.calendar),
          SizedBox(height: 10),
          _Metrics(),
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
      );
}

class _BabyHero extends StatelessWidget {
  const _BabyHero();
  @override
  Widget build(BuildContext context) => _Card(
        child: Row(
          children: [
            const NumuwOrganicIcon(NumuwOrganicIconName.newborn, size: 62, semanticLabel: 'سلمى'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سلمى', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const Text('3 شهور و12 يوم'),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: const LinearProgressIndicator(value: .72, minHeight: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Metrics extends StatelessWidget {
  const _Metrics();
  @override
  Widget build(BuildContext context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.18,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumuwOrganicIcon(icon, size: 37, semanticLabel: title),
            const Spacer(),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}

class _QuickLogPage extends StatelessWidget {
  const _QuickLogPage();
  @override
  Widget build(BuildContext context) => const _Page(
        key: ValueKey('quick-log-page'),
        title: 'تسجيل سريع',
        subtitle: 'سجلي أهم أحداث يوم سلمى بأقل عدد من الخطوات',
        icon: NumuwOrganicIconName.add,
        children: [
          _Actions(),
          SizedBox(height: 16),
          _Card(
            child: _RowItem(
              'رضاعة شغالة الآن',
              '12:34 دقيقة · الجهة اليمنى',
              NumuwOrganicIconName.breastfeeding,
            ),
          ),
        ],
      );
}

class _Actions extends StatelessWidget {
  const _Actions();
  @override
  Widget build(BuildContext context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.08,
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
  const _Action(this.label, this.icon);
  final String label;
  final NumuwOrganicIconName icon;
  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumuwOrganicIcon(icon, size: 46, semanticLabel: label),
            const Spacer(),
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            Text('تسجيل سريع', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      );
}

class _ChildPage extends StatelessWidget {
  const _ChildPage();
  @override
  Widget build(BuildContext context) => const _Page(
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
                NumuwOrganicIcon(NumuwOrganicIconName.growth, size: 48),
                SizedBox(width: 10),
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
          _Card(child: _RowItem('ترفع الرأس بثبات', 'تم تحقيقها', NumuwOrganicIconName.milestones)),
        ],
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}

class _FamilyPage extends StatelessWidget {
  const _FamilyPage();
  @override
  Widget build(BuildContext context) => _Page(
        key: const ValueKey('family-page'),
        title: 'العائلة',
        subtitle: 'متابعة مشتركة بصلاحيات واضحة لكل فرد',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني')),
                const SizedBox(height: 12),
                FilledButton(onPressed: () {}, child: const Text('إنشاء دعوة')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Section('مهام مشتركة', NumuwOrganicIconName.tasks),
          const SizedBox(height: 10),
          const _Card(
            child: _RowItem('تجهيز شنطة الطبيب', 'غداً 5:00 م · مسندة لبابا', NumuwOrganicIconName.tasks),
          ),
        ],
      );
}

class _AssistantPage extends StatelessWidget {
  const _AssistantPage();
  @override
  Widget build(BuildContext context) => _Page(
        key: const ValueKey('assistant-page'),
        title: 'مساعد نُمُوّ',
        subtitle: 'للتنظيم والتلخيص، وليس بديلاً عن الطبيب',
        icon: NumuwOrganicIconName.aiAssistant,
        children: [
          const _Card(
            child: _RowItem(
              'سلامة أولاً',
              'في أي حالة طارئة تواصلي مع الطوارئ فوراً ولا تنتظري رد المساعد.',
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
            spacing: 7,
            runSpacing: 7,
            children: [
              ActionChip(onPressed: () {}, label: const Text('ملخص اليوم')),
              ActionChip(onPressed: () {}, label: const Text('تقرير الطبيب')),
              ActionChip(onPressed: () {}, label: const Text('صياغة سؤال')),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(hintText: 'اكتبي سؤالك هنا...')),
        ],
      );
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
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: mine ? scheme.surface : scheme.primary.withValues(alpha: .10),
          border: Border.all(color: scheme.outline.withValues(alpha: .42)),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(text, softWrap: true, style: const TextStyle(height: 1.55)),
      ),
    );
  }
}

class _MorePage extends StatelessWidget {
  const _MorePage({required this.night, required this.onToggleTheme});
  final bool night;
  final VoidCallback onToggleTheme;
  @override
  Widget build(BuildContext context) => _Page(
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
                const NumuwOrganicIcon(NumuwOrganicIconName.relaxation, size: 40),
                const SizedBox(width: 10),
                const Expanded(child: Text('الوضع الليلي', style: TextStyle(fontWeight: FontWeight.w900))),
                Switch(value: night, onChanged: (_) => onToggleTheme()),
              ],
            ),
          ),
        ],
      );
}
