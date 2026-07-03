import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFD9EFE9), AppColors.background],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
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
                      ),
                      alignment: Alignment.center,
                      child: const Text('ðŸ‘¶', style: TextStyle(fontSize: 76)),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Ù†ÙÙ…ÙÙˆÙ‘',
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
                      'Ø³Ø¬Ù‘Ù„ÙŠ Ø£Ø­Ø¯Ø§Ø« Ø·ÙÙ„ÙƒÙØŒ ØªØ§Ø¨Ø¹ÙŠ Ù†Ù…ÙˆÙ‘Ù‡\nÙˆØ§Ø·Ù…Ø¦Ù†ÙŠ ÙÙŠ ÙƒÙ„ Ù„Ø­Ø¸Ø© ðŸ’š',
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
                    PrimaryButton(
                      label: 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„',
                      onPressed: onSignIn,
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨ Ø¬Ø¯ÙŠØ¯',
                      onPressed: onSignUp,
                    ),
                    const SizedBox(height: 24),
                    const _FeatureRow(
                      icon: 'ðŸ¼',
                      color: AppColors.mintLight,
                      text:
                          'ØªØ³Ø¬ÙŠÙ„ Ø³Ø±ÙŠØ¹ Ù„Ù„Ø±Ø¶Ø§Ø¹Ø© ÙˆØ§Ù„Ù†ÙˆÙ… ÙˆØ§Ù„Ø­ÙØ§Ø¶Ø§Øª',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: 'ðŸ“Š',
                      color: AppColors.purpleLight,
                      text: 'Ù…ØªØ§Ø¨Ø¹Ø© Ø§Ù„Ù†Ù…Ùˆ ÙˆØ§Ù„ØªØ·Ø¹ÙŠÙ…Ø§Øª',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: 'ðŸ’¬',
                      color: AppColors.peachLight,
                      text:
                          'Ù…Ø³Ø§Ø¹Ø¯ Ø¢Ù…Ù† Ù„ØªÙ†Ø¸ÙŠÙ… Ø¨ÙŠØ§Ù†Ø§Øª Ø·ÙÙ„ÙƒÙ',
                    ),
                    const SizedBox(height: 18),
                    const _PrivacyTrustCard(),
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

class _PrivacyTrustCard extends StatelessWidget {
  const _PrivacyTrustCard();

  @override
  Widget build(BuildContext context) => SoftCard(
    color: numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.mintLight,
    borderColor: numuwNightMode() ? AppColors.nightBorder : AppColors.mintSoft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.privacy_tip_outlined, color: AppColors.mint),
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
                'بيانات طفلك لا تظهر إلا لكِ ولمن تسمحين له من مشاركة العيلة، ويمكنك إدارة الصلاحيات من داخل التطبيق.',
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

  final String icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconBadge(icon: icon, background: color, size: 38),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 14),
        ),
      ),
    ],
  );
}
