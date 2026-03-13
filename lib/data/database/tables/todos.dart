import 'package:drift/drift.dart';

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('杂项'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
