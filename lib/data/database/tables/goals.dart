import 'package:drift/drift.dart';

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalSteps => integer().withDefault(const Constant(100))();
  IntColumn get completedSteps => integer().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
