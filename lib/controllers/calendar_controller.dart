import 'package:flutter/foundation.dart';
import '../models/time_event.dart';
import '../repositories/calendar_repository.dart';

class CalendarController extends ChangeNotifier {
  final CalendarRepository _repository;
  DateTime _selectedDate = DateTime.now();
  List<TimeEvent> _events = [];

  CalendarController(this._repository);

  DateTime get selectedDate => _selectedDate;
  List<TimeEvent> get events => _events;

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    _events = await _repository.getEventsForDate(_selectedDate);
    notifyListeners();
  }

  Future<void> saveEvent(TimeEvent event) async {
    await _repository.updateEvent(event);
    await _loadEvents();
  }

  Future<void> deleteEventInstance(String id, DateTime date) async {
    await _repository.deleteEventInstance(id, date);
    await _loadEvents();
  }

  Future<void> deleteEventSeries(String id) async {
    await _repository.deleteEvent(id);
    await _loadEvents();
  }

  Future<void> moveEventEdge(String id, int newStartMinute, int newDurationMinutes) async {
    final event = _events.firstWhere((e) => e.id == id);
    await _repository.updateEvent(event.copyWith(
      startMinute: newStartMinute,
      durationMinutes: newDurationMinutes,
    ));
    await _loadEvents();
  }
}