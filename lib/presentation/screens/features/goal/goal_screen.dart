import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目标'),
      ),
      body: const Center(
        child: Text('目标功能'),
      ),
    );
  }
}
