import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/numuw_classy_components.dart';
import '../../widgets/numuw_motion_widgets.dart';
import 'design_preview_gallery.dart';
import 'full/preview_auth_onboarding.dart';
import 'full/preview_care_flows.dart';
import 'full/preview_child_family_ai.dart';
import 'full/preview_home.dart';
import 'full/preview_more_states.dart';

class FullAppPreview extends StatefulWidget {
  const FullAppPreview({super.key});

  @override
  State<FullAppPreview> createState() => _FullAppPreviewState();
}

class _FullAppPreviewState extends State<FullAppPreview> {
  bool black = false;

  @override
  Widget build(BuildContext context) {
    final groups = <_PreviewGroup>[
      _PreviewGroup(
        title: '01 · البداية والحساب',
        subtitle: 'Splash, Welcome, Authentication, Onboarding',
        screens: [
          _PreviewLink('Splash', Icons.spa_outlined, (black) => PreviewSplashScreen(black: black)),
          _PreviewLink('Welcome', Icons.favorite_outline_rounded, (black) => PreviewWelcomeScreen(black: black)),
          _PreviewLink('تسجيل الدخول', Icons.login_rounded, (black) => PreviewSignInScreen(black: black)),
          _PreviewLink('إنشاء حساب', Icons.person_add_alt_1_rounded, (black) => PreviewSignUpScreen(black: black)),
          _PreviewLink('تأكيد البريد', Icons.mark_email_unread_outlined, (black) => PreviewEmailConfirmationScreen(black: black)),
          _PreviewLink('Onboarding · المرحلة', Icons.child_care_outlined, (black) => PreviewOnboardingStageScreen(black: black)),
          _PreviewLink('Onboarding · التفاصيل', Icons.badge_outlined, (black) => PreviewOnboardingDetailsScreen(black: black)),
          _PreviewLink('Onboarding · اللمسات الأخيرة', Icons.auto_awesome_outlined, (black) => PreviewOnboardingOptionalScreen(black: black)),
        ],
      ),
      _PreviewGroup(
        title: '02 · الرئيسية والرعاية اليومية',
        subtitle: 'Home + every repeated care interaction',
        screens: [
          _PreviewLink('الرئيسية', Icons.home_outlined, (black) => PreviewHomeScreen(black: black)),
          _PreviewLink('تسجيل سريع', Icons.add_circle_outline_rounded, (black) => PreviewQuickLogScreen(black: black)),
          _PreviewLink('رضاعة', Icons.water_drop_outlined, (black) => PreviewFeedingScreen(black: black)),
          _PreviewLink('شفط', Icons.opacity_rounded, (black) => PreviewPumpingScreen(black: black)),
          _PreviewLink('نوم', Icons.dark_mode_outlined, (black) => PreviewSleepScreen(black: black)),
          _PreviewLink('حفاضة', Icons.baby_changing_station_outlined, (black) => PreviewDiaperScreen(black: black)),
          _PreviewLink('طعام', Icons.restaurant_outlined, (black) => PreviewFoodScreen(black: black)),
          _PreviewLink('دواء', Icons.medication_outlined, (black) => PreviewMedicineScreen(black: black)),
          _PreviewLink('حرارة', Icons.thermostat_outlined, (black) => PreviewTemperatureScreen(black: black)),
          _PreviewLink('ملاحظة', Icons.edit_note_outlined, (black) => PreviewNoteScreen(black: black)),
          _PreviewLink('تفاصيل / تعديل نشاط', Icons.receipt_long_outlined, (black) => PreviewEventDetailsScreen(black: black)),
        ],
      ),
      _PreviewGroup(
        title: '03 · الطفل والنمو والصحة',
        subtitle: 'Profile, growth, vaccinations and care planning',
        screens: [
          _PreviewLink('ملف الطفل', Icons.child_care_rounded, (black) => PreviewChildOverviewScreen(black: black)),
          _PreviewLink('متابعة النمو', Icons.show_chart_rounded, (black) => PreviewGrowthScreen(black: black)),
          _PreviewLink('التطعيمات', Icons.vaccines_outlined, (black) => PreviewVaccinationsScreen(black: black)),
          _PreviewLink('مهام العيلة', Icons.assignment_turned_in_outlined, (black) => PreviewFamilyTasksScreen(black: black)),
          _PreviewLink('أسئلة الطبيب', Icons.help_outline_rounded, (black) => PreviewDoctorQuestionsScreen(black: black)),
          _PreviewLink('تحليل الشفط', Icons.analytics_outlined, (black) => PreviewPumpingAnalyticsScreen(black: black)),
        ],
      ),
      _PreviewGroup(
        title: '04 · المساعد والعيلة والخدمات',
        subtitle: 'AI assistant, family access, reports and settings',
        screens: [
          _PreviewLink('مساعد نُموّ', Icons.auto_awesome_outlined, (black) => PreviewAssistantScreen(black: black)),
          _PreviewLink('المزيد / الإعدادات', Icons.grid_view_rounded, (black) => PreviewMoreScreen(black: black)),
          _PreviewLink('مشاركة العيلة', Icons.family_restroom_rounded, (black) => PreviewFamilySharingScreen(black: black)),
          _PreviewLink('كارت الأسبوع', Icons.ios_share_rounded, (black) => PreviewWeeklyShareScreen(black: black)),
        ],
      ),
      _PreviewGroup(
        title: '05 · System states',
        subtitle: 'Nothing should ever feel broken or unfinished',
        screens: [
          _PreviewLink('Loading', Icons.hourglass_empty_rounded, (black) => PreviewLoadingStateScreen(black: black)),
          _PreviewLink('Empty', Icons.inbox_outlined, (black) => PreviewEmptyStateScreen(black: black)),
          _PreviewLink('Error', Icons.cloud_off_outlined, (black) => PreviewErrorStateScreen(black: black)),
          _PreviewLink('Success', Icons.check_circle_outline_rounded, (black) => PreviewSuccessStateScreen(black: black)),
        ],
      ),
    ];

    final total = groups.fold<int>(0, (sum, group) => sum + group.screens.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 42),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.roseMist,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.local_florist_rounded, color: AppColors.plum),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NUMUW · FULL DESIGN PREVIEW',
                          style: TextStyle(
                            color: AppColors.plum,
                            fontSize: 10,
                            letterSpacing: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Classy Motherhood App',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$total شاشة Preview مبنية على وظائف Numuw الحالية. بدّلي بين Light وBlack ثم افتحي أي flow. لا توجد أي بيانات حقيقية أو production writes هنا.',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12.5,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.all(5),
                decoration: BoxDecoration(
                  color: AppColors.neutralSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ThemeChoice(
                        label: 'Light · Porcelain',
                        icon: Icons.light_mode_outlined,
                        selected: !black,
                        onTap: () => setState(() => black = false),
                      ),
                    ),
                    Expanded(
                      child: _ThemeChoice(
                        label: 'Black edition',
                        icon: Icons.dark_mode_outlined,
                        selected: black,
                        onTap: () => setState(() => black = true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              NumuwClassySurface(
                onTap: () => Navigator.of(context).push(
                  numuwPageRoute((_) => const DesignPreviewGallery()),
                ),
                child: const Row(
                  children: [
                    _LabIcon(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Design System + Component + Motion Lab',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'الألوان، Black variants، Buttons، Components، Animations',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded, color: AppColors.mutedText),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              for (final group in groups) ...[
                _GroupHeader(group: group),
                const SizedBox(height: 10),
                ...group.screens.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 9),
                    child: _ScreenRow(
                      screen: entry.value,
                      index: entry.key + 1,
                      black: black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.all(15),
                decoration: BoxDecoration(
                  color: AppColors.roseMist,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.plumSoft),
                ),
                child: const Text(
                  'Preview branch only · design/classy-motherhood-v1\nProduction data logic and main routing remain untouched until design approval.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.plumDark,
                    fontSize: 11.5,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    onTap: onTap,
    child: AnimatedContainer(
      duration: NumuwMotion.fast,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: selected ? NumuwElevation.card : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? AppColors.plum : AppColors.secondaryText, size: 17),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.text : AppColors.secondaryText,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});
  final _PreviewGroup group;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        group.title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        group.subtitle,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
      ),
    ],
  );
}

class _ScreenRow extends StatelessWidget {
  const _ScreenRow({required this.screen, required this.index, required this.black});
  final _PreviewLink screen;
  final int index;
  final bool black;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    onTap: () => Navigator.of(context).push(
      numuwPageRoute((_) => screen.builder(black)),
    ),
    padding: const EdgeInsetsDirectional.fromSTEB(13, 12, 13, 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: black ? AppColors.nightPrimarySoft : AppColors.roseMist,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            screen.icon,
            color: black ? AppColors.nightPrimary : AppColors.plum,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            screen.title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          index.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 7),
        const Icon(Icons.chevron_left_rounded, color: AppColors.mutedText, size: 19),
      ],
    ),
  );
}

class _LabIcon extends StatelessWidget {
  const _LabIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.plum,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Icon(Icons.widgets_outlined, color: Colors.white, size: 20),
  );
}

class _PreviewGroup {
  const _PreviewGroup({required this.title, required this.subtitle, required this.screens});
  final String title;
  final String subtitle;
  final List<_PreviewLink> screens;
}

class _PreviewLink {
  const _PreviewLink(this.title, this.icon, this.builder);
  final String title;
  final IconData icon;
  final Widget Function(bool black) builder;
}
