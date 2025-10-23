// 定义一些常用的颜色常量，方便使用
import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyColor {
  static const String reset = '\x1B[0m'; // 重置/默认
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m'; // 红色
  static const String green = '\x1B[32m'; // 绿色
  static const String yellow = '\x1B[33m'; // 黄色
  static const String blue = '\x1B[34m'; // 蓝色
  static const String magenta = '\x1B[35m'; // 紫色/品红
  static const String cyan = '\x1B[36m'; // 青色
  static const String white = '\x1B[37m';

  // 背景色
  static const String bgBlack = '\x1B[40m';
  static const String bgRed = '\x1B[41m';
  static const String bgGreen = '\x1B[42m';
  static const String bgYellow = '\x1B[43m';
  static const String bgBlue = '\x1B[44m';
  static const String bgMagenta = '\x1B[45m';
  static const String bgCyan = '\x1B[46m';
  static const String bgWhite = '\x1B[47m';

  // 样式
  static const String bold = '\x1B[1m'; // 粗体/高亮
  static const String faint = '\x1B[2m';
  static const String italic = '\x1B[3m'; // 斜体
  static const String underline = '\x1B[4m'; // 下划线

  /// 代表成功的颜色，通常用于表示成功、完成、通过等操作
  static Color success() {
    return getColorScheme().secondary;
  }

  /// 代表失败的颜色，通常用于表示失败、错误、拒绝等操作
  static Color error() {
    return getColorScheme().error;
  }

  /// 背景、表面式，常用于 AlertDialog
  static Color surface() {
    return getColorScheme().surface;
  }

  /// 高亮或信息提示
  static Color info() {
    return getColorScheme().primary;
  }

  /// 文本颜色
  static Color text(double opacity) {
    return getColorScheme().onSurface.withAlpha((255 * opacity).toInt());
  }
}

