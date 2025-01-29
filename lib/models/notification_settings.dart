class NotificationSettings {
  final bool expiryNotifications;
  final bool lowStockNotifications;
  final bool weeklyReminders;
  final int expiryThresholdDays;
  final Map<String, int> lowStockThresholds; // Product category -> threshold
  final NotificationTime reminderTime;
  final List<int> weeklyReminderDays; // 1 = Monday, 7 = Sunday
  final bool instantAlerts;

  NotificationSettings({
    this.expiryNotifications = true,
    this.lowStockNotifications = true,
    this.weeklyReminders = false,
    this.expiryThresholdDays = 7,
    this.lowStockThresholds = const {},
    this.reminderTime = const NotificationTime(hour: 9, minute: 0),
    this.weeklyReminderDays = const [1], // Monday by default
    this.instantAlerts = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'expiryNotifications': expiryNotifications,
      'lowStockNotifications': lowStockNotifications,
      'weeklyReminders': weeklyReminders,
      'expiryThresholdDays': expiryThresholdDays,
      'lowStockThresholds': lowStockThresholds,
      'reminderTime': reminderTime.toMap(),
      'weeklyReminderDays': weeklyReminderDays,
      'instantAlerts': instantAlerts,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      expiryNotifications: map['expiryNotifications'] ?? true,
      lowStockNotifications: map['lowStockNotifications'] ?? true,
      weeklyReminders: map['weeklyReminders'] ?? false,
      expiryThresholdDays: map['expiryThresholdDays'] ?? 7,
      lowStockThresholds: Map<String, int>.from(map['lowStockThresholds'] ?? {}),
      reminderTime: NotificationTime.fromMap(map['reminderTime'] ?? {'hour': 9, 'minute': 0}),
      weeklyReminderDays: List<int>.from(map['weeklyReminderDays'] ?? [1]),
      instantAlerts: map['instantAlerts'] ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? expiryNotifications,
    bool? lowStockNotifications,
    bool? weeklyReminders,
    int? expiryThresholdDays,
    Map<String, int>? lowStockThresholds,
    NotificationTime? reminderTime,
    List<int>? weeklyReminderDays,
    bool? instantAlerts,
  }) {
    return NotificationSettings(
      expiryNotifications: expiryNotifications ?? this.expiryNotifications,
      lowStockNotifications: lowStockNotifications ?? this.lowStockNotifications,
      weeklyReminders: weeklyReminders ?? this.weeklyReminders,
      expiryThresholdDays: expiryThresholdDays ?? this.expiryThresholdDays,
      lowStockThresholds: lowStockThresholds ?? this.lowStockThresholds,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyReminderDays: weeklyReminderDays ?? this.weeklyReminderDays,
      instantAlerts: instantAlerts ?? this.instantAlerts,
    );
  }
}

class NotificationTime {
  final int hour;
  final int minute;

  const NotificationTime({
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  factory NotificationTime.fromMap(Map<String, dynamic> map) {
    return NotificationTime(
      hour: map['hour'] ?? 9,
      minute: map['minute'] ?? 0,
    );
  }

  String format() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}
