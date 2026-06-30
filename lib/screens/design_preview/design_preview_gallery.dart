import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../splash_screen.dart';
import '../welcome_screen.dart';

class DesignPreviewGallery extends StatelessWidget {
  const DesignPreviewGallery({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Design preview is debug-only.')),
      );
    }
    final items = <_PreviewItem>[
      _PreviewItem('Splash', (_) => const SplashScreen()),
      _PreviewItem(
        'Welcome',
        (_) => WelcomeScreen(onSignIn: () {}, onSignUp: () {}),
      ),
      _PreviewItem(
        'Sign in',
        (_) => _PreviewAuth(
          title: 'مرحباً بعودتكِ 👋',
          subtitle: 'سجّلي الدخول للمتابعة',
        ),
      ),
      _PreviewItem(
        'Sign up',
        (_) => _PreviewAuth(
          title: 'إنشاء حساب ✨',
          subtitle: 'ابدئي رحلتكِ مع نُمُوّ',
          signUp: true,
        ),
      ),
      _PreviewItem(
        'Email confirmation',
        (_) => const _PreviewMessage(
          icon: '📧',
          title: 'تأكيد البريد الإلكتروني',
          message: 'أرسلنا رابط التأكيد إلى بريدكِ.',
        ),
      ),
      _PreviewItem(
        'Onboarding',
        (_) => const _PreviewMessage(
          icon: '👶',
          title: 'إضافة طفلك',
          message: 'معاينة خطوات الاختيار والبيانات والتفاصيل.',
        ),
      ),
      _PreviewItem('Home with data', (_) => const _PreviewHome(empty: false)),
      _PreviewItem('Home empty', (_) => const _PreviewHome(empty: true)),
      _PreviewItem('Quick log', (_) => const _PreviewQuickLog()),
      _PreviewItem(
        'Feeding',
        (_) => const _PreviewTimer(
          title: 'رضاعة',
          color: AppColors.mint,
          icon: '🍼',
        ),
      ),
      _PreviewItem(
        'Sleep',
        (_) => const _PreviewTimer(
          title: 'نوم',
          color: AppColors.purple,
          icon: '🌙',
        ),
      ),
      _PreviewItem(
        'Diaper',
        (_) => const _PreviewMessage(
          icon: '🧷',
          title: 'حفاضة',
          message: 'مبللة · متسخة · مبللة ومتسخة',
        ),
      ),
      _PreviewItem(
        'Food',
        (_) => const _PreviewMessage(
          icon: '🥣',
          title: 'طعام',
          message: 'اسم الطعام، الكمية، ملاحظات التفاعل.',
        ),
      ),
      _PreviewItem(
        'Medicine',
        (_) => const _PreviewMessage(
          icon: '💊',
          title: 'دواء',
          message: 'اسم الدواء والجرعة حسب تعليمات الطبيب.',
        ),
      ),
      _PreviewItem(
        'Temperature',
        (_) => const _PreviewMessage(
          icon: '🌡️',
          title: 'حرارة',
          message: 'إدخال رقمي مع تحذير آمن.',
        ),
      ),
      _PreviewItem(
        'Note',
        (_) => const _PreviewMessage(
          icon: '📝',
          title: 'ملاحظة',
          message: 'مساحة نصية كبيرة للحفظ.',
        ),
      ),
      _PreviewItem('Profile', (_) => const _PreviewProfile()),
      _PreviewItem('Assistant', (_) => const _PreviewAssistant()),
      _PreviewItem('More', (_) => const _PreviewMore()),
      _PreviewItem(
        'Night home',
        (_) => const _PreviewHome(empty: false, night: true),
      ),
      _PreviewItem(
        'Loading',
        (_) => const AppPage(child: LoadingSkeleton(height: 180)),
      ),
      _PreviewItem(
        'Error',
        (_) => const AppPage(
          child: ErrorMessageCard(message: 'حدث خطأ. حاولي مرة أخرى.'),
        ),
      ),
    ];
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Design Preview',
              subtitle: 'Debug-only Claude parity gallery',
              showNotification: false,
            ),
            const SizedBox(height: 18),
            SettingsGroup(
              children: items
                  .map(
                    (item) => SettingsRow(
                      icon: Icons.phone_iphone_rounded,
                      title: item.title,
                      color: AppColors.mint,
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: item.builder)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewItem {
  const _PreviewItem(this.title, this.builder);
  final String title;
  final WidgetBuilder builder;
}

class _PreviewAuth extends StatelessWidget {
  const _PreviewAuth({
    required this.title,
    required this.subtitle,
    this.signUp = false,
  });
  final String title;
  final String subtitle;
  final bool signUp;
  @override
  Widget build(BuildContext context) => AppPage(
    padding: const EdgeInsetsDirectional.fromSTEB(24, 64, 24, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumuwHeader(
          title: title,
          subtitle: subtitle,
          leading: AppIconButton(
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.pop(context),
            badge: false,
          ),
        ),
        const SizedBox(height: 28),
        if (signUp) ...[_FakeField('اسمكِ'), const SizedBox(height: 15)],
        const _FakeField('البريد الإلكتروني'),
        const SizedBox(height: 15),
        const _FakeField('كلمة المرور'),
        const SizedBox(height: 18),
        PrimaryButton(
          label: signUp ? 'إنشاء الحساب' : 'تسجيل الدخول',
          onPressed: () {},
        ),
      ],
    ),
  );
}

class _FakeField extends StatelessWidget {
  const _FakeField(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Text(label, style: TextStyle(color: numuwSecondaryTextColor())),
  );
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
    required this.icon,
    required this.title,
    required this.message,
  });
  final String icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: [
        IconBadge(icon: icon, background: AppColors.mintLight, size: 96),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: numuwSecondaryTextColor(), height: 1.7),
        ),
      ],
    ),
  );
}

