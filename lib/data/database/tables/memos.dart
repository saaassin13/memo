import 'package:drift/drift.dart';

class Memos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get category => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get remindTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
