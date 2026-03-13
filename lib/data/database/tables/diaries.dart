import 'package:drift/drift.dart';

class Diaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get weather => text().nullable()();
  TextColumn get content => text()();
  TextColumn get images => text().withDefault(const Constant(''))(); // JSON 数组字符串
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
