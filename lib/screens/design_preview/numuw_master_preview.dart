import 'package:flutter/material.dart';

import '../../core/assets/numuw_embedded_assets.dart';

class NumuwMasterPreview extends StatefulWidget {
  const NumuwMasterPreview({super.key, this.initialDark = false});

  final bool initialDark;

  @override
  State<NumuwMasterPreview> createState() => _NumuwMasterPreviewState();
}

class _NumuwMasterPreviewState extends State<NumuwMasterPreview> {
  late bool _dark = widget.initialDark;
  int _screen = 0;

  static const _labels = ['اليوم', 'التسجيل السريع', 'الرضاعة', 'ملف الطفل'];

  @override
  Widget build(BuildContext context) {
    final p = _dark ? const _Palette.dark() : const _Palette.light();
    return Scaffold(
      backgroundColor: _dark ? const Color(0xFF101410) : const Color(0xFFF1EBE1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 760;
            final phone = _PhoneCanvas(
              palette: p,
              selectedIndex: _screen,
              onNavigate: (index) => setState(() => _screen = index.clamp(0, 3)),
              child: switch (_screen) {
                0 => _HomeContent(palette: p),
                1 => _QuickLogContent(palette: p),
                2 => _FeedingContent(palette: p),
                _ => _ChildProfileContent(palette: p),
              },
            );

            if (!desktop) {
              return Stack(
                children: [
                  Center(child: phone),
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: _ThemeButton(
                      dark: _dark,
                      palette: p,
                      onPressed: () => setState(() => _dark = !_dark),
                    ),
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Numuw Master Preview',
                          style: TextStyle(
                            color: p.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أربع شاشات أساسية بنفس نظام التصميم للـ Light والـ Dark.',
                          style: TextStyle(color: p.muted, height: 1.6),
                        ),
                        const SizedBox(height: 18),
                        ...List.generate(_labels.length, (index) {
                          final active = _screen == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FilledButton.tonal(
                              onPressed: () => setState(() => _screen = index),
                              style: FilledButton.styleFrom(
                                backgroundColor: active ? p.primary : p.surface,
                                foregroundColor: active ? p.onPrimary : p.text,
                                alignment: Alignment.centerRight,
                              ),
                              child: Text(_labels[index]),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        _ThemeButton(
                          dark: _dark,
                          palette: p,
                          onPressed: () => setState(() => _dark = !_dark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 26),
                Center(child: phone),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhoneCanvas extends StatelessWidget {
  const _PhoneCanvas({
    required this.palette,
    required this.selectedIndex,
    required this.onNavigate,
    required this.child,
  });

  final _Palette palette;
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 393,
        height: 852,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(color: Color(0x28000000), blurRadius: 30, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          children: [
            _StatusBar(palette: palette),
            Expanded(child: child),
            _BottomNavigation(
              palette: palette,
              selectedIndex: selectedIndex,
              onNavigate: onNavigate,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.palette});
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Column(
        children: [
          _ScreenHeader(palette: palette, title: 'مرحباً ماما', leading: Icons.notifications_none_rounded),
          const SizedBox(height: 12),
          _Card(
            palette: palette,
            height: 100,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                ClipOval(
                  child: Image.memory(
                    NumuwEmbeddedAssets.baby,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('يوسف', style: _titleStyle(palette, 23)),
                      const SizedBox(height: 5),
                      Text('9 أسابيع و3 أيام', style: _bodyStyle(palette)),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: palette.soft,
                  child: Icon(Icons.favorite_border_rounded, color: palette.gold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            palette: palette,
            height: 144,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('نبتة يوسف', style: _titleStyle(palette, 19)),
                      const SizedBox(height: 6),
                      Text('كل تسجيل يسقي رحلة نموه', style: _bodyStyle(palette)),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: .65,
                          color: palette.primary,
                          backgroundColor: palette.track,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Center(child: Text('65%', style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w800, fontSize: 11))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Image.memory(NumuwEmbeddedAssets.plant, width: 108, height: 116, fit: BoxFit.contain),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: Text('ملخص اليوم', style: _titleStyle(palette, 18))),
          const SizedBox(height: 9),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(child: _Metric(palette: palette, title: 'الحفاضة', image: NumuwEmbeddedAssets.diaper, first: 'منذ', second: '45m')),
              const SizedBox(width: 9),
              Expanded(child: _Metric(palette: palette, title: 'النوم', image: NumuwEmbeddedAssets.moon, first: '11 ساعة', second: '20 دقيقة')),
              const SizedBox(width: 9),
              Expanded(child: _Metric(palette: palette, title: 'الرضاعة', image: NumuwEmbeddedAssets.bottle, first: 'منذ', second: '1h 20m')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(child: _InfoCard(palette: palette, title: 'نصيحة اليوم', body: 'روتين النوم يساعد طفلك على الاستقرار والنمو.', icon: Icons.eco_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _InfoCard(palette: palette, title: 'التطعيم القادم', body: 'بعد 6 أيام\nاللقاح الروتيني', icon: Icons.health_and_safety_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickLogContent extends StatelessWidget {
  const _QuickLogContent({required this.palette});
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    const actions = [
      (Icons.local_drink_rounded, 'رضاعة'),
      (Icons.water_drop_outlined, 'شفط'),
      (Icons.nightlight_round, 'نوم'),
      (Icons.baby_changing_station_rounded, 'حفاضة'),
      (Icons.rice_bowl_rounded, 'طعام'),
      (Icons.medication_outlined, 'دواء'),
      (Icons.thermostat_rounded, 'حرارة'),
      (Icons.note_alt_outlined, 'ملاحظة'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ScreenHeader(palette: palette, title: 'تسجيل سريع', subtitle: 'سجّلي ما يحتاجه طفلك بسهولة'),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _ActionTile(palette: palette, icon: action.$1, label: action.$2);
            },
          ),
          const SizedBox(height: 20),
          Text('آخر التسجيلات', style: _titleStyle(palette, 18)),
          const SizedBox(height: 8),
          _TimelineItem(palette: palette, icon: Icons.local_drink_rounded, title: 'رضاعة (يمين)', subtitle: '120 مل', time: '7:30 ص'),
          _TimelineItem(palette: palette, icon: Icons.nightlight_round, title: 'نوم', subtitle: 'ساعة و40 دقيقة', time: '6:10 ص'),
          _TimelineItem(palette: palette, icon: Icons.baby_changing_station_rounded, title: 'حفاضة', subtitle: 'جافة', time: '5:45 ص'),
        ],
      ),
    );
  }
}

class _FeedingContent extends StatefulWidget {
  const _FeedingContent({required this.palette});
  final _Palette palette;

  @override
  State<_FeedingContent> createState() => _FeedingContentState();
}

class _FeedingContentState extends State<_FeedingContent> {
  int _side = 1;
  bool _burp = true;
  bool _spitUp = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ScreenHeader(palette: p, title: 'الرضاعة', trailing: Icons.arrow_back_rounded),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(30)),
              child: Text('جلسة جارية الآن', style: TextStyle(color: p.primaryDark, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 236,
              height: 236,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: .72, strokeWidth: 7, color: p.primary, backgroundColor: p.track),
                  Image.memory(NumuwEmbeddedAssets.leafTip, width: 52, height: 52),
                  Text('05:12', style: TextStyle(color: p.primaryDark, fontSize: 48, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('الجهة', style: _titleStyle(p, 15)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('يمين')),
              ButtonSegment(value: 1, label: Text('يسار')),
              ButtonSegment(value: 2, label: Text('كلاهما')),
            ],
            selected: {_side},
            onSelectionChanged: (value) => setState(() => _side = value.first),
            style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? p.primary : p.surface)),
          ),
          const SizedBox(height: 12),
          _Field(palette: p, label: 'نوع الرضاعة', value: 'رضاعة طبيعية', icon: Icons.keyboard_arrow_down_rounded),
          const SizedBox(height: 9),
          _Field(palette: p, label: 'الكمية (اختياري)', value: '120 مل'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ToggleRow(palette: p, label: 'استفراغ', value: _spitUp, onChanged: (value) => setState(() => _spitUp = value))),
              const SizedBox(width: 10),
              Expanded(child: _ToggleRow(palette: p, label: 'تجشؤ', value: _burp, onChanged: (value) => setState(() => _burp = value))),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(backgroundColor: p.primary, foregroundColor: p.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              icon: const Icon(Icons.eco_rounded),
              label: const Text('إيقاف وحفظ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildProfileContent extends StatelessWidget {
  const _ChildProfileContent({required this.palette});
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Column(
        children: [
          _ScreenHeader(palette: palette, title: 'ملف الطفل', trailing: Icons.more_vert_rounded),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipOval(child: Image.memory(NumuwEmbeddedAssets.baby, width: 118, height: 118, fit: BoxFit.cover)),
              CircleAvatar(radius: 18, backgroundColor: palette.primary, child: Icon(Icons.camera_alt_rounded, color: palette.onPrimary, size: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text('يوسف', style: _titleStyle(palette, 26)),
          const SizedBox(height: 4),
          Text('9 أسابيع و3 أيام', style: _bodyStyle(palette)),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(child: _StatCard(palette: palette, title: 'نوع الرضاعة', value: 'طبيعية', icon: Icons.eco_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(palette: palette, title: 'فصيلة الدم', value: 'O+', icon: Icons.water_drop_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(palette: palette, title: 'وزن الولادة', value: '3.25', icon: Icons.monitor_weight_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          _FeatureCard(palette: palette, title: 'النمو', subtitle: 'تابعي طول ووزن يوسف وتطوره', icon: Icons.local_florist_rounded),
          const SizedBox(height: 10),
          _FeatureCard(palette: palette, title: 'التطعيمات', subtitle: 'جدول التطعيمات والمواعيد القادمة', icon: Icons.health_and_safety_rounded),
          const SizedBox(height: 10),
          _FeatureCard(palette: palette, title: 'مهام العائلة', subtitle: 'قائمة المهام والتعاون بين أفراد العائلة', icon: Icons.family_restroom_rounded),
          const SizedBox(height: 10),
          _FeatureCard(palette: palette, title: 'أسئلة الطبيب', subtitle: 'جهّزي الأسئلة للزيارة القادمة', icon: Icons.medical_information_outlined),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.palette});
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
      child: Row(
        children: [
          Text('9:41', style: TextStyle(color: palette.text, fontSize: 12, fontWeight: FontWeight.w800)),
          const Spacer(),
          Icon(Icons.signal_cellular_alt_rounded, size: 13, color: palette.text),
          const SizedBox(width: 4),
          Icon(Icons.wifi_rounded, size: 13, color: palette.text),
          const SizedBox(width: 4),
          Icon(Icons.battery_full_rounded, size: 15, color: palette.text),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.palette, required this.title, this.subtitle, this.leading, this.trailing});
  final _Palette palette;
  final String title;
  final String? subtitle;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 44, height: 44, child: leading == null ? null : Icon(leading, color: palette.text)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: _titleStyle(palette, 22)),
            if (subtitle != null) Text(subtitle!, style: _bodyStyle(palette, 12.5)),
          ],
        ),
        SizedBox(width: 44, height: 44, child: trailing == null ? null : Icon(trailing, color: palette.text)),
      ],
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.palette, required this.selectedIndex, required this.onNavigate});
  final _Palette palette;
  final int selectedIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'اليوم', 0),
      (Icons.edit_note_rounded, 'التسجيل', 1),
      (Icons.child_care_rounded, 'طفلي', 3),
      (Icons.auto_awesome_rounded, 'اسألي', 3),
      (Icons.more_horiz_rounded, 'المزيد', 3),
    ];
    return Container(
      height: 82,
      decoration: BoxDecoration(color: palette.surface, border: Border(top: BorderSide(color: palette.border))),
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 13),
      child: Row(
        textDirection: TextDirection.rtl,
        children: items.map((item) {
          final active = item.$3 == selectedIndex || (selectedIndex == 2 && item.$3 == 1);
          return Expanded(
            child: InkResponse(
              onTap: () => onNavigate(item.$3),
              radius: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 34,
                    decoration: BoxDecoration(color: active ? palette.soft : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: Icon(item.$1, size: 22, color: active ? palette.primaryDark : palette.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(item.$2, style: TextStyle(color: active ? palette.primaryDark : palette.muted, fontSize: 10.5, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.palette, required this.icon, required this.label});
  final _Palette palette;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _Card(
      palette: palette,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: palette.primaryDark),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: palette.text, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.palette, required this.icon, required this.title, required this.subtitle, required this.time});
  final _Palette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _Card(
        palette: palette,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            CircleAvatar(backgroundColor: palette.soft, child: Icon(icon, color: palette.primaryDark, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: TextStyle(color: palette.text, fontWeight: FontWeight.w800)), Text(subtitle, style: _bodyStyle(palette, 12))])),
            Text(time, style: _bodyStyle(palette, 12)),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.palette, required this.title, required this.image, required this.first, required this.second});
  final _Palette palette;
  final String title;
  final dynamic image;
  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    return _Card(
      palette: palette,
      height: 113,
      padding: const EdgeInsets.all(7),
      elevated: false,
      child: Column(
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: palette.text, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Image.memory(image, width: 36, height: 36),
          const Spacer(),
          Text(first, style: _bodyStyle(palette, 11)),
          Text(second, style: TextStyle(color: palette.text, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.palette, required this.title, required this.body, required this.icon});
  final _Palette palette;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Card(
      palette: palette,
      height: 148,
      color: palette.subtle,
      padding: const EdgeInsets.all(11),
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(color: palette.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Expanded(child: Text(body, textAlign: TextAlign.right, style: TextStyle(color: palette.text, fontSize: 12.5, height: 1.6))),
          Icon(icon, color: palette.primary, size: 28),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.palette, required this.label, required this.value, this.icon});
  final _Palette palette;
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: palette.text, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: palette.border)),
          child: Row(textDirection: TextDirection.rtl, children: [Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: palette.text))), if (icon != null) Icon(icon, color: palette.muted)]),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.palette, required this.label, required this.value, required this.onChanged});
  final _Palette palette;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: palette.border)),
      child: Row(textDirection: TextDirection.rtl, children: [Expanded(child: Text(label, style: TextStyle(color: palette.text, fontWeight: FontWeight.w700))), Switch(value: value, onChanged: onChanged, activeThumbColor: palette.primary)]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.palette, required this.title, required this.value, required this.icon});
  final _Palette palette;
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Card(
      palette: palette,
      height: 94,
      elevated: false,
      padding: const EdgeInsets.all(8),
      child: Column(children: [Text(title, maxLines: 1, style: _bodyStyle(palette, 11)), const SizedBox(height: 5), Text(value, style: _titleStyle(palette, 18)), const Spacer(), Icon(icon, color: palette.primary, size: 22)]),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.palette, required this.title, required this.subtitle, required this.icon});
  final _Palette palette;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Card(
      palette: palette,
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          CircleAvatar(backgroundColor: palette.soft, child: Icon(icon, color: palette.primaryDark)),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: _titleStyle(palette, 17)), const SizedBox(height: 4), Text(subtitle, textAlign: TextAlign.right, style: _bodyStyle(palette, 12))])),
          Icon(Icons.chevron_left_rounded, color: palette.muted),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.dark, required this.palette, required this.onPressed});
  final bool dark;
  final _Palette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: palette.primary, foregroundColor: palette.onPrimary),
      icon: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      label: Text(dark ? 'الوضع الفاتح' : 'الوضع الداكن'),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.palette, required this.child, this.height, this.padding = const EdgeInsets.all(13), this.color, this.elevated = true});
  final _Palette palette;
  final Widget child;
  final double? height;
  final EdgeInsets padding;
  final Color? color;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
        boxShadow: elevated ? [BoxShadow(color: palette.shadow, blurRadius: 16, offset: const Offset(0, 5))] : null,
      ),
      child: child,
    );
  }
}

