import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

class PregnancyScreen extends StatelessWidget {
  const PregnancyScreen({super.key});

  static const _tasks = [
    _PregnancyTask('شنطة المستشفى', 'قسّميها: أوراق، ملابس الطفل، احتياجاتك الشخصية.', Icons.local_mall_outlined, AppColors.peach),
    _PregnancyTask('خطة أول أسبوع', 'من يطبخ؟ من يزور؟ من يبدّل معك في الليل؟', Icons.calendar_month_outlined, AppColors.blue),
    _PregnancyTask('أسئلة الطبيب', 'اكتبي أي ألم أو قلق بدل ما تنسيه في الزيارة.', Icons.medical_information_outlined, AppColors.success),
  ];

  static const _milestones = [
    'جهّزي ركن التسجيل الليلي قبل الولادة.',
    'اتفقي مع شخص قريب على أول 48 ساعة دعم.',
    'احفظي أرقام الطوارئ والطبيب في مكان واضح.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('وضع الحمل')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'استعداد هادي قبل وصول الطفل',
              subtitle: 'قوائم عملية للأيام الأخيرة، بنفس هوية نُمُوّ الهادئة وبدون زحمة معلومات.',
              showNotification: false,
              trailing: IconBadge(
                icon: '🤰',
                background: AppColors.blue.withValues(alpha: .13),
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              color: numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.mintLight,
              borderColor: numuwAccentColor().withValues(alpha: .20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: 'تركيز هذا الأسبوع', icon: Icons.auto_awesome_rounded),
                  const SizedBox(height: 12),
                  Text(
                    'لا تحاولي تجهيز كل شيء مرة واحدة. اختاري مهمة واحدة صغيرة اليوم، والباقي يتوزع على الأسرة.',
                    style: TextStyle(color: numuwTextColor(), height: 1.7, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionTitle(title: 'قوائم التجهيز', icon: Icons.task_alt_rounded),
            const SizedBox(height: 12),
            ..._tasks.map(
              (task) => Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 12),
                child: _PregnancyTaskCard(task: task),
              ),
            ),
            const SizedBox(height: 12),
            SectionTitle(title: 'تذكيرات آمنة', icon: Icons.favorite_rounded),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                children: [
                  for (var i = 0; i < _milestones.length; i++) ...[
                    _Milestone(text: _milestones[i], index: i + 1),
                    if (i != _milestones.length - 1) Divider(height: 18, color: numuwBorderColor()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            InfoBanner(
              message: 'المحتوى هنا تنظيمي فقط. أي أعراض أو قلق طبي لازم يرجع للطبيب المتابع.',
              color: AppColors.blue,
              background: AppColors.blueLight,
              icon: Icons.info_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _PregnancyTaskCard extends StatelessWidget {
  const _PregnancyTaskCard({required this.task});

  final _PregnancyTask task;

  @override
  Widget build(BuildContext context) => SoftCard(
        padding: const EdgeInsetsDirectional.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: task.color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(task.icon, color: task.color, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: TextStyle(color: numuwTextColor(), fontSize: 16.5, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(task.subtitle, style: TextStyle(color: numuwSecondaryTextColor(), height: 1.55, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.text, required this.index});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: numuwAccentColor().withValues(alpha: .14),
            child: Text('$index', style: TextStyle(color: numuwAccentColor(), fontSize: 12, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: numuwTextColor(), height: 1.55, fontWeight: FontWeight.w700)),
          ),
        ],
      );
}

class _PregnancyTask {
  const _PregnancyTask(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
