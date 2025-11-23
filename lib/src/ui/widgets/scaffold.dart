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
  final FloatingActionButtonLocation? floatingActionButtonLocation;

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
    this.floatingActionButtonLocation,
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
      floatingActionButtonLocation: floatingActionButtonLocation,
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

class MyAppBarMenuItem {
  final String value;
  final String text;
  final IconData? iconData;
  final Color? color;
  final bool bold;

  const MyAppBarMenuItem({
    required this.value,
    required this.text,
    this.iconData,
    this.color,
    this.bold = false,
  });
}

class MyAppBarMenuButtons extends StatelessWidget {
  final void Function(String) onSelected;
  final List<List<MyAppBarMenuItem>> items;

  const MyAppBarMenuButtons({
    super.key,
    required this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> children = [];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(const PopupMenuDivider(height: 1));
      }
      children.addAll(
        items[i].map((item) {
          final textChild = Text(
            item.text,
            style: TextStyle(
              color: item.color,
              fontWeight: item.bold ? FontWeight.bold : null,
            ),
          );
          return PopupMenuItem(
            value: item.value,
            child: item.iconData == null
                ? textChild
                : Row(
                    children: [
                      Icon(item.iconData!, size: 20, color: item.color),
                      const SizedBox(width: 12),
                      textChild,
                    ],
                  ),
          );
        }),
      );
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => children,
    );
  }
}

/// 当页面没有记录时显示的空状态 Widget。
/// 它遵循应用的极简扁平化主题，并引导用户进行初次操作。
class MyEmptyStateWidget extends StatelessWidget {
  /// 提示用户可以执行的操作（例如：“添加新活动”）。
  final String? buttonText;

  /// 当用户点击按钮时执行的回调函数。
  final VoidCallback? onAction;

  /// 描述当前页面的内容类型（例如：“活动”、“资源”）。
  final String? title;

  final Widget? child;

  final bool showDesc;

  const MyEmptyStateWidget({
    super.key,
    this.title,
    this.buttonText,
    this.onAction,
    this.child,
    this.showDesc = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // final double upwardShift = DeviceService.screenHeight / 5;
    final titleText = title ?? 'record'.tr;

    final childBox = Center(
      child: Padding(
        padding: EdgeInsets.only(left: 32.0, right: 32,),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 确保 Column 占据的空间最小化
          children: <Widget>[
            // 1. 引导图标
            Icon(
              Icons.inbox_outlined, // 使用一个清晰的图标表示“空”
              size: 80.0,
              // 使用辅助色，因为主色通常用于主要操作
              color: colorScheme.secondary.withAlpha(125),
            ),

            const SizedBox(height: 24),

            // 2. 提示文本
            Text(
              'noRecord'.trParams({'title': titleText}),
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),

            // 3. 详细说明
            if (showDesc) ...[
              const SizedBox(height: 8),
              Text(
                'clickToCreateYourFirstRecord'.trParams({'title': titleText}),
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface.withAlpha(150),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 4. 主要操作按钮 (使用主题 Primary Color)
            if (onAction != null) ...[
              const SizedBox(height: 30),
              SizedBox(
                width: 250, // 限定按钮宽度
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(
                    buttonText ??
                        'createNewRecord'.trParams({'title': titleText}),
                  ),
                  style: ElevatedButton.styleFrom(
                    // 🚨 遵循扁平化主题：移除阴影
                    elevation: theme.elevatedButtonTheme.style?.elevation
                        ?.resolve({}),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 适度圆角
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            if (child != null) child!,
          ],
        ),
      ),
    );
    final height = DeviceService.screenHeight / 2;
    return height > 400
        ? SizedBox(height: DeviceService.screenHeight / 2, child: childBox)
        : childBox;
  }
}
