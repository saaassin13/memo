import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoEditScreen extends ConsumerWidget {
  const MemoEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑备忘录'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 保存备忘录
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: const Center(
        child: Text('备忘录编辑'),
      ),
    );
  }
}
