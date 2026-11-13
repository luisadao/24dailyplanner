import 'package:hive/hive.dart';
import '../adapters/recurrence_type_adapter.dart';
import '../adapters/time_event_adapter.dart';
import '../extensions/recurrence_evaluator.dart';
import '../models/time_event.dart';

class CalendarRepository {
  late Box<TimeEvent> _eventBox;

  Future<void> initialize() async {
    Hive.registerAdapter(TimeEventAdapter());
    Hive.registerAdapter(RecurrenceTypeAdapter());
    _eventBox = await Hive.openBox<TimeEvent>('events_v1');
  }

  Future<void> addEvent(TimeEvent event) async {
    await _eventBox.put(event.id, event);
  }

  Future<void> updateEvent(TimeEvent event) async {
    await _eventBox.put(event.id, event);
  }

  Future<List<TimeEvent>> getEventsForDate(DateTime date) async {
    return _eventBox.values.where((event) => event.occursOn(date)).toList();
  }

  Future<void> deleteEvent(String id) async {
    await _eventBox.delete(id);
  }

  Future<void> deleteEventInstance(String id, DateTime date) async {
    final event = _eventBox.get(id);
    if (event == null) return;
    final excluded = [...?event.excludedDates, _formatDate(date)];
    await _eventBox.put(
      id,
      TimeEvent(
        id: event.id,
        title: event.title,
        notes: event.notes,
        date: event.date,
        startMinute: event.startMinute,
        durationMinutes: event.durationMinutes,
        colorValue: event.colorValue,
        recurrenceType: event.recurrenceType,
        recurrenceDays: event.recurrenceDays,
        recurrenceEndDate: event.recurrenceEndDate,
        excludedDates: excluded,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

}