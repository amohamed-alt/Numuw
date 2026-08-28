import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/numuw_classy_components.dart';
import '../../../widgets/numuw_motion_widgets.dart';
import 'preview_shared.dart';

class PreviewSplashScreen extends StatelessWidget {
  const PreviewSplashScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    showBack: true,
    child: SizedBox(
      height: 640,
      child: Center(
        child: NumuwFadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: black
                      ? AppColors.nightGradient
                      : AppColors.maternalGlow,
                  border: Border.all(
                    color: black
                        ? AppColors.nightBorder
                        : AppColors.blush,
                  ),
                  boxShadow: black
                      ? const []
                      : NumuwElevation.floating,
                ),
                child: Center(
                  child: Icon(
                    Icons.local_florist_rounded,
                    size: 48,
                    color: black
                        ? AppColors.nightPrimary
                        : AppColors.plum,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'نُموّ',
                style: TextStyle(
                  color: previewText(context),
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'رفيقتكِ في رحلة الأمومة',
                style: TextStyle(
                  color: previewSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: 96,
                child: LinearProgressIndicator(
                  value: .65,
                  borderRadius: BorderRadius.circular(999),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PreviewWelcomeScreen extends StatelessWidget {
  const PreviewWelcomeScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    showBack: true,
    child: Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: black
                ? AppColors.nightGradient
                : AppColors.childHeroGradient,
            border: Border.all(color: previewBorder(context)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.favorite_outline_rounded,
                size: 72,
                color: previewAccent(context),
              ),
              Positioned(
                bottom: 33,
                left: 48,
                child: Icon(
                  Icons.local_florist_rounded,
                  color: black ? AppColors.nightPrimary : AppColors.sage,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'كل لحظة حب… تنمو بحكاية',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: previewText(context),
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'سجّلي يوم طفلك بهدوء، تابعي نموه، وشاركي العناية مع من تثقين بهم.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: previewSecondary(context),
            fontSize: 13,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 28),
        const NumuwClassyButton(label: 'ابدئي الآن', onPressed: previewNoop),
        const SizedBox(height: 10),
        const NumuwClassyButton(
          label: 'لديكِ حساب؟ تسجيل الدخول',
          variant: NumuwButtonVariant.secondary,
          onPressed: previewNoop,
        ),
        const SizedBox(height: 24),
        const PreviewSafetyNote(
          text:
              'بيانات طفلك خاصة بكِ وبمن تسمحين له فقط. يمكنك إدارة مشاركة العيلة من داخل التطبيق.',
        ),
      ],
    ),
  );
}

class PreviewSignInScreen extends StatelessWidget {
  const PreviewSignInScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'تسجيل الدخول',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const PreviewPageIntro(
          eyebrow: 'WELCOME BACK',
          title: 'مرحباً بعودتكِ',
          subtitle: 'كمّلي يومك من المكان الذي توقفتِ عنده.',
          icon: Icons.favorite_border_rounded,
        ),
        const SizedBox(height: 26),
        const PreviewField(
          label: 'البريد الإلكتروني',
          value: 'mama@numuw.app',
          icon: Icons.mail_outline_rounded,
          ltr: true,
        ),
        const SizedBox(height: 14),
        const PreviewField(
          label: 'كلمة المرور',
          value: 'password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: previewNoop,
            child: const Text('نسيتِ كلمة المرور؟'),
          ),
        ),
        const SizedBox(height: 12),
        const NumuwClassyButton(
          label: 'تسجيل الدخول',
          icon: Icons.arrow_back_rounded,
          onPressed: previewNoop,
        ),
        const SizedBox(height: 20),
        const PreviewDividerLabel('أو'),
        const SizedBox(height: 18),
        const NumuwClassyButton(
          label: 'إنشاء حساب جديد',
          variant: NumuwButtonVariant.secondary,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}

class PreviewSignUpScreen extends StatelessWidget {
  const PreviewSignUpScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'إنشاء حساب',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const PreviewPageIntro(
          eyebrow: 'NEW BEGINNING',
          title: 'ابدئي رحلتكِ مع نُموّ',
          subtitle: 'حساب واحد يجمع يوم طفلك، نموه، ومشاركة العناية.',
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 24),
        const PreviewField(
          label: 'اسمكِ',
          value: 'ماما ليان',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 13),
        const PreviewField(
          label: 'البريد الإلكتروني',
          value: 'mama@numuw.app',
          icon: Icons.mail_outline_rounded,
          ltr: true,
        ),
        const SizedBox(height: 13),
        const PreviewField(
          label: 'كلمة المرور',
          value: 'password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        const SizedBox(height: 18),
        const NumuwClassyButton(label: 'إنشاء الحساب', onPressed: previewNoop),
        const SizedBox(height: 13),
        Center(
          child: Text(
            'بالاستمرار، أنتِ توافقين على سياسة الخصوصية وشروط الاستخدام.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: previewSecondary(context),
              fontSize: 10.5,
              height: 1.55,
            ),
          ),
        ),
      ],
    ),
  );
}

class PreviewEmailConfirmationScreen extends StatelessWidget {
  const PreviewEmailConfirmationScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'تأكيد البريد',
    child: SizedBox(
      height: 560,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PreviewIcon(
              icon: Icons.mark_email_unread_outlined,
              size: 90,
            ),
            const SizedBox(height: 22),
            Text(
              'افتحي بريدكِ',
              style: TextStyle(
                color: previewText(context),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'أرسلنا رابط التأكيد إلى\nmama@numuw.app',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: previewSecondary(context),
                fontSize: 13,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 26),
            const NumuwClassyButton(
              label: 'العودة لتسجيل الدخول',
              onPressed: previewNoop,
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: previewNoop, child: const Text('إعادة إرسال الرابط')),
          ],
        ),
      ),
    ),
  );
}

