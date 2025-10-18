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

class MyBodyPadding extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;

  const MyBodyPadding(
    this.child, {
    super.key,
    this.horizontal = 16,
    this.vertical = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child,
    );
  }
}

// 扩展方法
extension WidgetListSpacing on List<Widget> {
  /// 在列表的每个元素之间插入一个间距 widget
  List<Widget> withAppBarActions({double height = 16.0, double width = 16.0}) {
    if (isEmpty) {
      return this;
    }
    final spacedList = <Widget>[SizedBox(width: width, height: height)];
    for (int i = 0; i < length; i++) {
      spacedList.add(this[i]);
      spacedList.add(SizedBox(width: width, height: height));
    }
    return spacedList;
  }

  List<Widget> withRowWidth() {
    if (isEmpty) {
      return this;
    }
    final spacedList = <Widget>[const SizedBox(width: 10)];
    for (int i = 0; i < length; i++) {
      spacedList.add(this[i]);
      spacedList.add(const SizedBox(width: 10));
    }
    return spacedList;
  }

  List<Widget> withColumnHeight() {
    if (isEmpty) {
      return this;
    }
    final spacedList = <Widget>[const SizedBox(height: 16)];
    for (int i = 0; i < length; i++) {
      spacedList.add(this[i]);
      spacedList.add(const SizedBox(height: 16));
    }
    return spacedList;
  }
}

/// 将一个子元素（如按钮）放在一个块级容器中，让其占满父容器的宽度
class MyBlockWidget extends StatelessWidget {
  final Widget child;

  const MyBlockWidget(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 强制宽度为父容器的最大宽度
      width: double.infinity,
      child: child,
    );
  }
}
