
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlowChipBar extends StatelessWidget {
  // 注意：不再需要 height 属性，高度由内容决定
  final List<Widget> children;
  final RxInt activeIndex;
  final void Function(int index) onChange;

  // 可以保留一个垂直间距属性
  final double verticalPadding;

  const FlowChipBar ({
    super.key,
    required this.activeIndex,
    required this.onChange,
    required this.children,
    this.verticalPadding = 12.0, // 默认的垂直上下内边距
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      // 外部 Container 仅用于样式和边框，高度由内部 Wrap 决定
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide( // 边框从 top 改为 bottom，更像 TabBar 的标准设计
            color: theme.dividerColor.withAlpha(125),
            width: 0.5,
          ),
        ),
      ),

      // 核心：使用 Padding + Wrap 替代 SingleChildScrollView
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 8.0),

        child: Wrap(
          // 间距控制
          spacing: 8.0, // 子 Widget 之间的水平间距
          runSpacing: 8.0, // 行与行之间的垂直间距 (自动换行时的间距)
          alignment: WrapAlignment.start, // Tab 从左侧开始对齐

          children: List.generate(children.length, (index) {
            // final isSelected = activeIndex.value == index;

            return Obx(() {
              // 确保 Obx 块内的 isSelected 是最新的状态
              final isCurrentActive = activeIndex.value == index;

              return InkWell(
                // InkWell 的点击区域应该被 Material 环绕，我们使用 Chip 风格
                onTap: () {
                  activeIndex.value = index;
                  onChange(index);
                },

                // 使用 Container 来模拟 Tab 的背景和形状 (Chip 风格)
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),

                  decoration: BoxDecoration(
                    color: isCurrentActive
                        ? theme.colorScheme.primary.withAlpha(25) // 选中时浅色背景
                        : theme.dividerColor.withAlpha(25), // 未选中时淡灰色背景
                    borderRadius: BorderRadius.circular(20.0), // 圆角边框，Chip 风格
                    border: Border.all(
                      color: isCurrentActive
                          ? theme.colorScheme.primary // 选中时主色边框
                          : Colors.transparent, // 未选中时无边框
                      width: 1.0,
                    ),
                  ),

                  // Tab 的内容 (您传入的 children)
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: isCurrentActive ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                      fontWeight: isCurrentActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.0,
                    ),
                    child: children[index],
                  ),
                ),
              );
            });
          }),
        ),
      ),
    );
  }
}