import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';

class DataBackupService {
  final AppDatabase _db;

  DataBackupService(this._db);

  /// 导出数据为 JSON 文件，返回文件路径
  Future<String> exportData() async {
    // 调试时使用应用文档目录，通过 Android Studio Device File Explorer 访问
    final exportDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(exportDir.path, 'memo_backup_$timestamp.json');

    final data = <String, dynamic>{
      'version': 1,
      'exportTime': DateTime.now().toIso8601String(),
      'tables': {},
    };

    // 导出备忘录
    final memos = await _db.select(_db.memos).get();
    data['tables']['memos'] = memos.map((r) => {
      'id': r.id,
      'title': r.title,
      'content': r.content,
      'category': r.category,
      'images': r.images,
      'remindTime': r.remindTime?.toIso8601String(),
      'isPinned': r.isPinned,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    }).toList();

    // 导出待办
    final todos = await _db.select(_db.todos).get();
    data['tables']['todos'] = todos.map((r) => {
      'id': r.id,
      'title': r.title,
      'category': r.category,
      'dueDate': r.dueDate?.toIso8601String(),
      'isCompleted': r.isCompleted,
      'isPinned': r.isPinned,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    }).toList();

    // 导出日记
    final diaries = await _db.select(_db.diaries).get();
    data['tables']['diaries'] = diaries.map((r) => {
      'id': r.id,
      'date': r.date.toIso8601String(),
      'weather': r.weather,
      'content': r.content,
      'label': r.label,
      'mood': r.mood,
      'images': r.images,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    }).toList();

    // 导出纪念日
    final anniversaries = await _db.select(_db.anniversaries).get();
    data['tables']['anniversaries'] = anniversaries.map((r) => {
      'id': r.id,
      'title': r.title,
      'date': r.date.toIso8601String(),
      'isLunar': r.isLunar,
      'reminderDays': r.reminderDays,
      'repeatYearly': r.repeatYearly,
      'relationship': r.relationship,
      'customRelation': r.customRelation,
      'phoneNumber': r.phoneNumber,
      'notes': r.notes,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    }).toList();

    // 导出目标
    final goals = await _db.select(_db.goals).get();
    data['tables']['goals'] = goals.map((r) => {
      'id': r.id,
      'name': r.name,
      'notes': r.notes,
      'progressType': r.progressType,
      'totalSteps': r.totalSteps,
      'completedSteps': r.completedSteps,
      'deadline': r.deadline?.toIso8601String(),
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    }).toList();

    // 导出目标进度记录
    final goalLogs = await _db.select(_db.goalProgressLogs).get();
    data['tables']['goalProgressLogs'] = goalLogs.map((r) => {
      'id': r.id,
      'goalId': r.goalId,
      'stepBefore': r.stepBefore,
      'stepAfter': r.stepAfter,
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();

    // 导出体重记录
    final weights = await _db.select(_db.weights).get();
    data['tables']['weights'] = weights.map((r) => {
      'id': r.id,
      'value': r.value,
      'bodyFat': r.bodyFat,
      'exercised': r.exercised,
      'exerciseType': r.exerciseType,
      'exerciseDuration': r.exerciseDuration,
      'notes': r.notes,
      'date': r.date.toIso8601String(),
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();

    // 导出倒计时
    final countdowns = await _db.select(_db.countdowns).get();
    data['tables']['countdowns'] = countdowns.map((r) => {
      'id': r.id,
      'name': r.name,
      'targetDate': r.targetDate.toIso8601String(),
      'category': r.category,
      'isRepeat': r.isRepeat,
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();

    // 导出记账
    final accounts = await _db.select(_db.accounts).get();
    data['tables']['accounts'] = accounts.map((r) => {
      'id': r.id,
      'amount': r.amount,
      'type': r.type,
      'category': r.category,
      'note': r.note,
      'date': r.date.toIso8601String(),
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final file = File(filePath);
    await file.writeAsString(jsonStr, flush: true);

    return filePath;
  }

  /// 导入数据，返回导入的记录数
  Future<ImportResult> importData(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('备份文件不存在');
    }

    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final tables = data['tables'] as Map<String, dynamic>;

    int totalImported = 0;

    await _db.transaction(() async {
      // 导入备忘录
      if (tables.containsKey('memos')) {
        for (final item in (tables['memos'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.memos).insert(MemosCompanion.insert(
            title: map['title'] ?? '',
            content: map['content'] ?? '',
            category: map['category'] ?? '',
            images: Value(map['images'] ?? ''),
            remindTime: Value(map['remindTime'] != null ? DateTime.parse(map['remindTime']) : null),
            isPinned: Value(map['isPinned'] ?? false),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
            updatedAt: Value(map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入待办
      if (tables.containsKey('todos')) {
        for (final item in (tables['todos'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.todos).insert(TodosCompanion.insert(
            title: map['title'] ?? '',
            category: map['category'] ?? '',
            dueDate: Value(map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null),
            isCompleted: Value(map['isCompleted'] ?? false),
            isPinned: Value(map['isPinned'] ?? false),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
            updatedAt: Value(map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入日记
      if (tables.containsKey('diaries')) {
        for (final item in (tables['diaries'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.diaries).insert(DiariesCompanion.insert(
            date: DateTime.parse(map['date']),
            weather: Value(map['weather']),
            content: Value(map['content'] ?? ''),
            label: Value(map['label'] ?? ''),
            mood: Value(map['mood'] ?? ''),
            images: Value(map['images'] ?? ''),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
            updatedAt: Value(map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入纪念日
      if (tables.containsKey('anniversaries')) {
        for (final item in (tables['anniversaries'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.anniversaries).insert(AnniversariesCompanion.insert(
            title: map['title'] ?? '',
            date: DateTime.parse(map['date']),
            isLunar: Value(map['isLunar'] ?? false),
            reminderDays: Value(map['reminderDays'] ?? 0),
            repeatYearly: Value(map['repeatYearly'] ?? true),
            relationship: Value(map['relationship'] ?? '其他'),
            customRelation: Value(map['customRelation']),
            phoneNumber: Value(map['phoneNumber']),
            notes: Value(map['notes']),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
            updatedAt: Value(map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入目标
      if (tables.containsKey('goals')) {
        for (final item in (tables['goals'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.goals).insert(GoalsCompanion.insert(
            name: map['name'] ?? '',
            notes: Value(map['notes'] ?? ''),
            progressType: Value(map['progressType'] ?? 0),
            totalSteps: Value(map['totalSteps'] ?? 100),
            completedSteps: Value(map['completedSteps'] ?? 0),
            deadline: Value(map['deadline'] != null ? DateTime.parse(map['deadline']) : null),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
            updatedAt: Value(map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入目标进度记录
      if (tables.containsKey('goalProgressLogs')) {
        for (final item in (tables['goalProgressLogs'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.goalProgressLogs).insert(GoalProgressLogsCompanion.insert(
            goalId: map['goalId'] ?? 0,
            stepBefore: map['stepBefore'] ?? 0,
            stepAfter: map['stepAfter'] ?? 0,
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入体重记录
      if (tables.containsKey('weights')) {
        for (final item in (tables['weights'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.weights).insert(WeightsCompanion.insert(
            value: (map['value'] as num).toDouble(),
            bodyFat: Value(map['bodyFat'] != null ? (map['bodyFat'] as num).toDouble() : null),
            exercised: Value(map['exercised'] ?? false),
            exerciseType: Value(map['exerciseType'] ?? ''),
            exerciseDuration: Value(map['exerciseDuration'] ?? 0),
            notes: Value(map['notes'] ?? ''),
            date: DateTime.parse(map['date']),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入倒计时
      if (tables.containsKey('countdowns')) {
        for (final item in (tables['countdowns'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.countdowns).insert(CountdownsCompanion.insert(
            name: map['name'] ?? '',
            targetDate: DateTime.parse(map['targetDate']),
            category: Value(map['category']),
            isRepeat: Value(map['isRepeat'] ?? false),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }

      // 导入记账
      if (tables.containsKey('accounts')) {
        for (final item in (tables['accounts'] as List)) {
          final map = item as Map<String, dynamic>;
          await _db.into(_db.accounts).insert(AccountsCompanion.insert(
            amount: (map['amount'] as num).toDouble(),
            type: map['type'] ?? '支出',
            category: map['category'] ?? '',
            note: Value(map['note']),
            date: DateTime.parse(map['date']),
            createdAt: Value(map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
          ));
          totalImported++;
        }
      }
    });

    return ImportResult(
      totalRecords: totalImported,
      importedAt: DateTime.now(),
    );
  }
}

class ImportResult {
  final int totalRecords;
  final DateTime importedAt;

  ImportResult({required this.totalRecords, required this.importedAt});
}
