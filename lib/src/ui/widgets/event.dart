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

  static Widget unfocusOnTap(Widget child) {
    // 关键：使用 GestureDetector 包裹整个可点击区域
    return GestureDetector(
      // 捕获屏幕上任何位置的点击事件
      onTap: () {
        // 关键代码：通过 FocusManager 获取当前主要的焦点，并强制解除它。
        // 这会触发键盘隐藏和当前 TextFormField 的失焦。
        FocusManager.instance.primaryFocus?.unfocus();
      },

      // 注意：Behavior.translucent 确保即使在子 Widget 上点击，
      // 也能捕获到点击事件并传递给 onTap。
      behavior: HitTestBehavior.translucent,

      child: child,
    );
  }
  /// 移除焦点
  static void unfocus(){
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
