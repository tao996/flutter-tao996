import 'package:flutter/material.dart';

class MyEvents {
  static Widget inkWell({
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap, // 处理简单的点击事件
      onDoubleTap: onLongPress,
      child: child,
    );
  }

  static Widget tooltip({
    required String message,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    required Widget child,
  }) {
    return Tooltip(
      message: message,
      child: InkWell(
        onTap: onTap, // 处理简单的点击事件
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
