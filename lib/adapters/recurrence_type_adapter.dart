import 'package:hive/hive.dart';
import '../models/time_event.dart';

class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 1;

  @override
  RecurrenceType read(BinaryReader reader) {
    return RecurrenceType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    writer.writeInt(obj.index);
  }
}