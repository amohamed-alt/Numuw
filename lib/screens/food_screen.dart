import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  int _selectedStage = 0;

  static const _stages = ['6 شهور', '7–8 شهور', '9–12 شهر'];

  static const _foods = [
    [
      _FoodItem('بطاطا مهروسة', 'كمية صغيرة كبداية وبقوام ناعم.', '🍠'),
      _FoodItem('كوسة مهروسة', 'نوع واحد في المرة لتسهيل المتابعة.', '🥒'),
      _FoodItem('تفاح مطبوخ', 'مهروس وناعم ومناسب للتجربة الأولى.', '🍎'),
    ],
    [
      _FoodItem('شوفان ناعم', 'وجبة بسيطة وسهلة التسجيل.', '🥣'),
      _FoodItem('موز مهروس', 'قوام لين ومناسب كتجربة سريعة.', '🍌'),
      _FoodItem('خضار مهروس', 'اختاري نوعًا واحدًا وسجّلي الملاحظة.', '🥕'),
    ],
    [
      _FoodItem('قطع طرية', 'أطعمة لينة جدًا وتحت إشراف كامل.', '🥑'),
      _FoodItem('زبادي مناسب', 'بدون إضافات كثيرة ومع متابعة التقبل.', '🥛'),
      _FoodItem('وجبة عائلية مبسطة', 'نسخة لطيفة من أكل البيت.', '🍲'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final foods = _foods[_selectedStage];
    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('الطعام بعد 6 شهور')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'تقديم الطعام بهدوء',
              subtitle: 'اقتراحات منظمة حسب العمر مع مساحة لتسجيل التقبل والملاحظات من شاشة التسجيل.',
              showNotification: false,
              trailing: IconBadge(
                icon: '🥣',
                background: AppColors.success.withValues(alpha: .13),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _stages.length; i++)
                  ChoicePill(
                    label: _stages[i],
                    selected: _selectedStage == i,
                    onTap: () => setState(() => _selectedStage = i),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SectionTitle(title: 'اقتراحات مناسبة', icon: Icons.restaurant_menu_rounded),
            const SizedBox(height: 12),
            if (foods.isEmpty)
              const EmptyState(message: 'لا توجد اقتراحات لهذه المرحلة بعد.')
            else
              ...foods.map(
                (food) => Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12),
                  child: _FoodCard(food: food),
                ),
              ),
            const SizedBox(height: 10),
            SoftCard(
              color: AppColors.peach.withValues(alpha: numuwNightMode() ? .10 : .08),
              borderColor: AppColors.peach.withValues(alpha: .22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: 'متابعة التقبل', icon: Icons.shield_outlined),
                  const SizedBox(height: 10),
                  Text(
                    'قدمي تجربة واحدة في كل مرة وسجّلي الملاحظات داخل نُمُوّ. عند وجود أي قلق، ارجعي للطبيب المتابع.',
                    style: TextStyle(color: numuwTextColor(), height: 1.7, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InfoBanner(
              message: 'هذه الشاشة للتنظيم والتذكير فقط وليست بديلًا عن إرشادات طبيب الأطفال.',
              color: AppColors.peach,
              background: AppColors.peachLight,
              icon: Icons.info_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.food});

  final _FoodItem food;

  @override
  Widget build(BuildContext context) => SoftCard(
        padding: const EdgeInsetsDirectional.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(
              icon: food.icon,
              background: numuwAccentColor().withValues(alpha: .12),
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.title, style: TextStyle(color: numuwTextColor(), fontSize: 16.5, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(food.subtitle, style: TextStyle(color: numuwSecondaryTextColor(), height: 1.55, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _FoodItem {
  const _FoodItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final String icon;
}
