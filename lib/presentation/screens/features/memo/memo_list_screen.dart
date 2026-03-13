import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoListScreen extends ConsumerWidget {
  const MemoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备忘录'),
      ),
      body: const Center(
        child: Text('备忘录列表'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 跳转到编辑页面
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
