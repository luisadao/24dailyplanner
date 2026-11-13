class TimeEvent {
  final String id;
  final String title;
  final String? notes;
  final DateTime date;
  final int startMinute;
  final int durationMinutes;
  final int colorValue;
  final int? iconCodePoint;
  final RecurrenceType recurrenceType;
  final List<int>? recurrenceDays;
  final DateTime? recurrenceEndDate;
  final List<String>? excludedDates;

  TimeEvent({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    required this.startMinute,
    required this.durationMinutes,
    required this.colorValue,
    this.iconCodePoint,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceDays,
    this.recurrenceEndDate,
    this.excludedDates,
  });

  TimeEvent copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? date,
    int? startMinute,
    int? durationMinutes,
    int? colorValue,
    int? iconCodePoint,
    RecurrenceType? recurrenceType,
    List<int>? recurrenceDays,
    DateTime? recurrenceEndDate,
    List<String>? excludedDates,
  }) {
    return TimeEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      excludedDates: excludedDates ?? this.excludedDates,
    );
  }
}

enum RecurrenceType {
  none,
  daily,
  weekdays,
  weekly,
  monthly,
}