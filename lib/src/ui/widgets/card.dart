import 'package:flutter/material.dart';

// margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
Widget myCard(Widget child, {bool fullWidth = true}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: fullWidth
          ? SizedBox(
              width: double.infinity, // 强制宽度撑满
              child: child,
            )
          : child,
    ),
  );
}