TextStyle _titleStyle(_Palette palette, double size) => TextStyle(color: palette.text, fontSize: size, fontWeight: FontWeight.w800, height: 1.2);
TextStyle _bodyStyle(_Palette palette, [double size = 14]) => TextStyle(color: palette.muted, fontSize: size, fontWeight: FontWeight.w500, height: 1.45);

class _Palette {
  const _Palette.light()
      : background = const Color(0xFFFBF8F1),
        surface = const Color(0xFFFFFDF9),
        subtle = const Color(0xFFF5F0E7),
        primary = const Color(0xFF74865B),
        primaryDark = const Color(0xFF4F6242),
        soft = const Color(0xFFE5EAD9),
        onPrimary = Colors.white,
        gold = const Color(0xFFD6B36A),
        text = const Color(0xFF37372F),
        muted = const Color(0xFF7D7A70),
        border = const Color(0xFFE7DED2),
        track = const Color(0xFFE7E2D7),
        shadow = const Color(0x188A7B68);

  const _Palette.dark()
      : background = const Color(0xFF171B17),
        surface = const Color(0xFF222820),
        subtle = const Color(0xFF252B23),
        primary = const Color(0xFFA8B58E),
        primaryDark = const Color(0xFFD3DDBB),
        soft = const Color(0xFF343D30),
        onPrimary = const Color(0xFF172013),
        gold = const Color(0xFFE8B86D),
        text = const Color(0xFFF5F1E8),
        muted = const Color(0xFFBDB8AC),
        border = const Color(0xFF394137),
        track = const Color(0xFF394137),
        shadow = const Color(0x30000000);

  final Color background;
  final Color surface;
  final Color subtle;
  final Color primary;
  final Color primaryDark;
  final Color soft;
  final Color onPrimary;
  final Color gold;
  final Color text;
  final Color muted;
  final Color border;
  final Color track;
  final Color shadow;
}
