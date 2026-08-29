import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.fromSTEB(32, 58, 32, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.mintLight.withValues(alpha: .9),
                      numuwPageColor(),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const NumuwEntrance(child: _WelcomeHero()),
                    const SizedBox(height: 22),
                    Text(
                      'نُموّ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سجّلي أحداث طفلكِ، تابعي نموّه\nواطمئني على تفاصيل يومه بهدوء.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 40),
                child: Column(
                  children: [
                    NumuwPrimaryButton(
                      label: 'تسجيل الدخول',
                      onPressed: onSignIn,
                    ),
                    const SizedBox(height: 12),
                    NumuwSecondaryButton(
                      label: 'إنشاء حساب جديد',
                      onPressed: onSignUp,
                    ),
                    const SizedBox(height: 24),
                    const _FeatureRow(
                      icon: NumuwOrganicIconName.breastfeeding,
                      color: AppColors.mintLight,
                      text: 'تسجيل سريع للرضاعة والنوم والحفاضات',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: NumuwOrganicIconName.growth,
                      color: AppColors.purpleLight,
                      text: 'متابعة النمو والتطعيمات في مكان واحد',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: NumuwOrganicIconName.aiAssistant,
                      color: AppColors.peachLight,
                      text: 'مساعد آمن لتنظيم بيانات طفلكِ وأسئلتكِ اليومية',
                    ),
                    const SizedBox(height: 18),
                    const _PrivacyTrustCard(),
                    const SizedBox(height: 18),
                    const NumuwPlantProgress(
                      progress: .28,
                      label: 'تتفتح أول الأوراق',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.mintLight, AppColors.mintSoft],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.mint.withValues(alpha: .2),
          width: 3,
        ),
        boxShadow: numuwNightMode()
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x184F6242),
                  blurRadius: 26,
                  offset: Offset(0, 12),
                ),
              ],
      ),
      alignment: Alignment.center,
      child: const NumuwOrganicIcon(
        NumuwOrganicIconName.newborn,
        size: 104,
        semanticLabel: 'طفل حديث الولادة',
      ),
    );
  }
}

class _PrivacyTrustCard extends StatelessWidget {
  const _PrivacyTrustCard();

  @override
  Widget build(BuildContext context) => SoftCard(
    color: numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.mintLight,
    borderColor: numuwNightMode() ? AppColors.nightBorder : AppColors.mintSoft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: numuwSurfaceColor(),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const NumuwOrganicIcon(
            NumuwOrganicIconName.privacy,
            size: 34,
            semanticLabel: 'الخصوصية',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'خصوصيتك واضحة من البداية',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'بيانات طفلك لا تظهر إلا لكِ ولمن تسمحين له من مشاركة العائلة، ويمكنك إدارة الصلاحيات وحذف حسابك وبياناتك من داخل التطبيق.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final NumuwOrganicIconName icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: numuwBorderColor()),
        ),
        child: NumuwOrganicIcon(icon, size: 32),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwSecondaryTextColor(),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ),
    ],
  );
}
