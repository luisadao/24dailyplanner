import 'package:flutter/material.dart';
import '../models/time_event.dart';
import '../theme/app_colors.dart';

class AgendaCard extends StatelessWidget {
  final List<TimeEvent> events;
  final ValueChanged<TimeEvent> onEventTap;

  const AgendaCard({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = events.toList()
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sorted.isEmpty
            ? [
                const Text(
                  'No events yet',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ]
            : sorted.map((event) => _AgendaRow(event: event, onTap: onEventTap)).toList(),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  final TimeEvent event;
  final ValueChanged<TimeEvent> onTap;

  const _AgendaRow({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final start = _formatTime(event.startMinute);
    final end = _formatTime(event.startMinute + event.durationMinutes);

    return GestureDetector(
      onTap: () => onTap(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Color(event.colorValue),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title.isEmpty ? 'Untitled' : event.title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '$start–$end',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                      if (event.recurrenceType != RecurrenceType.none) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.repeat, size: 12, color: AppColors.secondaryText),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int minute) {
    final h = minute ~/ 60;
    final m = minute % 60;
    if (m == 0) return '${h}h';
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
