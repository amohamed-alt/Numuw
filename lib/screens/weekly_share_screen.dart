import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_colors.dart';
import '../models/weekly_child_summary.dart';
import '../services/weekly_summary_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';

class WeeklyShareScreen extends StatefulWidget {
  const WeeklyShareScreen({super.key, this.service});

  final WeeklySummaryService? service;

  @override
  State<WeeklyShareScreen> createState() => _WeeklyShareScreenState();
}

class _WeeklyShareScreenState extends State<WeeklyShareScreen> {
  final _cardKey = GlobalKey();
  late final WeeklySummaryService _service =
      widget.service ?? WeeklySummaryService();
  Future<WeeklyChildSummary>? _future;
  bool _sharing = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    _future = _service.buildForChild(child);
  }

  Future<void> _share() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || _sharing) return;
    setState(() {
      _sharing = true;
      _message = null;
    });
    try {
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) throw StateError('empty image');
      final file = await _writeTempImage(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: 'image/png', name: 'numuw-weekly.png'),
          ],
          text: 'ÙƒØ§Ø±Øª Ø£Ø³Ø¨ÙˆØ¹ Ø§Ù„Ø·ÙÙ„ Ù…Ù† Ù†ÙÙ…ÙÙˆÙ‘',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _message =
            'ØªØ¹Ø°Ø± Ù…Ø´Ø§Ø±ÙƒØ© Ø§Ù„ÙƒØ§Ø±Øª. Ø­Ø§ÙˆÙ„ÙŠ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<File> _writeTempImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}${Platform.pathSeparator}numuw-weekly-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    return file.writeAsBytes(bytes, flush: true);
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumuwAppBar(
              title: 'ÙƒØ§Ø±Øª Ø§Ù„Ø£Ø³Ø¨ÙˆØ¹',
              subtitle:
                  'Ù…Ù„Ø®Øµ Ø¨Ø³ÙŠØ· Ù‚Ø§Ø¨Ù„ Ù„Ù„Ù…Ø´Ø§Ø±ÙƒØ© Ù…Ù† Ø³Ø¬Ù„Ø§Øª Ø·ÙÙ„Ùƒ',
              leading: AppIconButton(
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.pop(context),
                badge: false,
                size: 42,
                radius: 13,
                iconSize: 20,
                borderWidth: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            const NumuwPlantProgress(
              progress: .58,
              label: 'Ù…Ù„Ø®Øµ Ø¬Ø§Ù‡Ø² Ù„Ù„Ù…Ø´Ø§Ø±ÙƒØ©',
            ),
            const SizedBox(height: 18),
            if (child == null)
              const NumuwEmptyState(
                message:
                    'Ø§Ø®ØªØ§Ø±ÙŠ Ø·ÙÙ„Ù‹Ø§ Ø£ÙˆÙ„Ù‹Ø§ Ù„Ø¹Ø±Ø¶ Ø§Ù„ÙƒØ§Ø±Øª.',
              )
            else
              FutureBuilder<WeeklyChildSummary>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const NumuwLoadingState(height: 280);
                  }
                  if (snapshot.hasError) {
                    return NumuwErrorState(
                      message:
                          'ØªØ¹Ø°Ø± ØªØ­Ù…ÙŠÙ„ Ù…Ù„Ø®Øµ Ø§Ù„Ø£Ø³Ø¨ÙˆØ¹. Ø­Ø§ÙˆÙ„ÙŠ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
                    );
                  }
                  final summary = snapshot.data;
                  if (summary == null) {
                    return const NumuwEmptyState(
                      message:
                          'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨ÙŠØ§Ù†Ø§Øª ÙƒØ§ÙÙŠØ© Ù„Ø¹Ø±Ø¶ Ø§Ù„ÙƒØ§Ø±Øª Ø¨Ø¹Ø¯.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RepaintBoundary(
                        key: _cardKey,
                        child: WeeklyShareCard(summary: summary),
                      ),
                      const SizedBox(height: 16),
                      NumuwPrimaryButton(
                        label: _sharing
                            ? 'Ø¬Ø§Ø±ÙŠ Ø§Ù„Ù…Ø´Ø§Ø±ÙƒØ©...'
                            : 'Ù…Ø´Ø§Ø±ÙƒØ©',
                        loading: _sharing,
                        onPressed: _sharing ? null : _share,
                      ),
                    ],
                  );
                },
              ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              NumuwErrorState(message: _message!),
            ],
          ],
        ),
      ),
    );
  }
}

