import 'dart:math';
import 'package:flutter/material.dart';
import '../models/time_event.dart';
import 'event_bottom_sheet.dart';
import 'radial_clock_painter.dart';

class RadialClock extends StatefulWidget {
  final DateTime date;
  final List<TimeEvent> events;
  final TimeOfDay currentTime;
  final bool showCurrentTime;
  final String centerTitle;
  final String centerSubtitle;
  final Function(TimeEvent)? onEventSaved;
  final Function(String, DateTime)? onDeleteInstance;
  final Function(String)? onDeleteSeries;
  final Function(String, int, int)? onEventResized;

  const RadialClock({
    super.key,
    required this.date,
    required this.events,
    required this.currentTime,
    this.showCurrentTime = true,
    required this.centerTitle,
    required this.centerSubtitle,
    this.onEventSaved,
    this.onDeleteInstance,
    this.onDeleteSeries,
    this.onEventResized,
  });

  @override
  State<RadialClock> createState() => _RadialClockState();
}

class _RadialClockState extends State<RadialClock> {
  String? _dragEventId;
  bool _draggingStart = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) => _handleTap(context, details.localPosition),
      onPanStart: (details) => _handleDragStart(details.localPosition),
      onPanUpdate: (details) => _handleDragUpdate(details.localPosition),
      onPanEnd: (_) => setState(() => _dragEventId = null),
      child: CustomPaint(
        size: const Size(400, 400),
        painter: RadialClockPainter(
          events: widget.events,
          currentTime: widget.showCurrentTime ? widget.currentTime : const TimeOfDay(hour: 0, minute: 0),
          showCurrentTime: widget.showCurrentTime,
          centerTitle: widget.centerTitle,
          centerSubtitle: widget.centerSubtitle,
        ),
      ),
    );
  }

  void _handleDragStart(Offset position) {
    final minute = _positionToMinute(position);
    if (minute == null) return;
    final event = _findEventAtAngle(minute);
    if (event == null) return;

    final startDiff = (minute - event.startMinute).abs();
    final endDiff = (minute - (event.startMinute + event.durationMinutes)).abs();
    if (startDiff <= 15 || endDiff <= 15) {
      setState(() {
        _dragEventId = event.id;
        _draggingStart = startDiff <= endDiff;
      });
    }
  }

  void _handleDragUpdate(Offset position) {
    if (_dragEventId == null) return;
    final minute = _positionToMinute(position);
    if (minute == null) return;

    final event = widget.events.firstWhere((e) => e.id == _dragEventId);
    final snappedMinute = (minute ~/ 15) * 15;

    if (_draggingStart) {
      final newDuration = event.startMinute + event.durationMinutes - snappedMinute;
      if (newDuration >= 15) {
        widget.onEventResized?.call(event.id, snappedMinute, newDuration);
      }
    } else {
      final newDuration = snappedMinute - event.startMinute;
      if (newDuration >= 15) {
        widget.onEventResized?.call(event.id, event.startMinute, newDuration);
      }
    }
  }

  int? _positionToMinute(Offset position) {
    const size = Size(400, 400);
    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = size.width / 2;

    if (distance < radius * 0.6 || distance > radius * 1.1) return null;

    var angle = atan2(dy, dx);
    angle = angle + pi / 2;
    if (angle < 0) angle += 2 * pi;

    final totalMinutes = ((angle / (2 * pi)) * 1440).round();
    return (totalMinutes ~/ 15) * 15;
  }

  void _handleTap(BuildContext context, Offset position) {
    final snappedMinutes = _positionToMinute(position);
    if (snappedMinutes == null) return;

    final tappedEvent = _findEventAtAngle(snappedMinutes);
    if (tappedEvent != null) {
      _openEditSheet(context, tappedEvent);
    } else {
      _openCreateSheet(context, snappedMinutes);
    }
  }

  TimeEvent? _findEventAtAngle(int minute) {
    for (final event in widget.events) {
      final start = event.startMinute;
      final end = start + event.durationMinutes;
      if (minute >= start && minute <= end) return event;
    }
    return null;
  }

  Future<void> _openCreateSheet(BuildContext context, int startMinute) async {
    final result = await showModalBottomSheet<TimeEvent>(
      context: context,
      builder: (_) => EventBottomSheet(
        date: widget.date,
        event: TimeEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          date: widget.date,
          startMinute: startMinute,
          durationMinutes: 60,
          colorValue: Colors.blue.toARGB32(),
        ),
      ),
    );
    if (result != null) widget.onEventSaved?.call(result);
  }

  Future<void> _openEditSheet(BuildContext context, TimeEvent event) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (_) => EventBottomSheet(date: widget.date, event: event),
    );
    if (result is TimeEvent) {
      widget.onEventSaved?.call(result);
    } else if (result == 'delete_instance') {
      widget.onDeleteInstance?.call(event.id, widget.date);
    } else if (result == 'delete_all') {
      widget.onDeleteSeries?.call(event.id);
    }
  }
}