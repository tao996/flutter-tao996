import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:tao996/src/utils/fn_util.dart';

mixin MyCustomTabBarController {
  /// ListView.separated(controller) 中滚动位置保存，
  /// 需要自己手动 dispose
  final ScrollController scrollController = ScrollController();
  final cachePosition = <String, double>{};

  void savePosition(String key) {
    if (scrollController.hasClients) {
      cachePosition[key] = scrollController.offset;
    }
  }

  void restorePosition(String key) {
    // 确保控制器连接后再跳转
    final double? position = cachePosition[key];
    if (position == null) return;
    // 如果已连接，直接跳转
    if (scrollController.hasClients) {
      scrollController.jumpTo(cachePosition[key] ?? 0);
    } else {
      dprint('scrollController has not clients');
      // 如果未连接，等待下一帧 Widget 布局完成后再跳转
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(position);
        }
      });
    }
  }
}

class MyCustomTabBarItem {
  final String key;
  final String title;

  MyCustomTabBarItem({required this.key, required this.title});
}

/// 显示样式 [bookMark] 书签样式（滚动）；[flow] 流式样式；[horizontal] 水平样式（滚动）
enum MyCustomTabBarStyle { bookMark, horizontal, flow, flowChip }

class MyCustomTabBar extends StatefulWidget {
  final double height;

  /// 子项：注意，你不能把 RxList 直接传进来，否则会引起 Unhandled Exception: Stack Overflow；应该传 RxList.value
  final List<MyCustomTabBarItem> children;

  /// 当前选中的标签索引
  final RxInt activeIndex;
  final void Function(int index) onChange;
  final MyCustomTabBarStyle tabStyle;

  const MyCustomTabBar({
    super.key,
    this.height = 50,
    this.tabStyle = MyCustomTabBarStyle.horizontal,
    required this.activeIndex,
    required this.onChange,
    required this.children,
  });

  @override
  State<MyCustomTabBar> createState() => _MyCustomTabBarState();
}

class _MyCustomTabBarState extends State<MyCustomTabBar> {
  /// 点击 tab 时确保滚动到合适的位置
  final ScrollController _scrollController = ScrollController();

