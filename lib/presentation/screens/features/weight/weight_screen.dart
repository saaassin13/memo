import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('体重'),
      ),
      body: const Center(
        child: Text('体重功能'),
      ),
    );
  }
}
