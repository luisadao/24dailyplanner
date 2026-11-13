import 'package:flutter/material.dart';
import '../models/time_event.dart';
import '../theme/app_colors.dart';

class EventBottomSheet extends StatefulWidget {
  final DateTime date;
  final TimeEvent? event;

  const EventBottomSheet({super.key, required this.date, this.event});

  @override
  State<EventBottomSheet> createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends State<EventBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late int _startMinute;
  late int _endMinute;
  late int _colorValue;
  late int? _iconCodePoint;
  late RecurrenceType _recurrenceType;
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _notesController = TextEditingController(text: event?.notes ?? '');
    _startMinute = event?.startMinute ?? 480;
    _endMinute = event != null
        ? event.startMinute + event.durationMinutes
        : _startMinute + 30;
    _colorValue = event?.colorValue ?? AppColors.presets.first.toARGB32();
    _iconCodePoint = event?.iconCodePoint;
    _recurrenceType = event?.recurrenceType ?? RecurrenceType.none;
    _selectedDays = event?.recurrenceDays?.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected icon + title header
          GestureDetector(
            onTap: _pickIcon,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(_colorValue).withValues(alpha: 0.2),
                  child: _iconCodePoint != null
                      // ignore: non_const_argument_for_const_parameter
                      ? Icon(IconData(_iconCodePoint!, fontFamily: 'MaterialIcons'), color: Color(_colorValue))
                      : const Icon(Icons.add_photo_alternate_outlined),
                ),
                const SizedBox(height: 8),
                Text(
                  _iconCodePoint != null ? 'Tap to change icon' : 'Tap to add icon',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimeChip(
                label: 'Start',
                minute: _startMinute,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: _startMinute ~/ 60, minute: _startMinute % 60),
                  );
                  if (time != null) {
                    setState(() {
                      final newStart = time.hour * 60 + time.minute;
                      if (newStart >= _endMinute - 15) {
                        _endMinute = newStart + 30;
                      }
                      _startMinute = newStart;
                    });
                  }
                },
              ),
              const Text('→', style: TextStyle(color: AppColors.secondaryText)),
              _TimeChip(
                label: 'End',
                minute: _endMinute,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: _endMinute ~/ 60, minute: _endMinute % 60),
                  );
                  if (time != null) {
                    setState(() {
                      _endMinute = time.hour * 60 + time.minute;
                      if (_endMinute < _startMinute + 15) {
                        _endMinute = _startMinute + 15;
                      }
                    });
                  }
                },
              ),
            ],
          ),
          Wrap(
            spacing: 8.0,
            alignment: WrapAlignment.center,
            children: AppColors.presets.map((color) {
              final selected = _colorValue == color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _colorValue = color.toARGB32()),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: AppColors.primaryText, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          DropdownButton<RecurrenceType>(
            value: _recurrenceType,
            items: RecurrenceType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (value) => setState(() {
              _recurrenceType = value!;
              if (_recurrenceType == RecurrenceType.weekly && _selectedDays.isEmpty) {
                _selectedDays = [widget.date.weekday];
              }
            }),
          ),
          if (_recurrenceType == RecurrenceType.weekly)
            Wrap(
              spacing: 4.0,
              children: List.generate(7, (index) {
                final day = index + 1;
                return FilterChip(
                  label: Text(_weekdayLabel(day)),
                  selected: _selectedDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                );
              }),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final event = TimeEvent(
                    id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    notes: _notesController.text.isEmpty ? null : _notesController.text,
                    date: widget.date,
                    startMinute: _startMinute,
                    durationMinutes: _endMinute - _startMinute,
                    colorValue: _colorValue,
                    iconCodePoint: _iconCodePoint,
                    recurrenceType: _recurrenceType,
                    recurrenceDays: _recurrenceType == RecurrenceType.weekly ? _selectedDays : null,
                  );
                  Navigator.pop(context, event);
                },
                child: const Text('Save'),
              ),
              if (widget.event != null)
                TextButton(
                  onPressed: () => _confirmDelete(),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    if (widget.event!.recurrenceType == RecurrenceType.none) {
      if (mounted) Navigator.pop(context, 'delete_all');
      return;
    }
    final dialogResult = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Delete this event only or all future events?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'delete_instance'),
            child: const Text('This event only'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'delete_all'),
            child: const Text('All future events'),
          ),
        ],
      ),
    );
    if (dialogResult != null && mounted) {
      Navigator.pop(context, dialogResult);
    }
  }

  Future<void> _pickIcon() async {
    const icons = [
      Icons.self_improvement,
      Icons.fitness_center,
      Icons.work,
      Icons.school,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.bedtime,
      Icons.shopping_cart,
      Icons.favorite,
      Icons.music_note,
      Icons.book,
      Icons.code,
    ];
    final picked = await showModalBottomSheet<int?>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: icons.map((icon) {
              return IconButton(
                icon: Icon(icon, size: 32),
                onPressed: () => Navigator.pop(context, icon.codePoint),
              );
            }).toList(),
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() => _iconCodePoint = picked);
    }
  }

  String _weekdayLabel(int day) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[day - 1];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final int minute;
  final VoidCallback onTap;

  const _TimeChip({required this.label, required this.minute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${minute ~/ 60}:${(minute % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}