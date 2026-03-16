import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/anniversary.dart';
import 'repository_providers.dart';

// 搜索关键词
final anniversarySearchProvider = StateProvider<String>((ref) => '');

// 纪念日列表流
final anniversariesProvider = StreamProvider<List<Anniversary>>((ref) {
  final repository = ref.watch(anniversaryRepositoryProvider);
  return repository.watchAll();
});

// 过滤后的列表 (搜索 + 按倒计时排序)
final filteredAnniversariesProvider = Provider<AsyncValue<List<Anniversary>>>((ref) {
  final anniversariesAsync = ref.watch(anniversariesProvider);
  final searchQuery = ref.watch(anniversarySearchProvider);

  return anniversariesAsync.whenData((anniversaries) {
    var filtered = anniversaries;

    // 搜索过滤
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((a) => a.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // 按倒计时排序 (最近的在前)
    filtered.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    return filtered;
  });
});

// 即将到来的纪念日 (未来7天)
final upcomingAnniversariesProvider = Provider<AsyncValue<List<Anniversary>>>((ref) {
  final anniversariesAsync = ref.watch(anniversariesProvider);
  return anniversariesAsync.whenData((anniversaries) {
    return anniversaries
        .where((a) => a.daysUntil >= 0 && a.daysUntil <= 7)
        .toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  });
});
