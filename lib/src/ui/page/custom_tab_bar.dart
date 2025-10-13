import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCustomTabBar extends StatefulWidget {
  final double height;
  final List<Widget> children;
  final RxInt activeIndex;
  final void Function(int index) onChange;

  const MyCustomTabBar({
    super.key,
    this.height = 50,
    required this.activeIndex,
    required this.onChange,
    required this.children,
  });

  @override
  State<MyCustomTabBar> createState() => _MyCustomTabBarState();
}

class _MyCustomTabBarState extends State<MyCustomTabBar> {
  final ScrollController _scrollController = ScrollController();

  // 使用 List<GlobalKey> 来精确追踪每个 Tab 的位置
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    // 根据 Tab 数量创建 GlobalKey 列表
    _keys = List.generate(widget.children.length, (_) => GlobalKey());
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
    final RenderBox? targetBox =
        _keys[index].currentContext?.findRenderObject() as RenderBox?;
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
                        key: _keys[index],
                        onTap: () {
                          widget.activeIndex.value = index;
                          widget.onChange(index);
                          // 确保在状态更新后执行滚动
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToIndex(index);
                          });
                        },
                        // 使用 Container/SizedBox 确保 InkWell 填充所需的点击区域
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 8.0,
                          ),
                          child: Obx(
                            () => DefaultTextStyle(
                              // 优化：给 Tab 的内容文本添加选中状态样式
                              style: TextStyle(
                                color: widget.activeIndex.value == index
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyLarge?.color
                                          ?.withAlpha(180),
                                fontWeight: widget.activeIndex.value == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              child: widget.children[index],
                            ),
                          ),
                        ),
                      ),

                      // 指示器：宽度应与内容宽度相关，这里使用 fixed 宽度
                      Obx(
                        () => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,

                          // 宽度可以稍微大一些，或者尝试使用 key: index 来优化动画
                          width: widget.activeIndex.value == index ? 24.0 : 0.0,
                          height: 3.0,
                          margin: const EdgeInsets.only(top: 2.0),

                          // 保持与内容的间距
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1.5),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
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
}