class WeeklyShareCard extends StatelessWidget {
  const WeeklyShareCard({super.key, required this.summary});

  final WeeklyChildSummary summary;

  @override
  Widget build(BuildContext context) {
    final night = numuwNightMode();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(20),
        decoration: BoxDecoration(
          gradient: night
              ? AppColors.nightGradient
              : const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Color(0xFFFFF8ED),
                    Color(0xFFE7F4F0),
                    Color(0xFFEAF4FA),
                  ],
                ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: night ? AppColors.nightBorder : Colors.white,
            width: 1.5,
          ),
          boxShadow: night
              ? const []
              : const [
                  BoxShadow(
                    color: Color(0x1A3D9E8C),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: numuwSurfaceColor(),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Ù†ÙÙ…ÙÙˆÙ‘',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ø£Ø³Ø¨ÙˆØ¹ ${summary.childName}',
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        'Ø¢Ø®Ø± 7 Ø£ÙŠØ§Ù… Ù…Ù† Ø³Ø¬Ù„Ø§ØªÙƒ',
                        style: TextStyle(
                          color: numuwSecondaryTextColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                color: numuwSurfaceColor().withValues(alpha: night ? .75 : .88),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.headlineLabel,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    summary.headlineMetric,
                    style: TextStyle(
                      color: numuwAccentColor(),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Ø§Ù„Ù†ÙˆÙ…',
                    value: '${_trim(summary.current.sleepHours)} Ø³',
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniMetric(
                    label: 'Ø§Ù„Ø±Ø¶Ø¹Ø§Øª',
                    value: '${summary.current.feedingCount}',
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniMetric(
                    label: 'Ø§Ù„Ø´ÙØ·',
                    value: '${summary.current.pumpingMl.round()} Ù…Ù„',
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _TrendLine(comparison: summary.sleepComparison),
            const SizedBox(height: 7),
            _TrendLine(comparison: summary.feedingComparison),
            const SizedBox(height: 7),
            _TrendLine(comparison: summary.pumpingComparison),
            const SizedBox(height: 14),
            Text(
              'Ù‡Ø°Ù‡ Ù…Ù‚Ø§Ø±Ù†Ø© Ù„Ù„Ø³Ø¬Ù„Ø§Øª ÙÙ‚Ø· ÙˆÙ„ÙŠØ³Øª ØªÙ‚ÙŠÙŠÙ…Ù‹Ø§ Ø·Ø¨ÙŠÙ‹Ø§.',
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _trim(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: numuwNightMode() ? .18 : .12),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _TrendLine extends StatelessWidget {
  const _TrendLine({required this.comparison});

  final WeeklyMetricComparison comparison;

  @override
  Widget build(BuildContext context) {
    final color = switch (comparison.trend) {
      WeeklyComparisonTrend.increased => AppColors.mint,
      WeeklyComparisonTrend.decreased => AppColors.yellow,
      WeeklyComparisonTrend.stable => AppColors.blue,
      WeeklyComparisonTrend.insufficientData => numuwSecondaryTextColor(),
    };
    final icon = switch (comparison.trend) {
      WeeklyComparisonTrend.increased => Icons.trending_up_rounded,
      WeeklyComparisonTrend.decreased => Icons.trending_down_rounded,
      WeeklyComparisonTrend.stable => Icons.drag_handle_rounded,
      WeeklyComparisonTrend.insufficientData => Icons.info_outline_rounded,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            comparison.message,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
