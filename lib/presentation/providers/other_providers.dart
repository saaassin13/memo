import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/countdown.dart';
import '../../domain/entities/weight.dart';
import 'repository_providers.dart';

// 纪念日列表 Provider
final countdownsProvider = StreamProvider<List<Countdown>>((ref) {
  final repository = ref.watch(countdownRepositoryProvider);
  return repository.watchAll();
});

// 体重记录列表 Provider
final weightsProvider = StreamProvider<List<Weight>>((ref) {
  final repository = ref.watch(weightRepositoryProvider);
  return repository.watchAll();
});
