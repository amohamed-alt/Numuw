import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../icons/numuw_icon.dart';
import '../numuw_classy_components.dart';
import '../numuw_motion_widgets.dart';

class NumuwReferenceFeedingPane extends StatelessWidget {
  const NumuwReferenceFeedingPane({
    super.key,
    required this.active,
    required this.timerText,
    required this.side,
    required this.feedingMethods,
    required this.amountController,
    required this.notesController,
    required this.amountMl,
    required this.burped,
    required this.vomited,
    required this.loading,
    required this.onBack,
    required this.onTimerPressed,
    required this.onSideChanged,
    required this.onPrimaryMethodChanged,
    required this.onMethodToggled,
    required this.onAmountChanged,
    required this.onAmountDelta,
    required this.onBurpedChanged,
    required this.onVomitedChanged,
  });

  final bool active;
  final String timerText;
  final String side;
  final Set<String> feedingMethods;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final int amountMl;
  final bool burped;
  final bool vomited;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onTimerPressed;
  final ValueChanged<String> onSideChanged;
  final ValueChanged<String> onPrimaryMethodChanged;
  final ValueChanged<String> onMethodToggled;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<int> onAmountDelta;
  final ValueChanged<bool> onBurpedChanged;
  final ValueChanged<bool> onVomitedChanged;

  bool get _natural => feedingMethods.contains('breast');

  bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  Color _text(BuildContext context) =>
      _dark(context) ? AppColors.nightText : AppColors.text;
  Color _secondary(BuildContext context) => _dark(context)
      ? AppColors.nightSecondaryText
      : AppColors.secondaryText;
  Color _surface(BuildContext context) =>
      _dark(context) ? AppColors.nightSurface : AppColors.surface;
  Color _raised(BuildContext context) => _dark(context)
      ? AppColors.nightSurfaceRaised
      : AppColors.surfaceRaised;
  Color _border(BuildContext context) =>
      _dark(context) ? AppColors.nightBorder : AppColors.border;
  Color _accent(BuildContext context) =>
      _dark(context) ? AppColors.nightPrimaryStrong : AppColors.plum;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: NumuwPressable(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _text(context),
                        size: 21,
                      ),
                    ),
                  ),
                ),
                Text(
                  'تسجيل رضاعة',
                  style: TextStyle(
                    color: _text(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: NumuwIcon(
                    NumuwIcons.history,
                    size: 19,
                    color: _accent(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _FeedingModeTabs(
            natural: _natural,
            onChanged: onPrimaryMethodChanged,
          ),
          const SizedBox(height: 22),
          if (_natural) ...[
            Text(
              'من أي جهة كانت الرضاعة؟',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: _text(context),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SideCard(
                    label: 'اليمين',
                    asset: NumuwIcons.feedingRight,
                    selected: side == 'right',
                    onTap: () => onSideChanged('right'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SideCard(
                    label: 'اليسار',
                    asset: NumuwIcons.feedingLeft,
                    selected: side == 'left',
                    onTap: () => onSideChanged('left'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => onSideChanged('both'),
                child: Text(
                  side == 'both' ? '✓ كلا الجهتين' : 'استخدام كلا الجهتين',
                ),
              ),
            ),
          ] else ...[
            Text(
              'كمية الرضاعة',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: _text(context),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _AmountInput(
              controller: amountController,
              amountMl: amountMl,
              onChanged: onAmountChanged,
              onDelta: onAmountDelta,
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'مدة الرضاعة',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: _text(context),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
              decoration: BoxDecoration(
                color: _surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border(context)),
                boxShadow: _dark(context)
                    ? const []
                    : const [
                        BoxShadow(
                          color: Color(0x0D442A34),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      timerText,
                      style: TextStyle(
                        color: _text(context),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    active ? 'جارية' : 'دقيقة',
                    style: TextStyle(
                      color: _secondary(context),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          NumuwClassyButton(
            label: active ? 'إيقاف وحفظ' : 'بدء الرضاعة',
            onPressed: loading ? null : onTimerPressed,
            loading: loading,
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () => _showDetails(context),
            child: const Text('إضافة ملاحظة أو تفاصيل'),
          ),
        ],
      );

  Future<void> _showDetails(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20,
            8,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تفاصيل إضافية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _text(sheetContext),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'طريقة الرضعة',
                  style: TextStyle(
                    color: _text(sheetContext),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MethodChip(
                      label: 'طبيعية',
                      selected: feedingMethods.contains('breast'),
                      onTap: () => onMethodToggled('breast'),
                    ),
                    _MethodChip(
                      label: 'زجاجة',
                      selected: feedingMethods.contains('bottle'),
                      onTap: () => onMethodToggled('bottle'),
                    ),
                    _MethodChip(
                      label: 'صناعية',
                      selected: feedingMethods.contains('formula'),
                      onTap: () => onMethodToggled('formula'),
                    ),
                    _MethodChip(
                      label: 'مختلطة',
                      selected: feedingMethods.contains('mixed'),
                      onTap: () => onMethodToggled('mixed'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  onChanged: onAmountChanged,
                  decoration: const InputDecoration(
                    labelText: 'كمية الحليب (مل)',
                    hintText: 'مثال: 60',
                  ),
                ),
                const SizedBox(height: 14),
                _ToggleRow(
                  label: 'تجشّأ',
                  value: burped,
                  onChanged: onBurpedChanged,
                ),
                const SizedBox(height: 8),
                _ToggleRow(
                  label: 'استفرغ',
                  value: vomited,
                  onChanged: onVomitedChanged,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات اختيارية',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                NumuwClassyButton(
                  label: 'تم',
                  variant: NumuwButtonVariant.tonal,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FeedingModeTabs extends StatelessWidget {
  const _FeedingModeTabs({required this.natural, required this.onChanged});

  final bool natural;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    final surface = dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final secondary = dark
        ? AppColors.nightSecondaryText
        : AppColors.secondaryText;
    return Container(
      height: 43,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeTab(
              label: 'رضاعة طبيعية',
              selected: natural,
              accent: accent,
              secondary: secondary,
              onTap: () => onChanged('breast'),
            ),
          ),
          Expanded(
            child: _ModeTab(
              label: 'رضاعة صناعية',
              selected: !natural,
              accent: accent,
              secondary: secondary,
              onTap: () => onChanged('formula'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.accent,
    required this.secondary,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color accent;
  final Color secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.nightBackground
                      : Colors.white)
                  : secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final text = dark ? AppColors.nightText : AppColors.text;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    final surface = dark ? AppColors.nightSurface : AppColors.surface;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 128,
        padding: const EdgeInsetsDirectional.fromSTEB(10, 13, 10, 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: !dark && selected
              ? const [
                  BoxShadow(
                    color: Color(0x12442A34),
                    blurRadius: 18,
                    offset: Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumuwIcon(asset, size: 72, color: accent),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({
    required this.controller,
    required this.amountMl,
    required this.onChanged,
    required this.onDelta,
  });
  final TextEditingController controller;
  final int amountMl;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onDelta;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
        padding: const EdgeInsetsDirectional.all(14),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: '60',
                suffixText: 'مل',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AmountButton(label: '−10', onTap: () => onDelta(-10)),
                const SizedBox(width: 8),
                Text(
                  '$amountMl مل',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                _AmountButton(label: '+10', onTap: () => onDelta(10)),
              ],
            ),
          ],
        ),
      );
}

class _AmountButton extends StatelessWidget {
  const _AmountButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.nightPrimarySoft
                : AppColors.roseMist,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.nightPrimaryStrong
                  : AppColors.plum,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (dark ? AppColors.nightPrimarySoft : AppColors.roseMist)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? accent
                : (dark ? AppColors.nightBorder : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? accent
                : (dark
                    ? AppColors.nightSecondaryText
                    : AppColors.secondaryText),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      );
}
