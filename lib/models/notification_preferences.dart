class NotificationPreferences {
  const NotificationPreferences({
    required this.userId,
    required this.pushEnabled,
    required this.careReminders,
    required this.vaccinationReminders,
    required this.medicationReminders,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.timezone,
    this.locale,
  });

  final String userId;
  final bool pushEnabled;
  final bool careReminders;
  final bool vaccinationReminders;
  final bool medicationReminders;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String? timezone;
  final String? locale;

  factory NotificationPreferences.defaults(String userId) =>
      NotificationPreferences(
        userId: userId,
        pushEnabled: false,
        careReminders: true,
        vaccinationReminders: true,
        medicationReminders: true,
      );

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        userId: json['user_id'] as String,
        pushEnabled: json['push_enabled'] as bool? ?? false,
        careReminders: json['care_reminders'] as bool? ?? true,
        vaccinationReminders:
            json['vaccination_reminders'] as bool? ?? true,
        medicationReminders: json['medication_reminders'] as bool? ?? true,
        quietHoursStart: json['quiet_hours_start'] as String?,
        quietHoursEnd: json['quiet_hours_end'] as String?,
        timezone: json['timezone'] as String?,
        locale: json['locale'] as String?,
      );

  Map<String, dynamic> toUpsertJson() => {
        'user_id': userId,
        'push_enabled': pushEnabled,
        'care_reminders': careReminders,
        'vaccination_reminders': vaccinationReminders,
        'medication_reminders': medicationReminders,
        'quiet_hours_start': _cleanOptional(quietHoursStart),
        'quiet_hours_end': _cleanOptional(quietHoursEnd),
        'timezone': _cleanOptional(timezone),
        'locale': _cleanOptional(locale),
      };

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? careReminders,
    bool? vaccinationReminders,
    bool? medicationReminders,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? timezone,
    String? locale,
    bool clearQuietHours = false,
  }) =>
      NotificationPreferences(
        userId: userId,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        careReminders: careReminders ?? this.careReminders,
        vaccinationReminders:
            vaccinationReminders ?? this.vaccinationReminders,
        medicationReminders:
            medicationReminders ?? this.medicationReminders,
        quietHoursStart:
            clearQuietHours ? null : quietHoursStart ?? this.quietHoursStart,
        quietHoursEnd:
            clearQuietHours ? null : quietHoursEnd ?? this.quietHoursEnd,
        timezone: timezone ?? this.timezone,
        locale: locale ?? this.locale,
      );

  static String? _cleanOptional(String? value) {
    final cleaned = value?.trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }
}
