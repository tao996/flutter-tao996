import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

/// 一个用于展示列表的复选框 Widget。可以通过 [FormHelper.listCheckbox] 调用
class ListCheckbox<T> extends StatefulWidget {
  /// 待显示的列表。
  final List<KV<T>> items;

  /// 初始选中的名称列表。
  final List<T>? values;

  /// 当任何复选框的选中状态发生改变时调用的回调函数。
  final ValueChanged<List<T>>? onSelectionChanged;
  final bool dense;

  const ListCheckbox({
    super.key,
    required this.items,
    this.values,
    this.onSelectionChanged,
    this.dense = false,
  });

  @override
  State<ListCheckbox> createState() => _ListCheckboxState<T>();
}

class _ListCheckItem<T> {
  final KV<T> item;
  bool selected;

  _ListCheckItem({required this.item, required this.selected});
}

class _ListCheckboxState<T> extends State<ListCheckbox<T>> {
  late List<_ListCheckItem<T>> _listWithSelectionState;

  @override
  void initState() {
    super.initState();
    _initializeList();
  }

  // 辅助函数：统一初始化逻辑
  void _initializeList() {
    _listWithSelectionState = widget.items
        .map(
          (item) => _ListCheckItem<T>(
        item: item,
        selected:
        widget.values != null &&
            widget.values!.contains(item.value),
      ),
    )
        .toList();
  }
  // 2. 核心修正：当父级 Widget 改变时，同步内部 State
  @override
  void didUpdateWidget(covariant ListCheckbox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items ||
        widget.values != oldWidget.values) {
      _initializeList();
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _listWithSelectionState.length,
      itemBuilder: (context, index) {
        final item = _listWithSelectionState[index];

        return CheckboxListTile(
          dense: widget.dense,
          // 复选框的选中状态
          value: item.selected,
          // 复选框的标签，显示 ServerFeedUrl 的 title
          title: Text(item.item.label),
          // 当选中状态改变时调用
          onChanged: (bool? newValue) {
            setState(() {
              // 更新 state 中列表的 selected 属性
              item.selected = newValue ?? false;
            });

            // 调用回调函数，通知父 Widget 列表已更新
            widget.onSelectionChanged?.call(
              _listWithSelectionState
                  .where((item) => item.selected)
                  .map((item) => item.item.value)
                  .toList(),
            );
          },
        );
      },
    );
  }
}
