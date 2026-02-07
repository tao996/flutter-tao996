import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyReorder<T> extends StatelessWidget {
  final RxList<T> items;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget? emptyWidget;
  final void Function(int oldIndex, int newIndex)? onReorder;

  MyReorder(
    this.items, {
    required this.itemBuilder,
    this.onReorder,
    this.emptyWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (items.isEmpty) {
        return emptyWidget ?? MyEmptyStateWidget();
      }

      return ReorderableListView.builder(
        shrinkWrap: true, // 根据内容决定自身显示的大小
        physics: const NeverScrollableScrollPhysics(), // 滚动行为：无法滚动
        itemCount: items.length,
        onReorder: onReorder ?? _onReorder, // 当表项目被重新排列时回调函数
        // itemExtent: 30.0, 每个项目的固定高度
        buildDefaultDragHandles: false, // 是否使用默认的拖动手柄

        proxyDecorator: (child, index, animation) {
          // 更改拖动中项目的外观（下面示例半拖动中项目设置为半透明）
          return Material(
            elevation: 6.0,
            color: Colors.transparent,
            shadowColor: Colors.black,
            child: child,
          );
        },
        itemBuilder: itemBuilder,
      );
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
  }
}

/*
buildDefaultDragHandles: false,
itemBuilder: (context, index) {
  return ListTile(
    key: ValueKey(_items[index]),
    title: Text(_items[index]),
    trailing: ReorderableDragStartListener(
      index: index,
      child: Icon(Icons.drag_handle),
    ),
  );
},       
        */
/// 当你将 buildDefaultDragHandles: false 时使用
Widget myReorderDragHandleIcon(int index) {
  return ReorderableDragStartListener(
    index: index,
    child: Icon(Icons.drag_handle),
  );
}