  // 使用 List<GlobalKey> 来精确追踪每个 Tab 的位置
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    // 监听 activeIndex 变化，外部主动修改时执行滚动
    widget.activeIndex.listen((index) {
      // 优化：使用 SchedulerBinding 替代 WidgetsBinding.instance.addPostFrameCallback
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(index);
      });
    });
  }

  GlobalKey _getKey(MyCustomTabBarItem item) {
    if (!_keys.containsKey(item.key)) {
      _keys[item.key] = GlobalKey();
    }
    return _keys[item.key]!;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // 核心滚动逻辑：使用 GlobalKey 获取精确位置
  // ----------------------------------------------------
  void _scrollToIndex(int index) {
    if (_keys.isEmpty || index >= _keys.length) return;

    // 1. 获取目标 Tab 的 RenderBox
    final item = widget.children[index];
    final RenderBox? targetBox =
        _getKey(item).currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;

    // 2. 获取 SingleChildScrollView 的 RenderBox (即视口)
    final RenderBox? scrollViewBox = context.findRenderObject() as RenderBox?;
    if (scrollViewBox == null) return;

    // 3. 计算 Tab 相对于 ScrollView 的左侧位置 (GlobalToLocal)
    // 目标 Tab 的左边缘相对于 ScrollView 视口左边缘的 X 偏移量
    final Offset position = targetBox.localToGlobal(
      Offset.zero,
      ancestor: scrollViewBox,
    );
    final double itemStartOffset = position.dx;

    // 4. 获取 Tab 的实际宽度
    final double itemWidth = targetBox.size.width;

    // 5. 获取 ScrollView 的视口宽度
    final double viewportWidth = scrollViewBox.size.width;

    // 6. 目标滚动位置计算：将 Tab 的中心对齐到视口的中心
    // 目标 Tab 中心点的 X 坐标
    final double itemCenter = itemStartOffset + (itemWidth / 2.0);

    // 视口中心点的 X 坐标
    final double viewportCenter = viewportWidth / 2.0;

    // 目标滚动位置 (需要滚动的距离)
    final double targetScrollOffset =
        _scrollController.offset + (itemCenter - viewportCenter);

    // 7. 确保目标位置在合法范围内
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double finalOffset = math.min(
      maxScrollExtent,
      math.max(0.0, targetScrollOffset),
    );

    // 8. 执行滚动动画
    _scrollController.animateTo(
      finalOffset,
      duration: const Duration(milliseconds: 300), // 可以尝试 200ms-400ms
      curve: Curves.easeOutCubic, // 使用更流畅的曲线
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tabStyle) {
      case MyCustomTabBarStyle.bookMark:
        return _buildBookMarkStyle(context);
      case MyCustomTabBarStyle.flow:
        return _buildFlowStyle(context);
      case MyCustomTabBarStyle.horizontal:
        return _buildHorizontalStyle(context);
      case MyCustomTabBarStyle.flowChip:
        return _buildFlowChip(context);
    }
  }

  /// 文本的显示
  Widget _child(ThemeData theme, int index) {
    final bool active = widget.activeIndex.value == index;
    return DefaultTextStyle(
      style: TextStyle(
        color: active
            ? theme
                  .colorScheme
                  .primary // 选中状态使用强调色
            : theme.textTheme.bodyLarge?.color,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
      ),
      child: Text(widget.children[index].title),
    );
  }

  // 指示器：宽度应与内容宽度相关，这里使用 fixed 宽度
  Widget _bottomLineAnimated(ThemeData theme, int index) {
    // 2. 底部指示器 (AnimatedContainer)
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,

        // 指示器宽度：固定宽度，使其居中于 Tab
        width: widget.activeIndex.value == index ? 24.0 : 0.0,
        height: 3.0,
        margin: const EdgeInsets.only(top: 2.0),

        // 保持与内容的间距
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.5),
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHorizontalStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withAlpha(125), // 使用主题的分隔线颜色
            width: 0.5, // 调整边框宽度
          ),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        // 外部 Padding 已经包含在 Row 内部的 Padding 中
        padding: EdgeInsets.zero,

        child: Builder(
          // 使用 Builder 获取 Row 的 BuildContext
          builder: (rowContext) {
            return Row(
              // 内部 Row 不需要 mainAxisAlignment.spaceAround，依靠 Padding 即可
              children: List.generate(widget.children.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  // 调整 Tab 之间的间距
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 使用 InkWell 替代 GestureDetector，并利用其填充整个高度
                      InkWell(
                        key: _getKey(widget.children[index]),
                        onTap: () {
                          if (widget.activeIndex.value != index) {
                            widget.activeIndex.value = index;
                            widget.onChange(index);
                            // 确保在状态更新后执行滚动，因为上面 activeIndex.listen 已经监听了，所以这里不需要
                            // WidgetsBinding.instance.addPostFrameCallback((_) {
                            //   _scrollToIndex(index);
                            // });
                          }
                        },
                        // 使用 Container/SizedBox 确保 InkWell 填充所需的点击区域
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 8.0,
                          ),
                          child: Obx(() => _child(theme, index)),
                        ),
                      ),

                      _bottomLineAnimated(theme, index),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookMarkStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // 笔记本背景颜色（可以和 Scaffold 背景色一致，产生连接感）
    final Color notebookBgColor = theme.scaffoldBackgroundColor;
    // 标签页选中颜色
    final Color activeTabColor = notebookBgColor;
    // 标签页未选中颜色（略微深一点或灰色）
    final Color inactiveTabColor = theme.dividerColor.withAlpha(25);

    return Container(
      // 外部 Container 充当笔记本的底色或边框
      height: widget.height,
      width: double.infinity,
      color: theme.dividerColor.withAlpha(25), // 模拟 Tab Bar 的背景底色

      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // 关键：将所有标签页对齐到底部
          children: List.generate(widget.children.length, (index) {
            return Padding(
              // 标签页之间的水平间距
              padding: const EdgeInsets.symmetric(horizontal: 4.0),

              child: InkWell(
                key: _getKey(widget.children[index]),
                onTap: () {
                  // 如果是点击未激活的 Tab，则更新状态并滚动
                  if (widget.activeIndex.value != index) {
                    widget.activeIndex.value = index;
                    widget.onChange(index);
                  }
                },

                // 使用 Obx 来响应 activeIndex 的变化
                child: Obx(() {
                  final bool currentActive = widget.activeIndex.value == index;
                  final double verticalPadding =
                      widget.activeIndex.value == index ? -2 : 4.0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      8 - verticalPadding,
                    ),

                    // 未选中时向下推，以便于对齐 Row 的底部
                    decoration: BoxDecoration(
                      color: currentActive ? activeTabColor : inactiveTabColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0), // 略微圆润
                        topRight: Radius.circular(4.0),
                      ),
                      // 关键：使用 Border.all 来绘制统一的边框，以满足圆角要求
                      border: currentActive
                          ? null // 选中的 Tab 无边框，与内容连接
                          : Border.all(
                              color: theme.dividerColor.withAlpha(10),
                              width: 0.5,
                            ),
                    ),

                    child: _child(theme, index),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFlowStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withAlpha(125),
            width: 0.5,
          ),
        ),
      ),

      child: Padding(
        // Padding 用于控制 Tab Bar 的垂直空间和左右边距
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),

        child: Wrap(
          spacing: 16.0, // 子 Widget 之间的水平间距
          runSpacing: 10.0, // 行与行之间的垂直间距（略微增加，以容纳指示器）
          alignment: WrapAlignment.start,

          children: List.generate(widget.children.length, (index) {
            return Column(
              mainAxisSize: MainAxisSize.min, // 确保 Column 不会占用多余空间
              children: [
                // 1. Tab 点击区域 (使用 InkWell)
                InkWell(
                  onTap: () {
                    if (widget.activeIndex.value != index) {
                      widget.activeIndex.value = index;
                      widget.onChange(index);
                    }
                  },

                  child: Container(
                    // 填充内部 Padding，使点击区域更舒适
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 4.0,
                    ),

                    child: Obx(() => _child(theme, index)),
                  ),
                ),

                // 2. 底部指示器 (AnimatedContainer)
                _bottomLineAnimated(theme, index),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFlowChip(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      // 外部 Container 仅用于样式和边框，高度由内部 Wrap 决定
      decoration: BoxDecoration(
        color:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            // 边框从 top 改为 bottom，更像 TabBar 的标准设计
            color: theme.dividerColor.withAlpha(125),
            width: 0.5,
          ),
        ),
      ),

      // 核心：使用 Padding + Wrap 替代 SingleChildScrollView
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8.0),

        child: Wrap(
          // 间距控制
          spacing: 8.0, // 子 Widget 之间的水平间距
          runSpacing: 8.0, // 行与行之间的垂直间距 (自动换行时的间距)
          alignment: WrapAlignment.start, // Tab 从左侧开始对齐

          children: List.generate(widget.children.length, (index) {
            // final isSelected = activeIndex.value == index;

            return InkWell(
              // InkWell 的点击区域应该被 Material 环绕，我们使用 Chip 风格
              onTap: () {
                if (widget.activeIndex.value != index) {
                  widget.activeIndex.value = index;
                  widget.onChange(index);
                }
              },

              // 使用 Container 来模拟 Tab 的背景和形状 (Chip 风格)
              child: Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),

                  decoration: BoxDecoration(
                    color: widget.activeIndex.value == index
                        ? theme.colorScheme.primary.withAlpha(25) // 选中时浅色背景
                        : theme.dividerColor.withAlpha(25), // 未选中时淡灰色背景
                    borderRadius: BorderRadius.circular(20.0), // 圆角边框，Chip 风格
                    border: Border.all(
                      color: widget.activeIndex.value == index
                          ? theme
                                .colorScheme
                                .primary // 选中时主色边框
                          : Colors.transparent, // 未选中时无边框
                      width: 1.0,
                    ),
                  ),

                  // Tab 的内容 (您传入的 children)
                  child: _child(theme, index),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
