import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/memo.dart';
import '../providers/repository_providers.dart';

// 备忘录列表 Provider
final memosProvider = StreamProvider<List<Memo>>((ref) {
  final repository = ref.watch(memoRepositoryProvider);
  return repository.watchAll();
});

// 分类筛选 Provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 搜索关键词 Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 排序方式 Provider
enum MemoSortOrder { latest, earliest, pinnedFirst }

final sortOrderProvider = StateProvider<MemoSortOrder>((ref) => MemoSortOrder.pinnedFirst);

// 过滤后的备忘录列表
final filteredMemosProvider = Provider<AsyncValue<List<Memo>>>((ref) {
  final memosAsync = ref.watch(memosProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  return memosAsync.whenData((memos) {
    var filtered = memos.toList();

    // 分类筛选
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((m) => m.category == category).toList();
    }

    // 搜索过滤
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((m) =>
        m.title.toLowerCase().contains(lowerQuery) ||
        m.content.toLowerCase().contains(lowerQuery)
      ).toList();
    }

    // 排序
    switch (sortOrder) {
      case MemoSortOrder.latest:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case MemoSortOrder.earliest:
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case MemoSortOrder.pinnedFirst:
        filtered.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }

    return filtered;
  });
});

// 分类列表
final categoriesProvider = Provider<List<String>>((ref) {
  return ['工作', '生活', '学习', '杂项'];
});
