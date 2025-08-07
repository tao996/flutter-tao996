import 'package:flutter/material.dart';

/// 一个用于展示列表的复选框 Widget。
class ListCheckbox extends StatefulWidget {
  /// 待显示的列表。
  final List<String> items;

  /// 初始选中的名称列表。
  final List<String>? initItems;

  /// 当任何复选框的选中状态发生改变时调用的回调函数。
  final ValueChanged<List<String>>? onSelectionChanged;

  const ListCheckbox({
    super.key,
    required this.items,
    this.initItems,
    this.onSelectionChanged,
  });

  @override
  State<ListCheckbox> createState() => _ListCheckboxState();
}

class _ListCheckItem {
  final String title;
  bool selected;

  _ListCheckItem({required this.title, required this.selected});
}

class _ListCheckboxState extends State<ListCheckbox> {
  // 由于 widget.serverFeedUrls 是不可变的，我们需要在 state 中管理一个可变的列表
  // 来追踪选中状态的变化。
  late List<_ListCheckItem> _listWithSelectionState;

  @override
  void initState() {
    super.initState();
    // 使用深拷贝来初始化状态，避免直接修改父级传入的列表
    _listWithSelectionState = widget.items
        .map(
          (title) => _ListCheckItem(
            title: title,
            selected:
                widget.initItems != null && widget.initItems!.contains(title),
          ),
        )
        .toList();
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
          // 复选框的选中状态
          value: item.selected,
          // 复选框的标签，显示 ServerFeedUrl 的 title
          title: Text(item.title),
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
                  .map((item) => item.title)
                  .toList(),
            );
          },
        );
      },
    );
  }
}
