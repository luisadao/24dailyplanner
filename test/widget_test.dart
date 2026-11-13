import 'package:flutter_test/flutter_test.dart';
import 'package:dailyplanner24h/models/time_event.dart';

void main() {
  test('TimeEvent model holds values', () {
    final event = TimeEvent(
      id: '1',
      title: 'Test',
      date: DateTime(2024, 1, 1),
      startMinute: 600,
      durationMinutes: 60,
      colorValue: 0xFF0000FF,
    );
    expect(event.title, 'Test');
    expect(event.startMinute, 600);
  });
}