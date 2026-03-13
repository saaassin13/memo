import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念日'),
      ),
      body: const Center(
        child: Text('纪念日功能'),
      ),
    );
  }
}