class PreviewOnboardingStageScreen extends StatefulWidget {
  const PreviewOnboardingStageScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewOnboardingStageScreen> createState() =>
      _PreviewOnboardingStageScreenState();
}

class _PreviewOnboardingStageScreenState
    extends State<PreviewOnboardingStageScreen> {
  String stage = 'born';

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'إعداد طفلكِ',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const PreviewStatusPill(label: 'الخطوة 1 من 3'),
        const SizedBox(height: 16),
        const PreviewPageIntro(
          title: 'نبدأ من أين؟',
          subtitle: 'اختاري المرحلة الحالية لنهيئ التجربة بالشكل المناسب لكِ.',
        ),
        const SizedBox(height: 24),
        PreviewChoiceCard(
          icon: Icons.child_care_rounded,
          title: 'طفلي وُلد',
          subtitle: 'ابدئي تسجيل الرضعات، النوم، والحفاضات من اليوم.',
          selected: stage == 'born',
          onTap: () => setState(() => stage = 'born'),
        ),
        const SizedBox(height: 12),
        PreviewChoiceCard(
          icon: Icons.pregnant_woman_rounded,
          title: 'ما زلتُ حاملاً',
          subtitle: 'تابعي موعد الولادة والاستعداد للمرحلة القادمة.',
          selected: stage == 'pregnancy',
          color: AppColors.sage,
          onTap: () => setState(() => stage = 'pregnancy'),
        ),
        const SizedBox(height: 28),
        const NumuwClassyButton(label: 'التالي', onPressed: previewNoop),
      ],
    ),
  );
}

class PreviewOnboardingDetailsScreen extends StatelessWidget {
  const PreviewOnboardingDetailsScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'عن طفلكِ',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewStatusPill(label: 'الخطوة 2 من 3'),
        const SizedBox(height: 16),
        const PreviewPageIntro(
          title: 'أخبريني عن ليان',
          subtitle: 'المعلومات الأساسية فقط الآن؛ ويمكن تعديلها لاحقاً.',
        ),
        const SizedBox(height: 22),
        const PreviewField(label: 'اسم الطفل', value: 'ليان'),
        const SizedBox(height: 13),
        const PreviewField(
          label: 'تاريخ الميلاد',
          value: '2025-11-16',
          icon: Icons.calendar_month_outlined,
          ltr: true,
        ),
        const SizedBox(height: 18),
        const Text('الجنس', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        NumuwSegmentedControl(
          items: const {'female': 'بنت', 'male': 'ولد', 'none': 'غير محدد'},
          value: 'female',
          onChanged: (_) {},
        ),
        const SizedBox(height: 18),
        const Text('نوع الرضاعة', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        NumuwSegmentedControl(
          items: const {'breast': 'طبيعية', 'formula': 'صناعية', 'mixed': 'مختلطة'},
          value: 'breast',
          onChanged: (_) {},
        ),
        const SizedBox(height: 25),
        const NumuwClassyButton(label: 'التالي', onPressed: previewNoop),
      ],
    ),
  );
}

class PreviewOnboardingOptionalScreen extends StatelessWidget {
  const PreviewOnboardingOptionalScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'تفاصيل إضافية',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewStatusPill(label: 'الخطوة 3 من 3'),
        const SizedBox(height: 16),
        const PreviewPageIntro(
          title: 'لمسات أخيرة',
          subtitle: 'اختيارية تماماً. الهدف أن نبدأ بسرعة لا أن نملأ نموذجاً طويلاً.',
        ),
        const SizedBox(height: 22),
        Center(
          child: Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.nightSurfaceRaised
                      : AppColors.blushSoft,
                  border: Border.all(color: previewBorder(context), width: 1.5),
                ),
                child: Icon(
                  Icons.child_care_rounded,
                  color: previewAccent(context),
                  size: 42,
                ),
              ),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: previewAccent(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 17),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const PreviewField(label: 'فصيلة الدم', value: 'O+'),
        const SizedBox(height: 13),
        const PreviewField(label: 'وزن الولادة', value: '3.2 كجم'),
        const SizedBox(height: 22),
        const NumuwClassyButton(
          label: 'لنبدأ رحلة نُموّ',
          icon: Icons.auto_awesome_rounded,
          onPressed: previewNoop,
        ),
        const SizedBox(height: 9),
        const NumuwClassyButton(
          label: 'تخطي التفاصيل الاختيارية',
          variant: NumuwButtonVariant.secondary,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}
