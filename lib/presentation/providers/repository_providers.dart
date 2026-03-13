import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/repositories/memo_repository_impl.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../data/repositories/diary_repository_impl.dart';
import '../../data/repositories/countdown_repository_impl.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../data/repositories/weight_repository_impl.dart';
import '../../domain/repositories/memo_repository.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../domain/repositories/countdown_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/weight_repository.dart';

// 数据库 Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be initialized in main.dart');
});

// Repository Providers
final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  return MemoRepositoryImpl(ref.watch(databaseProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(ref.watch(databaseProvider));
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepositoryImpl(ref.watch(databaseProvider));
});

final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  return CountdownRepositoryImpl(ref.watch(databaseProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(databaseProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(databaseProvider));
});

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepositoryImpl(ref.watch(databaseProvider));
});
