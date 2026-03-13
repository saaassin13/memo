import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/memo.dart';
import '../providers/repository_providers.dart';

// 编辑中的备忘录
class MemoEditState {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final bool isPinned;
  final DateTime? remindTime;
  final bool isLoading;
  final String? error;

  const MemoEditState({
    this.id,
    this.title = '',
    this.content = '',
    this.category,
    this.isPinned = false,
    this.remindTime,
    this.isLoading = false,
    this.error,
  });

  bool get isEditing => id != null;
  bool get hasChanges => title.isNotEmpty || content.isNotEmpty || category != null || isPinned || remindTime != null;

  MemoEditState copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    DateTime? remindTime,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearRemindTime = false,
  }) {
    return MemoEditState(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: clearCategory ? null : (category ?? this.category),
      isPinned: isPinned ?? this.isPinned,
      remindTime: clearRemindTime ? null : (remindTime ?? this.remindTime),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MemoEditNotifier extends StateNotifier<MemoEditState> {
  final Ref _ref;

  MemoEditNotifier(this._ref) : super(const MemoEditState());

  void initNew() {
    state = const MemoEditState();
  }

  Future<void> loadMemo(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = _ref.read(memoRepositoryProvider);
      final memo = await repository.getById(id);
      if (memo != null) {
        state = MemoEditState(
          id: memo.id,
          title: memo.title,
          content: memo.content,
          category: memo.category,
          isPinned: memo.isPinned,
          remindTime: memo.remindTime,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setCategory(String? category) {
    if (category == state.category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void setPinned(bool pinned) {
    state = state.copyWith(isPinned: pinned);
  }

  Future<void> togglePinned(int memoId) async {
    try {
      final repository = _ref.read(memoRepositoryProvider);
      final memo = await repository.getById(memoId);
      if (memo != null) {
        final updated = memo.copyWith(
          isPinned: !memo.isPinned,
          updatedAt: DateTime.now(),
        );
        await repository.update(updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setRemindTime(DateTime? time) {
    if (time == null) {
      state = state.copyWith(clearRemindTime: true);
    } else {
      state = state.copyWith(remindTime: time);
    }
  }

  Future<bool> save() async {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(error: '标题不能为空');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = _ref.read(memoRepositoryProvider);
      final now = DateTime.now();

      if (state.isEditing) {
        final memo = Memo(
          id: state.id,
          title: state.title.trim(),
          content: state.content.trim(),
          category: state.category,
          isPinned: state.isPinned,
          remindTime: state.remindTime,
          createdAt: now, // 会被忽略
          updatedAt: now,
        );
        await repository.update(memo);
      } else {
        final memo = Memo(
          title: state.title.trim(),
          content: state.content.trim(),
          category: state.category,
          isPinned: state.isPinned,
          remindTime: state.remindTime,
          createdAt: now,
          updatedAt: now,
        );
        await repository.insert(memo);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> delete() async {
    if (!state.isEditing) return false;

    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(memoRepositoryProvider);
      await repository.delete(state.id!);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

final memoEditProvider = StateNotifierProvider<MemoEditNotifier, MemoEditState>((ref) {
  return MemoEditNotifier(ref);
});
