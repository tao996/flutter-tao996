import 'dart:math';

import 'package:flutter/material.dart';

class MyPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? vertical;
  final double? horizontal;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? all; // 将 valueAll 改为可选，更符合命名习惯

  const MyPadding({
    super.key,
    required this.child,
    this.padding,
    this.vertical,
    this.horizontal,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.all,
  });

  @override
  Widget build(BuildContext context) {
    // 优先级 1: 如果直接传了 padding，直接使用
    if (padding != null) {
      return Padding(padding: padding!, child: child);
    }

    // 优先级 2: 合成 padding
    // 逻辑：各自方向的特定值 > 对称值 > 全局默认值
    final finalPadding = EdgeInsets.only(
      left: left ?? horizontal ?? all ?? 0,
      right: right ?? horizontal ?? all ?? 0,
      top: top ?? vertical ?? all ?? 0,
      bottom: bottom ?? vertical ?? all ?? 0,
    );

    return Padding(padding: finalPadding, child: child);
  }
}

class MyBodyPadding extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;
  final double top;

  const MyBodyPadding(
    this.child, {
    super.key,
    this.horizontal = 16,
    this.vertical = 0,
    this.top = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: horizontal,
        right: horizontal,
        top: max(vertical, top),
        bottom: vertical,
      ),
      child: child,
    );
  }
}

/// 检查一个 Widget 是否为功能上的“零尺寸占位符”。
///
/// 零尺寸占位符包括：
/// 1. const SizedBox.shrink()
/// 2. SizedBox(width: 0.0, height: 0.0)
/// 3. const Spacer() (如果在 Row/Column 中，Spacer 会尝试占据空间，但作为列表项，其尺寸可能为零)
///    * 注意：Spacer 的行为取决于其周围的 Flex 约束，但我们通常只关注零尺寸的 SizedBox。
///
/// 这里我们只关注最常用的零尺寸占位符：SizedBox 且 width/height 都为 0.0。
bool _isZeroSizedPlaceholder(Widget widget) {
  if (widget is SizedBox) {
    final SizedBox sizedBox = widget;
    // 检查 width 和 height 是否为 0.0
    return (sizedBox.width == 0.0 || sizedBox.width == null) &&
        (sizedBox.height == 0.0 || sizedBox.height == null);
  }
  // 如果未来您想支持其他零尺寸 Widget，可以在这里添加。
  // 例如：if (widget is Offstage && widget.offstage) return true;
  return false;
}

// 扩展方法
extension WidgetListSpacing on List<Widget> {
  /// 在水平列表的非空元素之间插入一个间距
  List<Widget> withRowWidth({
    bool first = true,
    double width = 16.0,
    bool last = true,
  }) {
    // 过滤掉所有零尺寸占位符，得到一个“有效”列表
    final effectiveList = where((w) => !_isZeroSizedPlaceholder(w)).toList();

    if (effectiveList.isEmpty) {
      return const []; // 如果有效列表为空，则返回空列表
    }

    final spacedList = <Widget>[];
    final space = SizedBox(width: width);

    // 1. 处理列表开头的间距 (如果 first=true)
    if (first) {
      spacedList.add(space);
    }

    // 2. 遍历有效列表并插入间隔
    for (int i = 0; i < effectiveList.length; i++) {
      spacedList.add(effectiveList[i]);

      // 如果不是最后一个元素，则添加间隔
      if (i < effectiveList.length - 1) {
        spacedList.add(space);
      }
    }

    // 3. 处理列表结尾的间距 (如果 last=true，则在结尾也加上一个)
    if (last) {
      spacedList.add(space);
    }

    return spacedList;
  }

  /// 在垂直列表的非空元素之间插入一个间距
  List<Widget> withColumnHeight({
    bool first = true,
    double height = 16.0,
    bool last = true,
  }) {
    // 过滤掉所有零尺寸占位符，得到一个“有效”列表
    final effectiveList = where((w) => !_isZeroSizedPlaceholder(w)).toList();

    if (effectiveList.isEmpty) {
      return const []; // 如果有效列表为空，则返回空列表
    }

    final spacedList = <Widget>[];
    final space = SizedBox(height: height);

    // 1. 处理列表开头的间距 (如果 first=true)
    if (first) {
      spacedList.add(space);
    }

    // 2. 遍历有效列表并插入间隔
    for (int i = 0; i < effectiveList.length; i++) {
      spacedList.add(effectiveList[i]);

      // 如果不是最后一个元素，则添加间隔
      if (i < effectiveList.length - 1) {
        spacedList.add(space);
      }
    }

    // 3. 处理列表结尾的间距 (如果 first=true，则在结尾也加上一个)
    if (last) {
      spacedList.add(space);
    }

    return spacedList;
  }
}

extension WidgetMethods on Widget {
  Widget withBodyPadding() {
    return MyBodyPadding(this);
  }

  Widget withForm(GlobalKey<FormState> formKey) {
    return Form(key: formKey, child: this);
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
