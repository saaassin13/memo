import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/database.dart';
import 'presentation/providers/repository_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MemoApp(),
    ),
  );
}
