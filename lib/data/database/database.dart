import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/memos.dart';
import 'tables/todos.dart';
import 'tables/diaries.dart';
import 'tables/countdowns.dart';
import 'tables/accounts.dart';
import 'tables/goals.dart';
import 'tables/weights.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Memos, Todos, Diaries, Countdowns, Accounts, Goals, Weights])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memo_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
