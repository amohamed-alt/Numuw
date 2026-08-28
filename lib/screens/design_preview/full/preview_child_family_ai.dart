import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/numuw_classy_components.dart';
import '../../../widgets/numuw_motion_widgets.dart';
import 'preview_shared.dart';

class PreviewChildOverviewScreen extends StatelessWidget {
  const PreviewChildOverviewScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'طفلي',
    trailing: IconButton(onPressed: previewNoop, icon: const Icon(Icons.edit_outlined)),
    child: Column(
      children: [
        const SizedBox(height: 6),
        const NumuwChildIdentity(name: 'ليان أحمد', age: '9 أشهر و12 يوم'),
        const SizedBox(height: 14),
        const Row(
          children: [
            PreviewMiniStat(label: 'الوزن', value: '8.6 كجم'),
            SizedBox(width: 8),
            PreviewMiniStat(label: 'الطول', value: '70 سم', color: AppColors.info),
            SizedBox(width: 8),
            PreviewMiniStat(label: 'فصيلة الدم', value: 'O+', color: Color(0xFF8D7399)),
          ],
        ),
        const SizedBox(height: 16),
        PreviewSectionCard(
          title: 'ملف ليان',
          child: Column(
            children: [
              const PreviewInfoRow(
                label: 'تاريخ الميلاد',
                value: '16 نوفمبر 2025',
                icon: Icons.cake_outlined,
              ),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(
                label: 'نوع الرضاعة',
                value: 'رضاعة طبيعية',
                icon: Icons.water_drop_outlined,
              ),
              Divider(color: previewBorder(context)),
              const PreviewInfoRow(
                label: 'مشاركة العيلة',
                value: '3 أشخاص لديهم وصول',
                icon: Icons.family_restroom_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NumuwClassyButton(
          label: 'تعديل معلومات الطفل',
          variant: NumuwButtonVariant.secondary,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}

class PreviewGrowthScreen extends StatefulWidget {
  const PreviewGrowthScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewGrowthScreen> createState() => _PreviewGrowthScreenState();
}

class _PreviewGrowthScreenState extends State<PreviewGrowthScreen> {
  String metric = 'weight';

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'متابعة النمو',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumuwSegmentedControl(
          items: const {'weight': 'الوزن', 'height': 'الطول', 'head': 'محيط الرأس'},
          value: metric,
          onChanged: (value) => setState(() => metric = value),
        ),
        const SizedBox(height: 18),
        PreviewSectionCard(
          title: switch (metric) {
            'height' => 'الطول (سم)',
            'head' => 'محيط الرأس (سم)',
            _ => 'الوزن (كجم)',
          },
          action: const PreviewStatusPill(label: 'آخر قياس: اليوم'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (metric) {
                  'height' => '70',
                  'head' => '44.2',
                  _ => '8.6',
                },
                style: TextStyle(
                  color: previewText(context),
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'السجل يعرض القياسات التي أدخلتِها فقط',
                style: TextStyle(
                  color: previewSecondary(context),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              const PreviewChart(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const PreviewSafetyNote(
          text:
              'منحنى نُموّ يساعدك على رؤية قياساتك المسجلة بوضوح؛ ولا يمثل تشخيصاً أو تقييماً طبياً.',
        ),
        const SizedBox(height: 16),
        const NumuwClassyButton(
          label: 'تسجيل قياس جديد',
          icon: Icons.add_rounded,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}

class PreviewVaccinationsScreen extends StatefulWidget {
  const PreviewVaccinationsScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewVaccinationsScreen> createState() => _PreviewVaccinationsScreenState();
}

class _PreviewVaccinationsScreenState extends State<PreviewVaccinationsScreen> {
  String tab = 'upcoming';

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'التطعيمات',
    child: Column(
      children: [
        NumuwSegmentedControl(
          items: const {'upcoming': 'القادمة', 'completed': 'المكتملة'},
          value: tab,
          onChanged: (value) => setState(() => tab = value),
        ),
        const SizedBox(height: 16),
        if (tab == 'upcoming') ...[
          const _VaccinationCard(
            title: 'الجرعة التالية',
            subtitle: '2 سبتمبر 2026',
            due: 'بعد 4 أيام',
            color: AppColors.info,
          ),
          const SizedBox(height: 10),
          const _VaccinationCard(
            title: 'الجرعة التالية',
            subtitle: '20 سبتمبر 2026',
            due: 'بعد 22 يوماً',
            color: Color(0xFF8D7399),
          ),
          const SizedBox(height: 10),
          const _VaccinationCard(
            title: 'تطعيم مجدول',
            subtitle: '2 أكتوبر 2026',
            due: 'بعد 34 يوماً',
            color: AppColors.sage,
          ),
        ] else ...[
          const _VaccinationCard(
            title: 'تطعيم مكتمل',
            subtitle: '15 أغسطس 2026',
            due: 'مكتمل',
            color: AppColors.success,
          ),
          const SizedBox(height: 10),
          const _VaccinationCard(
            title: 'تطعيم مكتمل',
            subtitle: '20 يونيو 2026',
            due: 'مكتمل',
            color: AppColors.success,
          ),
        ],
        const SizedBox(height: 18),
        const NumuwClassyButton(
          label: 'إضافة موعد تطعيم',
          icon: Icons.add_rounded,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}

class _VaccinationCard extends StatelessWidget {
  const _VaccinationCard({
    required this.title,
    required this.subtitle,
    required this.due,
    required this.color,
  });
  final String title;
  final String subtitle;
  final String due;
  final Color color;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    child: Row(
      children: [
        PreviewIcon(icon: Icons.vaccines_outlined, color: color, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: previewText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: previewSecondary(context),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        PreviewStatusPill(label: due, color: color),
      ],
    ),
  );
}

class PreviewFamilyTasksScreen extends StatefulWidget {
  const PreviewFamilyTasksScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewFamilyTasksScreen> createState() => _PreviewFamilyTasksScreenState();
}

class _PreviewFamilyTasksScreenState extends State<PreviewFamilyTasksScreen> {
  final done = <int>{1};

  @override
  Widget build(BuildContext context) {
    final tasks = [
      ('شراء حفاضات', 'ماما', AppColors.plum),
      ('تجهيز شنطة التطعيم', 'بابا', AppColors.info),
      ('تحديث قياس الوزن', 'العيلة', AppColors.sage),
    ];
    return PreviewScreenScaffold(
      black: widget.black,
      title: 'مهام العيلة',
      child: Column(
        children: [
          const PreviewPageIntro(
            title: 'العناية موزعة بوضوح',
            subtitle: 'كل شخص يعرف المطلوب منه بدون رسائل متفرقة.',
            icon: Icons.assignment_turned_in_outlined,
          ),
          const SizedBox(height: 18),
          NumuwClassySurface(
            child: Column(
              children: List.generate(tasks.length, (index) {
                final task = tasks[index];
                final checked = done.contains(index);
                return Column(
                  children: [
                    CheckboxListTile(
                      value: checked,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (_) => setState(() {
                        if (checked) {
                          done.remove(index);
                        } else {
                          done.add(index);
                        }
                      }),
                      title: Text(
                        task.$1,
                        style: TextStyle(
                          decoration: checked ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text('مسندة إلى: ${task.$2}'),
                      secondary: PreviewStatusPill(
                        label: checked ? 'تم' : 'مفتوحة',
                        color: checked ? AppColors.success : task.$3,
                      ),
                    ),
                    if (index != tasks.length - 1)
                      Divider(color: previewBorder(context)),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const NumuwClassyButton(
            label: 'إضافة مهمة',
            icon: Icons.add_rounded,
            onPressed: previewNoop,
          ),
        ],
      ),
    );
  }
}

class PreviewDoctorQuestionsScreen extends StatefulWidget {
  const PreviewDoctorQuestionsScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewDoctorQuestionsScreen> createState() =>
      _PreviewDoctorQuestionsScreenState();
}

class _PreviewDoctorQuestionsScreenState extends State<PreviewDoctorQuestionsScreen> {
  final answered = <int>{1};

  @override
  Widget build(BuildContext context) {
    final questions = [
      'هل نمط النوم الحالي مناسب لعمر ليان؟',
      'متى نبدأ نوع الطعام التالي؟',
      'هل نحتاج متابعة إضافية بعد التطعيم؟',
    ];
    return PreviewScreenScaffold(
      black: widget.black,
      title: 'أسئلة الطبيب',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewPageIntro(
            title: 'لا تنسي ما أردتِ سؤاله',
            subtitle: 'احفظي السؤال وقت حدوثه، وراجعي القائمة قبل الزيارة.',
            icon: Icons.help_outline_rounded,
          ),
          const SizedBox(height: 18),
          ...List.generate(questions.length, (index) {
            final done = answered.contains(index);
            return Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: PreviewChoiceCard(
                icon: done ? Icons.check_rounded : Icons.chat_bubble_outline_rounded,
                title: questions[index],
                subtitle: done ? 'تمت الإجابة' : 'معلّق',
                selected: done,
                color: done ? AppColors.success : AppColors.info,
                onTap: () => setState(() {
                  if (done) {
                    answered.remove(index);
                  } else {
                    answered.add(index);
                  }
                }),
              ),
            );
          }),
          const SizedBox(height: 8),
          const NumuwClassyButton(
            label: 'إضافة سؤال',
            icon: Icons.add_rounded,
            onPressed: previewNoop,
          ),
        ],
      ),
    );
  }
}

class PreviewAssistantScreen extends StatefulWidget {
  const PreviewAssistantScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewAssistantScreen> createState() => _PreviewAssistantScreenState();
}

class _PreviewAssistantScreenState extends State<PreviewAssistantScreen> {
  bool conversation = false;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'مساعد نُموّ',
    trailing: const PreviewStatusPill(label: 'AI'),
    child: Column(
      children: [
        const PreviewSafetyNote(
          text:
              'المساعد يرتب سجلاتك وأسئلتك ولا يستبدل الطبيب أو يقدم تشخيصاً طبياً.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: NumuwClassySurface(
                onTap: () => setState(() => conversation = true),
                child: const Column(
                  children: [
                    PreviewIcon(icon: Icons.description_outlined, size: 42),
                    SizedBox(height: 8),
                    Text('ملخص للطبيب', style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NumuwClassySurface(
                onTap: () => setState(() => conversation = true),
                child: const Column(
                  children: [
                    PreviewIcon(icon: Icons.question_mark_rounded, color: AppColors.info, size: 42),
                    SizedBox(height: 8),
                    Text('صياغة سؤال', style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        NumuwClassySurface(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 300),
            child: conversation
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ChatBubble(
                        text: 'جهزي لي ملخصاً لآخر يومين قبل زيارة الطبيب.',
                        user: true,
                      ),
                      _ChatBubble(
                        text:
                            'خلال آخر يومين سُجلت 9 رضعات، 5 تغييرات حفاضة، ومدة النوم المسجلة 12 ساعة إجمالاً. يوجد أيضاً سؤالان معلّقان للطبيب. أقدر أرتبها في نقاط مختصرة للتقرير.',
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PreviewIcon(icon: Icons.auto_awesome_rounded, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'كيف أقدر أساعدك اليوم؟',
                        style: TextStyle(
                          color: previewText(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'اختاري إجراءً سريعاً أو اكتبي سؤالك.',
                        style: TextStyle(color: previewSecondary(context), fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        NumuwClassySurface(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'اكتبي سؤالك للطبيب…',
                  style: TextStyle(color: previewSecondary(context), fontSize: 13),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: previewAccent(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, this.user = false});
  final String text;
  final bool user;

  @override
  Widget build(BuildContext context) => Align(
    alignment: user ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 290),
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: user ? previewAccent(context) : previewRaised(context),
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(18),
          topEnd: const Radius.circular(18),
          bottomStart: Radius.circular(user ? 18 : 5),
          bottomEnd: Radius.circular(user ? 5 : 18),
        ),
        border: user ? null : Border.all(color: previewBorder(context)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: user
              ? (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.nightBackground
                    : Colors.white)
              : previewText(context),
          fontSize: 12.5,
          height: 1.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class PreviewPumpingAnalyticsScreen extends StatelessWidget {
  const PreviewPumpingAnalyticsScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'تحليل الشفط',
    child: Column(
      children: [
        const Row(
          children: [
            PreviewMiniStat(label: 'إجمالي 7 أيام', value: '1,240 مل'),
            SizedBox(width: 8),
            PreviewMiniStat(label: 'الجلسات', value: '14', color: AppColors.info),
            SizedBox(width: 8),
            PreviewMiniStat(label: 'المتوسط', value: '89 مل', color: Color(0xFF8D7399)),
          ],
        ),
        const SizedBox(height: 14),
        const PreviewSectionCard(
          title: 'آخر 7 أيام',
          action: PreviewStatusPill(label: '+8%', color: AppColors.success),
          child: PreviewChart(color: AppColors.plum),
        ),
        const SizedBox(height: 14),
        const PreviewSafetyNote(
          text:
              'هذه مقارنة للسجلات فقط وليست مؤشراً طبياً على كمية الحليب أو كفايتها.',
        ),
        const SizedBox(height: 14),
        const PreviewSectionCard(
          title: 'الجلسات الأخيرة',
          child: Column(
            children: [
              NumuwTimelineRow(title: 'شفط 110 مل', subtitle: 'الجانبان · 14 دقيقة', time: '12:10'),
              NumuwTimelineRow(title: 'شفط 85 مل', subtitle: 'اليمين · 11 دقيقة', time: '08:40'),
              NumuwTimelineRow(title: 'شفط 95 مل', subtitle: 'الجانبان · 13 دقيقة', time: '05:20', isLast: true),
            ],
          ),
        ),
      ],
    ),
  );
}
