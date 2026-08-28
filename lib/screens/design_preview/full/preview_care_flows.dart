import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/numuw_classy_components.dart';
import '../../../widgets/numuw_motion_widgets.dart';
import 'preview_shared.dart';

class PreviewQuickLogScreen extends StatelessWidget {
  const PreviewQuickLogScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'تسجيل سريع',
    subtitle: 'أفعال يوم ليان',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const PreviewPageIntro(
          title: 'ما الذي حدث الآن؟',
          subtitle: 'اختاري الحدث؛ أغلب التسجيلات لا تحتاج أكثر من ثوانٍ.',
          eyebrow: 'QUICK LOG',
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 15,
          runSpacing: 20,
          children: const [
            NumuwQuickAction(
              label: 'رضاعة',
              icon: Icons.water_drop_outlined,
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'شفط',
              icon: Icons.opacity_rounded,
              tint: AppColors.lavenderSoft,
              accent: Color(0xFF8D7399),
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'نوم',
              icon: Icons.dark_mode_outlined,
              tint: AppColors.lavenderSoft,
              accent: Color(0xFF8D7399),
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'حفاضة',
              icon: Icons.baby_changing_station_outlined,
              tint: AppColors.powderSoft,
              accent: AppColors.info,
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'طعام',
              icon: Icons.restaurant_rounded,
              tint: AppColors.champagneSoft,
              accent: AppColors.warning,
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'دواء',
              icon: Icons.medication_outlined,
              tint: AppColors.peachLight,
              accent: AppColors.danger,
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'حرارة',
              icon: Icons.thermostat_rounded,
              tint: AppColors.peachLight,
              accent: AppColors.danger,
              onTap: previewNoop,
            ),
            NumuwQuickAction(
              label: 'ملاحظة',
              icon: Icons.edit_note_rounded,
              tint: AppColors.sageSoft,
              accent: AppColors.sage,
              onTap: previewNoop,
            ),
          ],
        ),
        const SizedBox(height: 28),
        const PreviewSectionCard(
          title: 'سجل اليوم',
          icon: Icons.schedule_rounded,
          child: Column(
            children: [
              NumuwTimelineRow(
                title: 'رضاعة طبيعية',
                subtitle: '15 دقيقة · يمين',
                time: '12:30',
              ),
              NumuwTimelineRow(
                title: 'حفاضة مبللة',
                subtitle: 'تم التسجيل بسرعة',
                time: '11:20',
                color: AppColors.info,
              ),
              NumuwTimelineRow(
                title: 'نوم',
                subtitle: 'ساعة و20 دقيقة',
                time: '10:10',
                color: Color(0xFF8D7399),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PreviewFeedingScreen extends StatefulWidget {
  const PreviewFeedingScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewFeedingScreen> createState() => _PreviewFeedingScreenState();
}

class _PreviewFeedingScreenState extends State<PreviewFeedingScreen> {
  bool active = false;
  String side = 'right';
  String method = 'breast';
  bool burped = true;
  bool vomited = false;
  int amount = 60;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'تسجيل رضاعة',
    trailing: NumuwPulseDot(active: active),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        PreviewSectionCard(
          title: active ? 'الرضعة جارية الآن' : 'جاهزة للبدء',
          icon: Icons.water_drop_outlined,
          child: Column(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  active ? '00 : 18 : 42' : '00 : 00',
                  style: TextStyle(
                    color: previewText(context),
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              NumuwClassyButton(
                label: active ? 'إيقاف وحفظ' : 'بدء الرضاعة',
                icon: active ? Icons.stop_rounded : Icons.play_arrow_rounded,
                variant: active
                    ? NumuwButtonVariant.black
                    : NumuwButtonVariant.primary,
                onPressed: () => setState(() => active = !active),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PreviewSectionCard(
          title: 'الجهة',
          child: NumuwSegmentedControl(
            items: const {'right': 'يمين', 'left': 'يسار', 'both': 'كلاهما'},
            value: side,
            onChanged: (value) => setState(() => side = value),
          ),
        ),
        const SizedBox(height: 14),
        PreviewSectionCard(
          title: 'طريقة الرضعة',
          child: NumuwSegmentedControl(
            items: const {'breast': 'طبيعية', 'bottle': 'زجاجة', 'formula': 'صناعية'},
            value: method,
            onChanged: (value) => setState(() => method = value),
          ),
        ),
        const SizedBox(height: 14),
        PreviewSectionCard(
          title: 'الكمية',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => amount = (amount - 10).clamp(0, 300)),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  const SizedBox(width: 10),
                  NumuwAnimatedNumber(
                    value: amount.toDouble(),
                    builder: (context, value) => Text(
                      '${value.round()} مل',
                      style: TextStyle(
                        color: previewText(context),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => setState(() => amount = (amount + 10).clamp(0, 300)),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                children: [30, 60, 90, 120]
                    .map(
                      (value) => ActionChip(
                        label: Text('$value مل'),
                        onPressed: () => setState(() => amount = value),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PreviewSectionCard(
          title: 'بعد الرضعة',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تجشّأت'),
                value: burped,
                onChanged: (v) => setState(() => burped = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('استفرغت'),
                value: vomited,
                onChanged: (v) => setState(() => vomited = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const PreviewField(
          label: 'ملاحظة اختيارية',
          hint: 'أي تفصيل تحبين الرجوع له لاحقاً',
          multiline: true,
        ),
      ],
    ),
  );
}

class PreviewPumpingScreen extends StatefulWidget {
  const PreviewPumpingScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewPumpingScreen> createState() => _PreviewPumpingScreenState();
}

class _PreviewPumpingScreenState extends State<PreviewPumpingScreen> {
  bool active = true;
  bool split = true;
  String side = 'both';
  int total = 110;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'جلسة شفط',
    trailing: NumuwPulseDot(active: active),
    child: Column(
      children: [
        PreviewSectionCard(
          title: active ? 'جلسة نشطة' : 'جاهزة للبدء',
          icon: Icons.opacity_rounded,
          child: Column(
            children: [
              Text(
                active ? '00 : 14 : 08' : '00 : 00',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: previewText(context),
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              NumuwClassyButton(
                label: active ? 'إيقاف المؤقت' : 'بدء مؤقت الشفط',
                variant: active
                    ? NumuwButtonVariant.black
                    : NumuwButtonVariant.primary,
                onPressed: () => setState(() => active = !active),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PreviewSectionCard(
          title: 'الجهة',
          child: NumuwSegmentedControl(
            items: const {'left': 'يسار', 'right': 'يمين', 'both': 'الجانبان'},
            value: side,
            onChanged: (value) => setState(() => side = value),
          ),
        ),
        const SizedBox(height: 14),
        PreviewSectionCard(
          title: 'الكمية',
          child: Column(
            children: [
              Row(
                children: [
                  PreviewMiniStat(label: 'الإجمالي', value: '$total مل'),
                  const SizedBox(width: 8),
                  const PreviewMiniStat(label: 'اليسار', value: '50 مل', color: AppColors.info),
                  const SizedBox(width: 8),
                  const PreviewMiniStat(label: 'اليمين', value: '60 مل', color: Color(0xFF8D7399)),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تقسيم الكمية بين الجانبين'),
                value: split,
                onChanged: (value) => setState(() => split = value),
              ),
              if (split) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(child: PreviewField(label: 'يسار', value: '50 مل')),
                    SizedBox(width: 10),
                    Expanded(child: PreviewField(label: 'يمين', value: '60 مل')),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NumuwClassyButton(label: 'حفظ جلسة الشفط', onPressed: previewNoop),
        const SizedBox(height: 16),
        const PreviewSafetyNote(
          text: 'المقارنات مبنية على سجلاتك فقط وليست تقييماً طبياً لإدرار الحليب.',
        ),
      ],
    ),
  );
}

class PreviewSleepScreen extends StatefulWidget {
  const PreviewSleepScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewSleepScreen> createState() => _PreviewSleepScreenState();
}

class _PreviewSleepScreenState extends State<PreviewSleepScreen> {
  bool asleep = true;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'النوم',
    child: Column(
      children: [
        const SizedBox(height: 8),
        NumuwFadeSlideIn(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 20),
            decoration: BoxDecoration(
              color: previewSurface(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: previewBorder(context)),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? const []
                  : NumuwElevation.card,
            ),
            child: Column(
              children: [
                const PreviewIcon(
                  icon: Icons.dark_mode_rounded,
                  color: Color(0xFF8D7399),
                  background: AppColors.lavenderSoft,
                  size: 74,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NumuwPulseDot(color: const Color(0xFF8D7399), active: asleep),
                    const SizedBox(width: 4),
                    Text(
                      asleep ? 'ليان تنام الآن' : 'جاهزة لجلسة نوم',
                      style: TextStyle(
                        color: previewSecondary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  asleep ? '01 : 12 : 34' : '00 : 00',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: previewText(context),
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 16),
                NumuwClassyButton(
                  label: asleep ? 'استيقظت — حفظ النوم' : 'بدء النوم',
                  variant: asleep
                      ? NumuwButtonVariant.black
                      : NumuwButtonVariant.primary,
                  onPressed: () => setState(() => asleep = !asleep),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const PreviewInfoRow(
          label: 'وقت البدء',
          value: '10:20 مساءً',
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(height: 8),
        const PreviewField(label: 'ملاحظات اختيارية', multiline: true),
      ],
    ),
  );
}

class PreviewDiaperScreen extends StatefulWidget {
  const PreviewDiaperScreen({super.key, required this.black});
  final bool black;

  @override
  State<PreviewDiaperScreen> createState() => _PreviewDiaperScreenState();
}

class _PreviewDiaperScreenState extends State<PreviewDiaperScreen> {
  String type = 'wet';

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: widget.black,
    title: 'حفاضة',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewPageIntro(
          title: 'تغيير حفاضة',
          subtitle: 'ثلاثة اختيارات واضحة؛ بدون أسئلة غير ضرورية.',
          icon: Icons.baby_changing_station_outlined,
        ),
        const SizedBox(height: 22),
        PreviewChoiceCard(
          icon: Icons.water_drop_outlined,
          title: 'مبللة',
          subtitle: 'بول فقط',
          selected: type == 'wet',
          color: AppColors.info,
          onTap: () => setState(() => type = 'wet'),
        ),
        const SizedBox(height: 10),
        PreviewChoiceCard(
          icon: Icons.circle_rounded,
          title: 'متسخة',
          subtitle: 'براز فقط',
          selected: type == 'dirty',
          color: AppColors.warning,
          onTap: () => setState(() => type = 'dirty'),
        ),
        const SizedBox(height: 10),
        PreviewChoiceCard(
          icon: Icons.baby_changing_station_rounded,
          title: 'مبللة ومتسخة',
          subtitle: 'بول وبراز',
          selected: type == 'both',
          color: const Color(0xFF8D7399),
          onTap: () => setState(() => type = 'both'),
        ),
        const SizedBox(height: 18),
        const PreviewField(label: 'ملاحظة اختيارية', multiline: true),
        const SizedBox(height: 18),
        const NumuwClassyButton(label: 'حفظ الحفاضة', onPressed: previewNoop),
      ],
    ),
  );
}

class PreviewFoodScreen extends StatelessWidget {
  const PreviewFoodScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'طعام',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewPageIntro(
          title: 'تسجيل وجبة',
          subtitle: 'ما أكلته ليان وأي تفاعل لاحظتِه بعدها.',
          icon: Icons.restaurant_rounded,
        ),
        const SizedBox(height: 22),
        const PreviewField(label: 'اسم الطعام', value: 'أفوكادو مهروس'),
        const SizedBox(height: 13),
        const PreviewField(label: 'الكمية أو الوصف', value: '4 ملاعق صغيرة'),
        const SizedBox(height: 13),
        const PreviewField(
          label: 'ملاحظات التفاعل',
          hint: 'أعجبها / رفضته / أي ملاحظة',
          multiline: true,
        ),
        const SizedBox(height: 18),
        const NumuwClassyButton(label: 'حفظ الوجبة', onPressed: previewNoop),
      ],
    ),
  );
}

class PreviewMedicineScreen extends StatelessWidget {
  const PreviewMedicineScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'دواء',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewPageIntro(
          title: 'توثيق الدواء',
          subtitle: 'سجّلي فقط ما تم إعطاؤه حسب تعليمات الطبيب.',
          icon: Icons.medication_outlined,
        ),
        const SizedBox(height: 22),
        const PreviewField(label: 'اسم الدواء', value: 'الدواء الموصوف'),
        const SizedBox(height: 13),
        const PreviewField(label: 'الجرعة', value: '2.5 مل'),
        const SizedBox(height: 13),
        const PreviewInfoRow(
          label: 'وقت التسجيل',
          value: 'اليوم · 8:30 مساءً',
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(height: 12),
        const PreviewSafetyNote(
          warning: true,
          text:
              'نُموّ لا يقدّم جرعات أو وصفات دوائية. اتبعي تعليمات الطبيب أو الجهة الصحية فقط.',
        ),
        const SizedBox(height: 16),
        const PreviewField(label: 'ملاحظة اختيارية', multiline: true),
        const SizedBox(height: 18),
        const NumuwClassyButton(label: 'حفظ الدواء', onPressed: previewNoop),
      ],
    ),
  );
}

class PreviewTemperatureScreen extends StatelessWidget {
  const PreviewTemperatureScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'درجة الحرارة',
    child: Column(
      children: [
        const SizedBox(height: 10),
        const PreviewIcon(
          icon: Icons.thermostat_rounded,
          color: AppColors.danger,
          background: AppColors.peachLight,
          size: 78,
        ),
        const SizedBox(height: 16),
        Text(
          '37.4°',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: previewText(context),
            fontSize: 48,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'مئوية',
          style: TextStyle(color: previewSecondary(context), fontSize: 12),
        ),
        const SizedBox(height: 22),
        const PreviewField(label: 'القراءة', value: '37.4', ltr: true),
        const SizedBox(height: 13),
        const PreviewField(label: 'ملاحظة عامة', multiline: true),
        const SizedBox(height: 14),
        const PreviewSafetyNote(
          warning: true,
          text:
              'في حال وجود أعراض مقلقة أو ارتفاع مستمر، تواصلي مع الطبيب أو الجهة الصحية المناسبة.',
        ),
        const SizedBox(height: 18),
        const NumuwClassyButton(label: 'حفظ القراءة', onPressed: previewNoop),
      ],
    ),
  );
}

class PreviewNoteScreen extends StatelessWidget {
  const PreviewNoteScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    title: 'ملاحظة',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewPageIntro(
          title: 'احفظي التفاصيل الصغيرة',
          subtitle: 'سطران الآن قد يكونان مهمين عندما تتحدثين مع الطبيب لاحقاً.',
          icon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: 22),
        const PreviewField(
          label: 'الملاحظة',
          value: 'نامت بهدوء بعد الرضعة وكانت أكثر نشاطاً بعد الاستيقاظ.',
          multiline: true,
        ),
        const SizedBox(height: 16),
        const NumuwClassyButton(
          label: 'حفظ الملاحظة',
          variant: NumuwButtonVariant.black,
          onPressed: previewNoop,
        ),
      ],
    ),
  );
}
