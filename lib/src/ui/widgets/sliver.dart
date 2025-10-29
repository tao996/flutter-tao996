import 'package:flutter/material.dart';

class MySliver {
  static Widget body(List<Widget> children) {
    return CustomScrollView(slivers: children);
  }

  /// 少量/静态内容，用于普通的 Widget
  /// 适用于放置报表头、筛选条件、已知高度的图片或描述文本等不方便用 `SliverList` 懒加载的内容。
  static Widget widget(Widget child) {
    return SliverToBoxAdapter(child: child);
  }

  /// 适用于放置您的大量分组数据记录，实现性能最优的懒加载和滚动。
  static Widget list(
    Widget? Function(BuildContext, int) itemBuilder, {
    int? itemCount,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
    );
  }
}
