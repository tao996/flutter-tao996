import 'package:flutter/material.dart';

class MyPadding extends StatelessWidget {
  final Widget child;

  /// EdgeInsets.? 设置距离
  final EdgeInsetsGeometry? padding;
  final double? vertical;
  final double? horizontal;
  final double valueAll;

  const MyPadding({
    super.key,
    required this.child,
    this.padding,
    this.vertical,
    this.horizontal,
    this.valueAll = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (padding == null && vertical == null && horizontal == null) {
      return Padding(padding: EdgeInsets.all(valueAll), child: child);
    }
    if (padding != null) {
      return Padding(padding: padding!, child: child);
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: vertical ?? 0,
          horizontal: horizontal ?? 0,
        ),
        child: child,
      );
    }
  }
}
