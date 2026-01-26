import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

void dprint(dynamic message, {bool stack = true, bool first = true}) {
  if (kDebugMode) {
    debugPrint(message.toString());
    if (stack) {
      StackUtil.output(
        color: MyColor.yellow,
        filterNames: ['function.dart'],
        first: first,
      );
    }
  }
}

void ddprint(dynamic message, dynamic args) {
  if (kDebugMode) {
    getIDebugService().d(message, args: args);
  }
}

int colorWithOpacity(double opacity) {
  return (255 * opacity).toInt();
}

/// 更新记录列表（不需要 IModel）
/// [items] 原有的列表；[record] 新的记录；[index] 索引；[unshift] 是否在头部添加
/// 如果 [record]==null并且 [index]不为0则表示删除
Future<void> syncListState({
  RxList<dynamic>? items,
  required int index,
  dynamic entity,
  RxInt? total,
  bool unshift = true,
}) async {
  // 分支 1：删除逻辑 (Entity 为空)
  if (entity == null) {
    if (index >= 0 && items != null) {
      items.removeAt(index);
      total?.value--;
    }
    return;
  }

  // 分支 2：更新逻辑 (Index 有效)
  if (index >= 0) {
    items?[index] = entity;
  }
  // 分支 3：新增逻辑 (Index 为负)
  else {
    if (items != null) {
      unshift ? items.insert(0, entity) : items.add(entity);
      total?.value++;
    }
  }
}
