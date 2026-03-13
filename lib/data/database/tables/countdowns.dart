import 'package:drift/drift.dart';

class Countdowns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get category => text().nullable()();
  BoolColumn get isRepeat => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
