import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 收入/支出
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