class _PreviewHome extends StatelessWidget {
  const _PreviewHome({required this.empty, this.night = false});
  final bool empty;
  final bool night;
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: [
        const AppHeader(
          title: 'صباح الخير يا ماما',
          subtitle: 'ليلى · 9 أسابيع و3 أيام',
        ),
        const SizedBox(height: 18),
        const ChildHeroCard(name: 'ليلى', age: '9 أسابيع و3 أيام'),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
          childAspectRatio: .96,
          children: [
            SummaryCard(
              title: 'آخر رضعة',
              value: empty ? 'لا توجد رضعات مسجلة' : '08:20',
              icon: '🍼',
              color: AppColors.peach,
              background: AppColors.peachLight,
            ),
            SummaryCard(
              title: 'نوم اليوم',
              value: empty ? 'لا توجد تسجيلات نوم اليوم' : '11 ساعة',
              icon: '🌙',
              color: AppColors.mint,
              background: AppColors.mintLight,
            ),
            SummaryCard(
              title: 'آخر تغيير حفاضة',
              value: empty ? 'لا توجد تغييرات حفاضة' : '09:15',
              icon: '🧷',
              color: AppColors.purple,
              background: AppColors.purpleLight,
            ),
            SummaryCard(
              title: 'التطعيم القادم',
              value: empty ? 'لم يتم تحديد تطعيم' : 'بعد 6 أيام',
              icon: '💉',
              color: AppColors.yellow,
              background: AppColors.yellowLight,
            ),
          ],
        ),
      ],
    ),
  );
}

class _PreviewQuickLog extends StatelessWidget {
  const _PreviewQuickLog();
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeader(
          title: 'تسجيل سريع ✏️',
          subtitle: 'سجّلي أحداث ليلى اليومية',
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 13,
          runSpacing: 14,
          children: const [
            QuickLogTypeButton(
              label: 'رضاعة',
              icon: '🍼',
              background: AppColors.peachLight,
              border: AppColors.peach,
              onTap: _noop,
            ),
            QuickLogTypeButton(
              label: 'نوم',
              icon: '🌙',
              background: AppColors.mintLight,
              border: AppColors.mint,
              onTap: _noop,
            ),
            QuickLogTypeButton(
              label: 'حفاضة',
              icon: '🧷',
              background: AppColors.purpleLight,
              border: AppColors.purple,
              onTap: _noop,
            ),
            QuickLogTypeButton(
              label: 'طعام',
              icon: '🥣',
              background: AppColors.yellowLight,
              border: AppColors.yellow,
              onTap: _noop,
            ),
          ],
        ),
      ],
    ),
  );
}

void _noop() {}

class _PreviewTimer extends StatelessWidget {
  const _PreviewTimer({
    required this.title,
    required this.color,
    required this.icon,
  });
  final String title;
  final Color color;
  final String icon;
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: [
        NumuwHeader(
          title: title,
          subtitle: 'معاينة المؤقت',
          leading: AppIconButton(
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.pop(context),
            badge: false,
          ),
          trailing: IconBadge(
            icon: icon,
            background: color.withValues(alpha: .14),
          ),
        ),
        const SizedBox(height: 18),
        TimerCard(
          time: '00:12',
          status: 'جارية الآن',
          color: color,
          active: true,
          buttonLabel: 'إيقاف وحفظ',
          onPressed: () {},
        ),
      ],
    ),
  );
}

class _PreviewProfile extends StatelessWidget {
  const _PreviewProfile();
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: const [
        AppHeader(title: 'ليلى', subtitle: '9 أسابيع و3 أيام'),
        SizedBox(height: 18),
        ChildHeroCard(name: 'ليلى', age: '9 أسابيع و3 أيام'),
        SizedBox(height: 18),
        GrowthCard(
          title: 'آخر وزن',
          value: '5.2 كجم',
          subtitle: 'بيانات تجريبية للمعاينة فقط',
        ),
      ],
    ),
  );
}

class _PreviewAssistant extends StatelessWidget {
  const _PreviewAssistant();
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: const [
        AppHeader(
          title: 'اسألي المساعد',
          subtitle: 'واجهة آمنة لتنظيم البيانات',
        ),
        SizedBox(height: 18),
        WarningBanner(message: 'لا يشخص ولا يصف علاجًا.'),
        SizedBox(height: 18),
        SoftCard(child: Text('كيف يمكنني مساعدتكِ في تنظيم بيانات طفلك؟')),
      ],
    ),
  );
}

class _PreviewMore extends StatelessWidget {
  const _PreviewMore();
  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: const [
        AppHeader(title: 'المزيد', subtitle: 'الإعدادات والخدمات'),
        SizedBox(height: 18),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.nightlight_round,
              title: 'وضع الليل الهادئ',
              color: AppColors.nightGold,
            ),
          ],
        ),
      ],
    ),
  );
}
