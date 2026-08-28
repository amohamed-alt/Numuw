import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/numuw_classy_components.dart';
import '../../../widgets/numuw_motion_widgets.dart';
import 'preview_shared.dart';

class PreviewMoreScreen extends StatelessWidget {
  const PreviewMoreScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'المزيد',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NumuwChildIdentity(name: 'ليان أحمد', age: 'الحساب: mama@numuw.app'),
        const SizedBox(height: 20),
        const NumuwSectionLabel(title: 'أدوات المتابعة'),
        const SizedBox(height: 9),
        PreviewSectionCard(
          title: 'التذكيرات',
          child: Column(
            children: [
              const PreviewSwitchRow(
                title: 'تذكير الرضعة القادمة',
                icon: Icons.notifications_active_outlined,
              ),
              Divider(color: previewBorder(context)),
              const PreviewSwitchRow(
                title: 'تذكير الدواء المسجل',
                icon: Icons.medication_outlined,
                initial: false,
              ),
              Divider(color: previewBorder(context)),
              const PreviewSwitchRow(
                title: 'تذكير التطعيم القادم',
                icon: Icons.vaccines_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NumuwSectionLabel(title: 'العيلة والتقارير'),
        const SizedBox(height: 9),
        PreviewSectionCard(
          title: 'الخدمات',
          child: Column(
            children: [
              const PreviewInfoRow(
                label: 'مشاركة العيلة',
                value: '3 أفراد لديهم وصول',
                icon: Icons.family_restroom_rounded,
              ),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(
                label: 'كارت الأسبوع',
                value: 'جاهز للمشاركة',
                icon: Icons.ios_share_rounded,
                color: AppColors.info,
              ),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(
                label: 'تقرير الطبيب PDF',
                value: 'تصدير آخر السجلات والأسئلة',
                icon: Icons.picture_as_pdf_outlined,
                color: Color(0xFF8D7399),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NumuwSectionLabel(title: 'التجربة والخصوصية'),
        const SizedBox(height: 9),
        PreviewSectionCard(
          title: 'الإعدادات',
          child: Column(
            children: [
              const PreviewSwitchRow(
                title: 'وضع الليل الهادئ',
                subtitle: 'ألوان سوداء منخفضة الإضاءة للاستخدام الليلي',
                icon: Icons.dark_mode_outlined,
                initial: false,
              ),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(
                label: 'الخصوصية',
                value: 'إدارة الوصول وبيانات الطفل',
                icon: Icons.privacy_tip_outlined,
                color: AppColors.sage,
              ),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(
                label: 'إصدار التطبيق',
                value: '1.0.0',
                icon: Icons.info_outline_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NumuwClassyButton(
          label: 'تسجيل الخروج',
          variant: NumuwButtonVariant.secondary,
          icon: Icons.logout_rounded,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}

class PreviewFamilySharingScreen extends StatefulWidget {
  const PreviewFamilySharingScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewFamilySharingScreen> createState() => _PreviewFamilySharingScreenState();
}

class _PreviewFamilySharingScreenState extends State<PreviewFamilySharingScreen> {
  bool inviteCreated = false;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'مشاركة العيلة',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewPageIntro(
          title: 'العناية فريق واحد',
          subtitle: 'أضيفي من تثقين بهم، واحتفظي بوضوح من لديه وصول لبيانات ليان.',
          icon: Icons.family_restroom_rounded,
        ),
        const SizedBox(height: 18),
        PreviewSectionCard(
          title: 'دعوة شخص',
          child: Column(
            children: [
              const PreviewField(
                label: 'البريد الإلكتروني — اختياري',
                hint: 'name@example.com',
                ltr: true,
              ),
              const SizedBox(height: 12),
              NumuwClassyButton(
                label: inviteCreated ? 'تم إنشاء الكود: NMW-4821' : 'إنشاء كود دعوة',
                variant: inviteCreated
                    ? NumuwButtonVariant.tonal
                    : NumuwButtonVariant.primary,
                onPressed: () => setState(() => inviteCreated = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const PreviewSectionCard(
          title: 'أفراد العيلة',
          child: Column(
            children: [
              PreviewInfoRow(
                label: 'ماما',
                value: 'المالك · وصول كامل',
                icon: Icons.person_outline_rounded,
              ),
              Divider(),
              PreviewInfoRow(
                label: 'بابا',
                value: 'ولي أمر · يستطيع التسجيل والمتابعة',
                icon: Icons.person_outline_rounded,
                color: AppColors.info,
              ),
              Divider(),
              PreviewInfoRow(
                label: 'الجدة',
                value: 'ولي أمر · متابعة وتسجيل',
                icon: Icons.person_outline_rounded,
                color: AppColors.sage,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const PreviewSafetyNote(
          text: 'يمكنك إزالة الوصول أو إدارة أفراد العيلة في أي وقت.',
        ),
      ],
    ),
  );
}

class PreviewWeeklyShareScreen extends StatelessWidget {
  const PreviewWeeklyShareScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'كارت الأسبوع',
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            gradient: black
                ? AppColors.nightGradient
                : const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [Color(0xFFFFF8F6), Color(0xFFF7E9EC), Color(0xFFF1F3ED)],
                  ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: previewBorder(context)),
            boxShadow: black ? const [] : NumuwElevation.floating,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PreviewIcon(icon: Icons.local_florist_rounded, size: 48),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أسبوع ليان',
                          style: TextStyle(
                            color: previewText(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'آخر 7 أيام من سجلات نُموّ',
                          style: TextStyle(color: previewSecondary(context), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              NumuwClassySurface(
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أبرز رقم هذا الأسبوع',
                      style: TextStyle(color: previewSecondary(context), fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '31 رضعة',
                      style: TextStyle(
                        color: previewAccent(context),
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  PreviewMiniStat(label: 'النوم', value: '48.5 س', color: Color(0xFF8D7399)),
                  SizedBox(width: 8),
                  PreviewMiniStat(label: 'الرضعات', value: '31'),
                  SizedBox(width: 8),
                  PreviewMiniStat(label: 'الشفط', value: '1,240 مل', color: AppColors.info),
                ],
              ),
              const SizedBox(height: 16),
              const _ShareTrend(icon: Icons.trending_up_rounded, text: 'الرضعات المسجلة زادت 6٪ عن الأسبوع السابق', color: AppColors.success),
              const SizedBox(height: 7),
              const _ShareTrend(icon: Icons.drag_handle_rounded, text: 'مدة النوم المسجلة قريبة من الأسبوع السابق', color: AppColors.info),
              const SizedBox(height: 7),
              const _ShareTrend(icon: Icons.trending_up_rounded, text: 'كمية الشفط المسجلة زادت 8٪', color: AppColors.plum),
              const SizedBox(height: 16),
              Text(
                'مقارنة للسجلات فقط وليست تقييماً طبياً.',
                style: TextStyle(color: previewSecondary(context), fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const NumuwClassyButton(
          label: 'مشاركة الكارت',
          icon: Icons.ios_share_rounded,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}

class _ShareTrend extends StatelessWidget {
  const _ShareTrend({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 17),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            color: previewText(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class PreviewEventDetailsScreen extends StatelessWidget {
  const PreviewEventDetailsScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'تفاصيل النشاط',
    child: Column(
      children: [
        const SizedBox(height: 10),
        const PreviewIcon(icon: Icons.water_drop_outlined, size: 68),
        const SizedBox(height: 12),
        Text(
          'رضاعة طبيعية',
          style: TextStyle(
            color: previewText(context),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        PreviewSectionCard(
          title: 'التفاصيل',
          child: Column(
            children: [
              const PreviewInfoRow(label: 'الوقت', value: '12:30 مساءً'),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(label: 'المدة', value: '15 دقيقة'),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(label: 'الجهة', value: 'اليمنى'),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(label: 'بعد الرضعة', value: 'تجشأت'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: NumuwClassyButton(
                label: 'تعديل',
                variant: NumuwButtonVariant.secondary,
                onPressed: previewNoop,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: NumuwClassyButton(
                label: 'حذف',
                variant: NumuwButtonVariant.danger,
                onPressed: previewNoop,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class PreviewLoadingStateScreen extends StatelessWidget {
  const PreviewLoadingStateScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'Loading state',
    child: SizedBox(
      height: 520,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.4),
          const SizedBox(height: 20),
          Text(
            'نجهّز بيانات ليان…',
            style: TextStyle(
              color: previewText(context),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'نحتفظ بالمحتوى السابق متى كان متاحاً، ولا نترك شاشة فارغة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: previewSecondary(context), fontSize: 11.5, height: 1.55),
          ),
        ],
      ),
    ),
  );
}

class PreviewEmptyStateScreen extends StatelessWidget {
  const PreviewEmptyStateScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'Empty state',
    child: SizedBox(
      height: 520,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PreviewIcon(icon: Icons.inbox_outlined, size: 82),
          const SizedBox(height: 18),
          Text(
            'لا توجد تسجيلات بعد',
            style: TextStyle(
              color: previewText(context),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'أول تسجيل سيظهر هنا مرتباً حسب الوقت.',
            style: TextStyle(color: previewSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 22),
          const NumuwClassyButton(label: 'سجلي أول نشاط', onPressed: previewNoop),
        ],
      ),
    ),
  );
}

class PreviewErrorStateScreen extends StatelessWidget {
  const PreviewErrorStateScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'Error state',
    child: SizedBox(
      height: 520,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PreviewIcon(
            icon: Icons.cloud_off_outlined,
            color: AppColors.danger,
            background: AppColors.peachLight,
            size: 82,
          ),
          const SizedBox(height: 18),
          Text(
            'تعذر تحديث البيانات',
            style: TextStyle(
              color: previewText(context),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'تحققي من الاتصال ثم حاولي مرة أخرى. لن نفقد التسجيلات المحفوظة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: previewSecondary(context), fontSize: 12, height: 1.55),
          ),
          const SizedBox(height: 22),
          const NumuwClassyButton(
            label: 'إعادة المحاولة',
            variant: NumuwButtonVariant.secondary,
            onPressed: previewNoop,
          ),
        ],
      ),
    ),
  );
}

class PreviewSuccessStateScreen extends StatelessWidget {
  const PreviewSuccessStateScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'Success state',
    child: SizedBox(
      height: 520,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NumuwSuccessBloom(size: 120),
          const SizedBox(height: 8),
          Text(
            'تم الحفظ بنجاح',
            style: TextStyle(
              color: previewText(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تم تسجيل الرضعة ويمكنك الرجوع لها من سجل اليوم.',
            textAlign: TextAlign.center,
            style: TextStyle(color: previewSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 22),
          const NumuwClassyButton(
            label: 'العودة للرئيسية',
            variant: NumuwButtonVariant.tonal,
            onPressed: previewNoop,
          ),
        ],
      ),
    ),
  );
}
