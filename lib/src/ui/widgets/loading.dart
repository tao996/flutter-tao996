import 'package:flutter/material.dart';

class MyLoading extends StatelessWidget {
  const MyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
