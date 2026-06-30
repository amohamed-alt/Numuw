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
                      child: const Text('👶', style: TextStyle(fontSize: 76)),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'نُمُوّ',
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
                      'سجّلي أحداث طفلكِ، تابعي نموّه\nواطمئني في كل لحظة 💚',
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
                    PrimaryButton(label: 'تسجيل الدخول', onPressed: onSignIn),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'إنشاء حساب جديد',
                      onPressed: onSignUp,
                    ),
                    const SizedBox(height: 24),
                    const _FeatureRow(
                      icon: '🍼',
                      color: AppColors.mintLight,
                      text: 'تسجيل سريع للرضاعة والنوم والحفاضات',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: '📊',
                      color: AppColors.purpleLight,
                      text: 'متابعة النمو والتطعيمات',
                    ),
                    const SizedBox(height: 11),
                    const _FeatureRow(
                      icon: '💬',
                      color: AppColors.peachLight,
                      text: 'مساعد آمن لتنظيم بيانات طفلكِ',
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
