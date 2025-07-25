import 'package:flutter/material.dart';

class MyEvents {
  static Widget inkWell({
    required Widget child,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return Material( // 提供 Material 环境给 InkWell
      color: Colors.transparent, // 防止 Material 产生背景色
      child: InkWell(
        onTap: onTap, // 处理简单的点击事件
        child: child,
      ),
    );
  }
}
