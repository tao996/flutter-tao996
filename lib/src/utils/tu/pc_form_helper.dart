import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class PcFormHelperUtil {
  static const double myFormLeftWidth = 120;

  const PcFormHelperUtil();

  /// 左侧控件 + 右侧控件
  Widget leftWidgetRightWidget({
    required Widget right,
    Widget? left,
    double? width,
    EdgeInsetsGeometry? padding,
    bool pZero = false,
  }) {
    return Padding(
      padding: pZero
          ? const EdgeInsets.all(0)
          : (padding ?? const EdgeInsets.symmetric(vertical: 8.0)),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic, // 必须设置 textBaseline
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(
              width: width ?? myFormLeftWidth,
              child: left ?? Container(),
            ),
          ),
          right,
        ],
      ),
    );
  }

  Widget leftNullRightWidget(Widget child, {EdgeInsetsGeometry? padding}) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(top: 8, bottom: 8, left: myFormLeftWidth),
      child: child,
    );
  }

  Widget leftStringRightWidget(
    String label, {
    required Widget child,
    bool isRequired = false,
    double? width,
  }) {
    return leftWidgetRightWidget(
      width: width,
      left: Row(
        // crossAxisAlignment: CrossAxisAlignment.start, // 开启后红点上浮
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: isRequired ? 4.0 : 10),
            child: isRequired
                ? const Icon(Icons.circle, size: 8, color: Colors.red)
                : null,
          ),
          MyText.h4(label),
        ],
      ),
      right: child,
    );
  }

  Widget input(
    String label, {
    required Widget child,
    double? width,
    bool isRequired = false,
  }) {
    return leftStringRightWidget(
      label,
      child: child,
      width: width,
      isRequired: isRequired,
    );
  }
}
