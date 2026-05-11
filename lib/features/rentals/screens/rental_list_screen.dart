import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RentalListScreen extends ConsumerWidget {
  const RentalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rentals")),
      body: const Center(child: Text("Browse rental listings")),
    );
  }
}
