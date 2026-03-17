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
import 'tables/goal_progress_logs.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Memos, Todos, Diaries, Countdowns, Accounts, Goals, Weights, Anniversaries, GoalProgressLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

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
        if (from < 5) {
          // 添加日记 label 和 mood 字段
          await m.addColumn(diaries, diaries.label);
          await m.addColumn(diaries, diaries.mood);
        }
        if (from < 6) {
          // 添加体重新字段
          await m.addColumn(weights, weights.bodyFat);
          await m.addColumn(weights, weights.exercised);
          await m.addColumn(weights, weights.exerciseType);
          await m.addColumn(weights, weights.exerciseDuration);
          await m.addColumn(weights, weights.notes);
        }
        if (from < 7) {
          // 创建目标进度记录表
          await m.createTable(goalProgressLogs);
        }
        if (from < 8) {
          // 添加目标进度类型字段
          await m.addColumn(goals, goals.progressType);
        }
        if (from < 9) {
          // 添加目标备注字段
          await m.addColumn(goals, goals.notes);
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
