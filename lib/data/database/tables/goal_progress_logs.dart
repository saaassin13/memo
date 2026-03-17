import 'package:drift/drift.dart';

class GoalProgressLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer()();
  IntColumn get stepBefore => integer()();
  IntColumn get stepAfter => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
