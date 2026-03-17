import 'package:drift/drift.dart';

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().withDefault(const Constant(''))(); // 备注
  IntColumn get progressType => integer().withDefault(const Constant(0))(); // 0=percent, 1=count, 2=days
  IntColumn get totalSteps => integer().withDefault(const Constant(100))();
  IntColumn get completedSteps => integer().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
