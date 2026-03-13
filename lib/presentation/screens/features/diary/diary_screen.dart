import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记'),
      ),
      body: const Center(
        child: Text('日记功能'),
      ),
    );
  }
}
