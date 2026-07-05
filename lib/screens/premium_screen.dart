import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String plan = 'annual';
  String? message;

  static const premiumFeatures = [
    'بدون إعلانات',
    'تقارير الطبيب PDF',
    'تسجيل صوتي بالعربية',
    'استخدام موسّع لمساعد الذكاء الاصطناعي',
    'مشاركة الأب والأسرة',
    'أكثر من طفل',
    'حفظ الصور والمستندات',
    'تقارير شهرية',
    'خطط روتين مخصصة',
    'محتوى صوتي كامل',
  ];

  static const freeFeatures = [
    'ملف طفل واحد',
    'تسجيل الرضاعة والنوم والحفاضات',
    'ملخص 7 أيام',
    'التطعيمات الأساسية',
    'محتوى أسبوعي',
    'أسئلة AI محدودة',
    'إعلانات محدودة',
  ];

  bool get annual => plan == 'annual';

  void purchase() {
    setState(() {
      message =
          'تم تجهيز تجربة الاشتراك في الواجهة. يتم تفعيل الدفع الحقيقي عند ربط Google Play وApp Store.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = annual ? '۳۹۹ ج.م' : '۴۹ ج.م';
    final period = annual ? 'سنويًا' : 'شهريًا';
    final renewal = annual ? 'يُجدَّد كل 12 شهرًا' : 'يُجدَّد كل شهر';

    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('')),
      body: AppPage(
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: numuwAccentColor().withValues(alpha: .14),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                Icons.nightlight_round,
                color: numuwAccentColor(),
                size: 52,
              ),
            ),
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 26,
                  height: 1.4,
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  const TextSpan(text: 'اعتني بطفلك براحة أكبر مع '),
                  TextSpan(
                    text: 'نُمُوّ Premium',
                    style: TextStyle(color: numuwAccentColor()),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _PlanCard(
                    title: 'سنوي',
                    price: '۳۹۹ ج.م',
                    period: 'سنويًا',
                    badge: 'الأفضل قيمة · وفّري 40%',
                    selected: annual,
                    onTap: () => setState(() => plan = 'annual'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PlanCard(
                    title: 'شهري',
                    price: '۴۹ ج.م',
                    period: 'شهريًا',
                    selected: !annual,
                    onTap: () => setState(() => plan = 'monthly'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                children: [
                  _SummaryRow('السعر', '$price / $period'),
                  _SummaryRow(
                    'التجربة المجانية',
                    '7 أيام — تُلغى قبل انتهائها بلا رسوم',
                  ),
                  _SummaryRow('التجديد', renewal),
                  _SummaryRow(
                    'الإلغاء',
                    'في أي وقت من إعدادات الاشتراك',
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'ماذا يشمل Premium؟',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient(numuwNightMode()),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: numuwAccentColor().withValues(alpha: .22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: numuwAccentColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الخطة المميزة',
                        style: TextStyle(
                          color: numuwAccentColor(),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...premiumFeatures.map(
                    (feature) => _FeatureRow(
                      text: feature,
                      active: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'الخطة المجانية تشمل',
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SoftCard(
              child: Column(
                children: freeFeatures
                    .map((feature) => _FeatureRow(text: feature))
                    .toList(),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 14),
              InfoBanner(message: message!, icon: Icons.info_outline_rounded),
            ],
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'ابدئي تجربة مجانية 7 أيام',
              onPressed: purchase,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(
                    () => message = 'لا يوجد اشتراك سابق مرتبط بهذا الحساب.',
                  ),
                  child: const Text('استعادة الشراء'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => setState(
                    () => message =
                        'يتم عرض شروط الاشتراك قبل تأكيد الشراء من المتجر.',
                  ),
                  child: const Text('شروط الاشتراك'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? numuwAccentColor().withValues(alpha: .12)
            : numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 18, 15, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? numuwAccentColor() : numuwBorderColor(),
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: numuwAccentColor(),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  style: TextStyle(color: numuwSecondaryTextColor()),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: TextStyle(
                    color: selected ? numuwAccentColor() : numuwTextColor(),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: numuwBorderColor())),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, this.active = false});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: active
                    ? numuwAccentColor().withValues(alpha: .14)
                    : numuwBorderColor().withValues(alpha: .45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: active
                    ? numuwAccentColor()
                    : numuwSecondaryTextColor(),
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: active
                      ? numuwTextColor()
                      : numuwSecondaryTextColor(),
                  fontSize: active ? 15 : 14,
                ),
              ),
            ),
          ],
        ),
      );
}
