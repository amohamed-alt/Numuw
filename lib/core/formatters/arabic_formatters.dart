import '../../models/child_profile.dart';

class ArabicFormatters {
  const ArabicFormatters._();

  static String date(DateTime? value) {
    if (value == null) return 'غير محدد';
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  static String time(DateTime? value) {
    if (value == null) return 'غير محدد';
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String duration(Duration duration) {
    if (duration.inMinutes <= 0) return '0 دقيقة';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '$minutes دقيقة';
    if (minutes == 0) return '$hours ساعة';
    return '$hours ساعة و$minutes دقيقة';
  }

  static String age(ChildProfile child, [DateTime? now]) {
    final current = now ?? DateTime.now();
    if (child.stage == 'pregnancy') {
      final due = child.dueDate;
      if (due == null) return 'حمل - موعد الولادة غير محدد';
      final days = due
          .difference(DateTime(current.year, current.month, current.day))
          .inDays;
      if (days > 0) return 'باقي $days يوم على موعد الولادة';
      if (days == 0) return 'موعد الولادة المتوقع اليوم';
      return 'تجاوز موعد الولادة المتوقع بـ${days.abs()} يوم';
    }

    final birth = child.birthDate;
    if (birth == null) return 'العمر غير محدد';
    final start = DateTime(birth.year, birth.month, birth.day);
    final end = DateTime(current.year, current.month, current.day);
    final totalDays = end.difference(start).inDays;
    if (totalDays < 0) return 'تاريخ الميلاد في المستقبل';
    if (totalDays < 7) return '$totalDays يوم';
    if (totalDays < 30) {
      final weeks = totalDays ~/ 7;
      final days = totalDays % 7;
      return days == 0 ? '$weeks أسابيع' : '$weeks أسابيع و$days أيام';
    }
    if (totalDays < 365) {
      final months = totalDays ~/ 30;
      final days = totalDays % 30;
      return days == 0 ? '$months أشهر' : '$months أشهر و$days أيام';
    }
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    return months == 0 ? '$years سنوات' : '$years سنوات و$months أشهر';
  }

  static String gender(String value) => switch (value) {
    'male' => 'ذكر',
    'female' => 'أنثى',
    _ => 'غير محدد',
  };

  static String feedingType(String value) => switch (value) {
    'breast' => 'رضاعة طبيعية',
    'formula' => 'رضاعة صناعية',
    'mixed' => 'رضاعة مختلطة',
    _ => 'غير محدد',
  };

  static String eventType(String value) => switch (value) {
    'feeding' => 'رضاعة',
    'sleep' => 'نوم',
    'diaper' => 'حفاضة',
    'food' => 'طعام',
    'medicine' => 'دواء',
    'temperature' => 'حرارة',
    _ => 'ملاحظة',
  };
}
