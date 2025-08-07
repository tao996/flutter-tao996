import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

/// 一个用于筛选独立名称的 Widget。
/// 用户可以选中或取消选中列表中的每个名称。
class GridCheckbox extends StatefulWidget {
  /// 所有的可选名称列表。
  final List<String> items;

  /// 初始选中的名称列表。
  final List<String>? initItems;

  /// 选中状态改变时调用的回调函数。
  /// 参数是当前所有选中的名称列表。
  final ValueChanged<List<String>> onSelectionChanged;

  /// 可选的列数，用于控制布局。默认为3。
  final int crossAxisCount;

  final double horizontal;

  const GridCheckbox({
    super.key,
    required this.items,
    required this.onSelectionChanged,
    this.initItems,
    this.crossAxisCount = 3,
    this.horizontal = 18,
  });

  @override
  State<GridCheckbox> createState() => _GridCheckboxState();
}

class _GridCheckboxState extends State<GridCheckbox> {
  // 用于存储当前选中的名称集合，使用 Set 保证唯一性且查找效率高
  final Set<String> _selectedNames = {};
  final IDebugService _debugService = getIDebugService();

  @override
  void initState() {
    super.initState();
    // 初始化选中的名称列表
    if (widget.initItems != null) {
      _selectedNames.addAll(widget.initItems!);
    }
    _debugService.d('_selectedNames', args: _selectedNames);
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的 ColorScheme
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      // 使用 GridView 使得名称可以多列布局，更美观
      shrinkWrap: true,
      // 根据内容收缩，避免占用过多空间
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: widget.horizontal),
      // 禁用内部滚动，由父级滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount, // 列数
        crossAxisSpacing: 8.0, // 列间距
        mainAxisSpacing: 8.0, // 行间距
        childAspectRatio: 2.5, // 宽高比，让按钮更宽
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final name = widget.items[index];
        final isSelected = _selectedNames.contains(name);
        _debugService.d(
          'itemBuilder:',
          args: {'name': name, 'isSelected': isSelected},
        );

        return InkWell(
          // 使用 InkWell 提供点击波纹效果
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedNames.remove(name); // 如果已选中，则取消选中
              } else {
                _selectedNames.add(name); // 如果未选中，则选中
              }
            });
            // 调用回调函数，通知父 Widget 选中状态已改变
            widget.onSelectionChanged(_selectedNames.toList());
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // color: isSelected ? Colors.blueAccent : Colors.grey[200],
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              // 选中/未选中颜色
              borderRadius: BorderRadius.circular(8.0),
              // 圆角
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha(
                        125,
                      ), // 未选中边框使用 onSurface 的半透明
                width: isSelected ? 2.0 : 1.0, // 边框粗细
              ),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
