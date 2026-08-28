import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  int _moodIndex = 1;
  final Set<int> _selectedCareItems = <int>{0, 2};

  static const _moods = [
    _Mood('مرهقة', 'خذي نفسًا بطيئًا', '😮‍💨', AppColors.peach),
    _Mood('محتاجة هدوء', 'دقيقتان بدون لوم', '🌙', AppColors.blue),
    _Mood('أفضل', 'احفظي اللحظة الحلوة', '🤍', AppColors.success),
  ];

  static const _careItems = [
    _CareItem('شربتِ مياه؟', 'كوب مياه بجانبك يكفي كبداية.', Icons.water_drop_outlined),
    _CareItem('أكلتِ حاجة بسيطة؟', 'زبادي، تمر، موز أو لقمة خفيفة.', Icons.restaurant_outlined),
    _CareItem('ارتحتِ 10 دقائق؟', 'حتى لو الطفل صاحي، اطلبي تبديل بسيط.', Icons.self_improvement_rounded),
    _CareItem('تكلمتِ مع حد؟', 'رسالة واحدة لشخص قريب تقلل الضغط.', Icons.chat_bubble_outline_rounded),
  ];

  void _toggleCareItem(int index) {
    setState(() {
      if (!_selectedCareItems.add(index)) {
        _selectedCareItems.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = _moods[_moodIndex];
    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('صحّتك أنتِ')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'أنتِ جزء من الرعاية',
              subtitle: 'متابعة صغيرة لحالتك واحتياجاتك وسط اليوم، بدون ضغط أو أحكام.',
              showNotification: false,
              trailing: IconBadge(
                icon: '🤍',
                background: AppColors.peach.withValues(alpha: .13),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(title: 'اختاري إحساسك الآن', icon: Icons.favorite_border_rounded),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _moods.length; i++)
                  _MoodChip(
                    mood: _moods[i],
                    selected: _moodIndex == i,
                    onTap: () => setState(() => _moodIndex = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SoftCard(
              color: mood.color.withValues(alpha: numuwNightMode() ? .12 : .10),
              borderColor: mood.color.withValues(alpha: .24),
              child: Row(
                children: [
                  IconBadge(icon: mood.icon, background: mood.color.withValues(alpha: .16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.label,
                          style: TextStyle(color: numuwTextColor(), fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.hint,
                          style: TextStyle(color: numuwSecondaryTextColor(), height: 1.55, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionTitle(title: 'تشيك سريع لنفسك', icon: Icons.checklist_rounded),
            const SizedBox(height: 12),
            ...List.generate(
              _careItems.length,
              (index) => Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 10),
                child: _CareTile(
                  item: _careItems[index],
                  selected: _selectedCareItems.contains(index),
                  onTap: () => _toggleCareItem(index),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InfoBanner(
              message: 'لو الإحساس بالتعب أو الحزن مستمر أو فيه خوف على نفسك أو الطفل، تواصلي مع طبيب أو شخص موثوق فورًا.',
              color: AppColors.peach,
              background: AppColors.peachLight,
              icon: Icons.health_and_safety_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood, required this.selected, required this.onTap});

  final _Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? mood.color.withValues(alpha: .14) : numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: selected ? mood.color : numuwBorderColor(), width: selected ? 1.8 : 1.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mood.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 7),
                Text(
                  mood.label,
                  style: TextStyle(color: selected ? mood.color : numuwTextColor(), fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      );
}

class _CareTile extends StatelessWidget {
  const _CareTile({required this.item, required this.selected, required this.onTap});

  final _CareItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
        onTap: onTap,
        padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 14, 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColors.success.withValues(alpha: .14) : numuwAccentColor().withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(selected ? Icons.check_rounded : item.icon, color: selected ? AppColors.success : numuwAccentColor(), size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextStyle(color: numuwTextColor(), fontSize: 15.5, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(item.subtitle, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Mood {
  const _Mood(this.label, this.hint, this.icon, this.color);

  final String label;
  final String hint;
  final String icon;
  final Color color;
}

class _CareItem {
  const _CareItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}
