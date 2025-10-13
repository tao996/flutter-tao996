import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 适用于内容可能超出屏幕范围但不需要复杂的滑动效果（例如视差滚动）的页面。
class MyScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  /// [singleChildScrollView] 在滚动方向（垂直）上，不给其子 Widget 任何约束，告诉它“你可以无限高”（即 child 继承了无限高的属性）
  /// 常用错误: `SingleChildScrollView>Column>Expanded|Flexible|ListView`
  ///
  /// ```
  /// // 改正
  /// SingleChildScrollView(
  ///   child: Column(
  ///     children: [
  ///       const Text('头部内容'),
  ///       ListView(
  ///         shrinkWrap: true, // <-- 关键：让 ListView 高度适应内容
  ///         physics: const NeverScrollableScrollPhysics(), // <-- 推荐：禁用内嵌 ListView 自身的滚动
  ///         itemCount: 10,
  ///         itemBuilder: (context, index) => Text('Item $index'),
  ///       ),],),)
  /// SingleChildScrollView(
  ///   child: Column(
  ///     mainAxisSize: MainAxisSize.min, // 确保 Column 高度最小化
  ///     children: [
  ///       const Text('其它内容')
  ///     ],),)
  /// ```
  final bool singleChildScrollView;

  /// 集成 SafeArea
  const MyScaffold({
    super.key,
    required this.singleChildScrollView,
    this.appBar,
    this.floatingActionButton,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return MyScaffold2(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      singleChildScrollView: singleChildScrollView,
      body: body,
    );
  }
}

class MyScaffold2 extends StatelessWidget {
  final AppBar? appBar;
  final Widget? drawer;
  final Widget body;
  final Widget? floatingActionButton;
  final bool singleChildScrollView;
  final bool useSafeArea;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;

  final double? drawerEdgeDragWidthPercent;

  /// 集成 SafeArea
  ///
  /// [drawerEdgeDragWidthPercent] 定义一个宽度区域，在这个区域内水平拖动（滑动）手势可以触发打开 drawer (侧边栏)。可以指定为 0.3
  const MyScaffold2({
    super.key,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
    this.singleChildScrollView = true,
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

class MyScaffold3Body extends StatelessWidget {
  final Widget? top;
  final Widget center;
  final Widget? bottom;

  /// 上下固定，中间为可滚动区域
  const MyScaffold3Body({
    super.key,
    this.top,
    required this.center,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 上部固定区域
        if (top != null) top!,

        // 中部滚动区域
        Expanded(child: SingleChildScrollView(child: center)),

        // 下部固定区域
        if (bottom != null) bottom!,
      ],
    );
  }
}

/// 实现更高级的滑动效果，特别是自定义的、可折叠的 AppBar
class MySliverScaffold extends StatelessWidget {
  /// SliverAppBar 与普通的 AppBar 不同，它可以根据用户的滑动行为进行展开、折叠、固定等动画效果，从而实现更丰富的交互体验。
  final SliverAppBar appBar;
  final List<Widget> children;

  const MySliverScaffold({
    super.key,
    required this.appBar,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold2(appBar: appBar, slivers: children);
  }
}

/// 更加自定义化的 SliverScaffold
class MySliverScaffold2 extends StatelessWidget {
  final SliverAppBar appBar;
  final List<Widget> slivers;
  final FloatingActionButton? floatingActionButton;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;

  const MySliverScaffold2({
    super.key,
    required this.appBar,
    required this.slivers,
    this.floatingActionButton,
    this.physics = const BouncingScrollPhysics(),
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: physics,
          scrollDirection: scrollDirection,
          reverse: reverse,
          slivers: [appBar, ...slivers],
        ),
      ),
    );
  }
}
