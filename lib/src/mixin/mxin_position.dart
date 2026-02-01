import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tao996/tao996.dart';

mixin MixinPositionCache {
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
