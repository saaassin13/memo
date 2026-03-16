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
import 'tables/anniversaries.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Memos, Todos, Diaries, Countdowns, Accounts, Goals, Weights, Anniversaries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // 添加 images 字段
          await m.addColumn(memos, memos.images);
        }
        if (from < 3) {
          // 添加 isPinned 字段
          await m.addColumn(todos, todos.isPinned);
        }
        if (from < 4) {
          // 创建纪念日表
          await m.createTable(anniversaries);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memo_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
