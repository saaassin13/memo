import 'package:drift/drift.dart';

class Weights extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get value => real()();
  RealColumn get bodyFat => real().nullable()();
  BoolColumn get exercised => boolean().withDefault(const Constant(false))();
  TextColumn get exerciseType => text().withDefault(const Constant(''))();
  IntColumn get exerciseDuration => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
