import 'package:flutter/material.dart';

class MyButtons {
  static Widget chevronLeft(
    BuildContext context, {
    required Function() onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon:const Icon(Icons.chevron_left_outlined),
    );
  }
}
