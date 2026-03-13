import 'package:drift/drift.dart';

class Weights extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get value => real()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
