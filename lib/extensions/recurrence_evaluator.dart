import '../models/time_event.dart';

extension RecurrenceEvaluator on TimeEvent {
  bool occursOn(DateTime date) {
    final normalizedDate = _normalize(date);
    final normalizedStart = _normalize(this.date);

    if (normalizedDate.isBefore(normalizedStart)) return false;
    if (recurrenceEndDate != null && normalizedDate.isAfter(_normalize(recurrenceEndDate!))) {
      return false;
    }

    final dateString = _formatDate(normalizedDate);
    if ((excludedDates ?? []).contains(dateString)) return false;

    switch (recurrenceType) {
      case RecurrenceType.none:
        return normalizedDate == normalizedStart;
      case RecurrenceType.daily:
        return true;
      case RecurrenceType.weekdays:
        return normalizedDate.weekday <= DateTime.friday;
      case RecurrenceType.weekly:
        return (recurrenceDays ?? []).contains(normalizedDate.weekday);
      case RecurrenceType.monthly:
        return normalizedDate.day == normalizedStart.day;
    }
  }

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}