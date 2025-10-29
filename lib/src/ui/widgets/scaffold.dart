import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

/// 集成 SafeArea
class MyScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget? drawer;
  final Widget body;
  final Widget? floatingActionButton;

  /// [singleChildScrollView] 在滚动方向（垂直）上，不给其子 Widget 任何约束，告诉它“你可以无限高”
  /// （即 child 继承了无限高的属性）默认为 false，表示你可以在 Column 中使用 Expanded；
  ///
  /// 设置为 true 时的常用错误: `SingleChildScrollView>Column>Expanded|Flexible|ListView`
  ///
  /// ```
  /// // 改正
  /// SingleChildScrollView(
  ///   child: ListView(
  ///     shrinkWrap: true, // <-- 关键：让 ListView 高度适应内容
  ///     physics: const NeverScrollableScrollPhysics(), // <-- 推荐：禁用内嵌 ListView 自身的滚动
  ///     ...),)
  /// SingleChildScrollView(
  ///   child: Column(
  ///     mainAxisSize: MainAxisSize.min, // 确保 Column 高度最小化
  ///     ...),)
  /// ```
  final bool singleChildScrollView;
  final bool useSafeArea;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  /// [drawerEdgeDragWidthPercent] 定义一个宽度区域，在这个区域内水平拖动（滑动）手势可以触发打开 drawer (侧边栏)。可以指定为 0.3
  final double? drawerEdgeDragWidthPercent;

  const MyScaffold({
    super.key,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
    this.singleChildScrollView = false,
    this.useSafeArea = true,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.drawerEdgeDragWidthPercent,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = singleChildScrollView
        ? SingleChildScrollView(child: body)
        : body;
    if (useSafeArea) {
      child = SafeArea(child: child);
    }

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      body: child,
      drawerEdgeDragWidth: drawerEdgeDragWidthPercent != null
          ? Get.width * drawerEdgeDragWidthPercent!
          : null,
    );
  }
}

/// 适用于子内容不包含 `Expanded` 的页面
class MyMiniScaffold extends StatelessWidget {
  final AppBar appBar;
  final List<Widget> children;
  final Widget? floatingActionButton;

  const MyMiniScaffold({
    super.key,
    required this.appBar,
    required this.children,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: true,
      appBar: appBar,
      body: MyBodyPadding(MyLayout.miniColumn(children)),
    );
  }
}
