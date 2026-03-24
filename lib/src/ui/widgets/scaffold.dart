import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

/// 集成 SafeArea
class MyScaffold extends StatelessWidget {
  /// 在 Flutter 中，Scaffold 的 appBar 默认已经处理了顶部的 SafeArea。
  ///
  /// 问题：如果你既有 appBar 又在 body 里套了 SafeArea，某些机型可能会出现“双倍顶距”的情况，或者顶部的阴影显示异常。
  final AppBar? appBar;
  final Widget? drawer;
  final Widget body;
  final Widget? floatingActionButton;

  /// 是否需要开启自动移除焦点，通常用在表单中
  ///
  /// 冲突风险：如果 body 中包含 ListView、Google Maps 或者其他复杂的手势组件，外层的 GestureDetector 可能会干扰内层的滑动判定，导致点击变得不灵敏。
  ///
  /// 重复触发：如果你在 body 里的某个按钮上也写了点击事件，外层的 unfocus 会先触发，有时会导致按钮的 onPressed 在某些特定机型上反馈延迟。
  final bool unfocusOnTap;

  /// [singleChildScrollView] 在滚动方向（垂直）上，不给其子 Widget 任何约束，告诉它“你可以无限高”
  ///
  /// 布局溢出：如果你传入的 body 内部本身包含了一个 Expanded 或 Flexible，当它被套入 SingleChildScrollView 时，高度会变成“无限大”，直接导致 RenderBox was not laid out 报错。
  ///
  /// 滚动条重复：如果 body 内部自带了滚动逻辑（比如 ListView），再套一层 SingleChildScrollView 会导致双层嵌套滚动，造成极其糟糕的卡顿感。
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

  /// [useSafeArea] 默认为 true，表示在构建 Scaffold 时，会自动添加 SafeArea 组件。
  ///
  /// 当你把 SafeArea 放在 Scaffold 的 body 内部时，由于 SafeArea 的原理是添加缩进（Padding），这会导致你的背景色或装饰出现断层。
  ///
  /// 问题：如果你的页面有底色（比如浅灰色），Scaffold 的背景色会填满屏幕，但 SafeArea 内部的内容会被限制在刘海屏/底部操作条之外。
  ///
  /// 后果：在真机测试时，你可能会发现状态栏和底部虚拟按键区是一片空白（或背景色），而不是你页面内容的延伸，视觉上不够“沉浸”。
  ///
  /// 建议：只有在页面背景和状态栏颜色不一致时才这么做。如果需要全屏背景，建议在具体的小组件里局部使用 SafeArea。
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
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.drawerEdgeDragWidthPercent,
    this.floatingActionButtonLocation,
    this.useSafeArea = true,
    this.unfocusOnTap = false,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      body: _buildBody(),
      drawerEdgeDragWidth: drawerEdgeDragWidthPercent != null
          ? Get.width * drawerEdgeDragWidthPercent!
          : null,
    );
    return unfocusOnTap ? MyEvents.unfocusOnTap(child) : child;
  }

  Widget _buildBody() {
    Widget content = body;

    // 3. 只有非滚动页面才考虑自动套 SingleChildScrollView
    if (singleChildScrollView) {
      content = SingleChildScrollView(child: content);
    }

    // 4. 建议增加 maintainBottomViewPadding 属性，防止键盘弹出时布局跳动
    return SafeArea(
      top: appBar == null, // 如果有 AppBar，顶部就不需要 SafeArea 了
      child: content,
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

class MyEmptyStateLayout extends StatelessWidget {
  final String titleText;
  final String? descText;
  final String? buttonText;
  final void Function()? onPressed;

  /// [titleText] 模型的名称；[descText] ；[buttonText] 按钮的文本；[onPressed] 按钮的点击事件
  const MyEmptyStateLayout({
    super.key,
    required this.titleText,
    this.descText,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final childBox = Center(
      child: Padding(
        padding: EdgeInsets.only(left: 32.0, right: 32),
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
            if (titleText.isNotEmpty)
              Text(
                titleText,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withAlpha(200),
                ),
                textAlign: TextAlign.center,
              ),

            // 3. 详细说明
            if (descText != null && descText!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                descText!,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface.withAlpha(150),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 4. 主要操作按钮 (使用主题 Primary Color)
            if (onPressed != null) ...[
              const SizedBox(height: 30),
              SizedBox(
                width: 250, // 限定按钮宽度
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.add),
                  label: Text(
                    buttonText ??
                        'createNewRecord'.trParams({'title': 'record'.tr}),
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
          ],
        ),
      ),
    );
    final height = MyDeviceService.screenHeight / 2;
    return height > 400
        ? SizedBox(height: MyDeviceService.screenHeight / 2, child: childBox)
        : childBox;
  }
}

/// 当页面没有记录时显示的空状态 Widget。
/// 它遵循应用的极简扁平化主题，并引导用户进行初次操作。
///
/// [showDesc] 是否显示描述：点击下方按钮，创建你的第一个 [title]
///
/// [onAction] 回调函数，如果不为 null，则会显示一个用于创建记录的按钮；你可以通过 [buttonText] 来自定义按钮的文字
///
/// [child] 追加的自定义组件
class MyEmptyStateWidget extends StatelessWidget {
  /// 提示用户可以执行的操作（例如：“添加新活动”）。

  /// 当用户点击按钮时执行的回调函数。
  final VoidCallback? onPressed;

  /// 描述当前页面的内容类型（例如：“活动”、“资源”）。
  final String? titleText;

  const MyEmptyStateWidget({super.key, this.titleText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = 'noRecord'.trParams({'title': titleText ?? 'record'.tr});
    final dt = 'clickToCreateYourFirstRecord'.trParams({
      'title': titleText ?? 'record'.tr,
    });
    return MyEmptyStateLayout(
      titleText: t,
      descText: onPressed == null ? null : dt,
      onPressed: onPressed,
    );
  }
}
