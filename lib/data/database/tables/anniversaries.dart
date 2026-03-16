import 'package:drift/drift.dart';

class Anniversaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isLunar => boolean().withDefault(const Constant(false))();
  IntColumn get reminderDays => integer().withDefault(const Constant(0))();
  BoolColumn get repeatYearly => boolean().withDefault(const Constant(true))();
  TextColumn get relationship => text().withDefault(const Constant('其他'))();
  TextColumn get customRelation => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
