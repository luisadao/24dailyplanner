import 'package:hive/hive.dart';
import '../models/time_event.dart';

class TimeEventAdapter extends TypeAdapter<TimeEvent> {
  @override
  final int typeId = 0;

  @override
  TimeEvent read(BinaryReader reader) {
    return TimeEvent(
      id: reader.readString(),
      title: reader.readString(),
      notes: reader.read(),
      date: DateTime.parse(reader.readString()),
      startMinute: reader.readInt(),
      durationMinutes: reader.readInt(),
      colorValue: reader.readInt(),
      iconCodePoint: reader.read() as int?,
      recurrenceType: RecurrenceType.values[reader.readInt()],
      recurrenceDays: reader.readList().cast<int>(),
      recurrenceEndDate: reader.read() as DateTime?,
      excludedDates: reader.readList().cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TimeEvent obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.write(obj.notes);
    writer.writeString(obj.date.toIso8601String());
    writer.writeInt(obj.startMinute);
    writer.writeInt(obj.durationMinutes);
    writer.writeInt(obj.colorValue);
    writer.write(obj.iconCodePoint);
    writer.writeInt(obj.recurrenceType.index);
    writer.writeList(obj.recurrenceDays ?? []);
    writer.write(obj.recurrenceEndDate);
    writer.writeList(obj.excludedDates ?? []);
  }
}