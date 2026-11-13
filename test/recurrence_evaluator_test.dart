import 'package:flutter_test/flutter_test.dart';
import 'package:dailyplanner24h/extensions/recurrence_evaluator.dart';
import 'package:dailyplanner24h/models/time_event.dart';

void main() {
  group('RecurrenceEvaluator', () {
    final baseDate = DateTime(2024, 1, 1); // Monday

    test('one-time event occurs only on its date', () {
      final event = TimeEvent(
        id: '1',
        title: 'Meeting',
        date: baseDate,
        startMinute: 600,
        durationMinutes: 60,
        colorValue: 0xFF0000FF,
        recurrenceType: RecurrenceType.none,
      );
      expect(event.occursOn(baseDate), isTrue);
      expect(event.occursOn(baseDate.add(const Duration(days: 1))), isFalse);
    });

    test('daily event repeats every day', () {
      final event = TimeEvent(
        id: '2',
        title: 'Daily',
        date: baseDate,
        startMinute: 0,
        durationMinutes: 60,
        colorValue: 0xFF00FF00,
        recurrenceType: RecurrenceType.daily,
      );
      expect(event.occursOn(baseDate), isTrue);
      expect(event.occursOn(baseDate.add(const Duration(days: 5))), isTrue);
    });

    test('weekly event respects selected days', () {
      final event = TimeEvent(
        id: '3',
        title: 'Weekly',
        date: baseDate,
        startMinute: 0,
        durationMinutes: 60,
        colorValue: 0xFFFF0000,
        recurrenceType: RecurrenceType.weekly,
        recurrenceDays: [1, 3, 5], // Mon, Wed, Fri
      );
      expect(event.occursOn(baseDate), isTrue); // Monday
      expect(event.occursOn(baseDate.add(const Duration(days: 2))), isTrue); // Wednesday
      expect(event.occursOn(baseDate.add(const Duration(days: 1))), isFalse); // Tuesday
    });

    test('excluded dates are skipped', () {
      final event = TimeEvent(
        id: '4',
        title: 'Daily Except',
        date: baseDate,
        startMinute: 0,
        durationMinutes: 60,
        colorValue: 0xFFFFFF00,
        recurrenceType: RecurrenceType.daily,
        excludedDates: ['2024-01-02'],
      );
      expect(event.occursOn(baseDate.add(const Duration(days: 1))), isFalse);
      expect(event.occursOn(baseDate.add(const Duration(days: 2))), isTrue);
    });
  });
}