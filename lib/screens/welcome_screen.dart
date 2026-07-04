import 'package:flutter/material.dart';

import '../core/app_colors.dart';
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
                      child: const Text(
                        'Ã°Å¸â€˜Â¶',
                        style: TextStyle(fontSize: 76),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Ã™â€ Ã™ÂÃ™â€¦Ã™ÂÃ™Ë†Ã™â€˜',
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
                      'Ã˜Â³Ã˜Â¬Ã™â€˜Ã™â€žÃ™Å  Ã˜Â£Ã˜Â­Ã˜Â¯Ã˜Â§Ã˜Â« Ã˜Â·Ã™ÂÃ™â€žÃ™Æ’Ã™ÂÃ˜Å’ Ã˜ÂªÃ˜Â§Ã˜Â¨Ã˜Â¹Ã™Å  Ã™â€ Ã™â€¦Ã™Ë†Ã™â€˜Ã™â€¡\nÃ™Ë†Ã˜Â§Ã˜Â·Ã™â€¦Ã˜Â¦Ã™â€ Ã™Å  Ã™ÂÃ™Å  Ã™Æ’Ã™â€ž Ã™â€žÃ˜Â­Ã˜Â¸Ã˜Â© Ã°Å¸â€™Å¡',
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
                      label: 'Ã˜ÂªÃ˜Â³Ã˜Â¬Ã™Å Ã™â€ž Ã˜Â§Ã™â€žÃ˜Â¯Ã˜Â®Ã™Ë†Ã™â€ž',
                      onPressed: onSignIn,
                    ),
                    const SizedBox(height: 12),
                    NumuwSecondaryButton(
                      label:
                          'Ã˜Â¥Ã™â€ Ã˜Â´Ã˜Â§Ã˜Â¡ Ã˜Â­Ã˜Â³Ã˜Â§Ã˜Â¨ Ã˜Â¬Ã˜Â¯Ã™Å Ã˜Â¯',
                      onPressed: onSignUp,
                    ),
                    const SizedBox(height: 24),
                    const _FeatureRow(
                      icon: 'Ã°Å¸ÂÂ¼',
                      color: AppColors.mintLight,
                      text:
                          'Ã˜ÂªÃ˜Â³Ã˜Â¬Ã™Å Ã™â€ž Ã˜Â³Ã˜Â±Ã™Å Ã˜Â¹ Ã™â€žÃ™â€žÃ˜Â±Ã˜Â¶Ã˜Â§Ã˜Â¹Ã˜Â© Ã™Ë†Ã˜Â§Ã™â€žÃ™â€ Ã™Ë†Ã™â€¦ Ã™Ë†Ã˜Â§Ã™â€žÃ˜Â­Ã™ÂÃ˜Â§Ã˜Â¶Ã˜Â§Ã˜Âª',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: 'Ã°Å¸â€œÅ ',
                      color: AppColors.purpleLight,
                      text:
                          'Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â¨Ã˜Â¹Ã˜Â© Ã˜Â§Ã™â€žÃ™â€ Ã™â€¦Ã™Ë† Ã™Ë†Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â·Ã˜Â¹Ã™Å Ã™â€¦Ã˜Â§Ã˜Âª',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: 'Ã°Å¸â€™Â¬',
                      color: AppColors.peachLight,
                      text:
                          'Ã™â€¦Ã˜Â³Ã˜Â§Ã˜Â¹Ã˜Â¯ Ã˜Â¢Ã™â€¦Ã™â€  Ã™â€žÃ˜ÂªÃ™â€ Ã˜Â¸Ã™Å Ã™â€¦ Ã˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜Âª Ã˜Â·Ã™ÂÃ™â€žÃ™Æ’Ã™Â',
                    ),
                    const SizedBox(height: 18),
                    const _PrivacyTrustCard(),
                    const SizedBox(height: 18),
                    const NumuwPlantProgress(
                      progress: .28,
                      label: 'ØªØªÙØªØ­ Ø£ÙˆÙ„ Ø§Ù„Ø£ÙˆØ±Ø§Ù‚',
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
                'Ø®ØµÙˆØµÙŠØªÙƒ ÙˆØ§Ø¶Ø­Ø© Ù…Ù† Ø§Ù„Ø¨Ø¯Ø§ÙŠØ©',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Ø¨ÙŠØ§Ù†Ø§Øª Ø·ÙÙ„Ùƒ Ù„Ø§ ØªØ¸Ù‡Ø± Ø¥Ù„Ø§ Ù„ÙƒÙ ÙˆÙ„Ù…Ù† ØªØ³Ù…Ø­ÙŠÙ† Ù„Ù‡ Ù…Ù† Ù…Ø´Ø§Ø±ÙƒØ© Ø§Ù„Ø¹ÙŠÙ„Ø©ØŒ ÙˆÙŠÙ…ÙƒÙ†Ùƒ Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„ØµÙ„Ø§Ø­ÙŠØ§Øª Ù…Ù† Ø¯Ø§Ø®Ù„ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚.',
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
