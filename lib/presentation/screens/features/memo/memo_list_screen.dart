import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/memo_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/memo_edit_provider.dart';
import '../../../widgets/memo/category_chips.dart';
import '../../../widgets/memo/memo_card.dart';
import '../../../widgets/memo/empty_memo.dart';

class MemoListScreen extends ConsumerStatefulWidget {
  const MemoListScreen({super.key});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).state = '';
      }
    });
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.vertical_align_top),
              title: const Text('置顶优先'),
              onTap: () {
                ref.read(sortOrderProvider.notifier).state = MemoSortOrder.pinnedFirst;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('最新优先'),
              onTap: () {
                ref.read(sortOrderProvider.notifier).state = MemoSortOrder.latest;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('最早优先'),
              onTap: () {
                ref.read(sortOrderProvider.notifier).state = MemoSortOrder.earliest;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMemoOptions(BuildContext context, int memoId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                context.push('/memo/edit?id=$memoId');
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('置顶'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(memoEditProvider.notifier).togglePinned(memoId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已更新')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: Text('删除', style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(memoId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int memoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除备忘录'),
        content: const Text('确定要删除这条备忘录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repository = ref.read(memoRepositoryProvider);
              await repository.delete(memoId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除')),
                );
              }
            },
            child: Text('删除', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteAsync(int memoId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除备忘录'),
        content: const Text('确定要删除这条备忘录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final memosAsync = ref.watch(filteredMemosProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索备忘录...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              )
            : const Text('备忘录'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showSortMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          const CategoryChips(),
          Expanded(
            child: memosAsync.when(
              data: (memos) {
                if (memos.isEmpty) {
                  return EmptyMemo(
                    onAdd: () => context.push('/memo/edit'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(memosProvider);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      final memo = memos[index];
                      return Dismissible(
                        key: Key('memo_${memo.id}'),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // 编辑
                            context.push('/memo/edit?id=${memo.id}');
                            return false;
                          } else {
                            // 删除
                            return await _confirmDeleteAsync(memo.id!);
                          }
                        },
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            final repository = ref.read(memoRepositoryProvider);
                            await repository.delete(memo.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已删除')),
                              );
                            }
                          }
                        },
                        child: MemoCard(
                          memo: memo,
                          onTap: () => context.push('/memo/edit?id=${memo.id}'),
                          onLongPress: () => _showMemoOptions(context, memo.id!),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('加载失败: $error'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(memosProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            final category = ref.read(selectedCategoryProvider);
            if (category != null) {
              context.push('/memo/edit?category=$category');
            } else {
              context.push('/memo/edit');
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
