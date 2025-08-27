import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../tao996.dart';

class ColorUtil {
  static const List<String> colors = [
    MyColor.red,
    MyColor.green,
    MyColor.yellow,
    MyColor.blue,
    MyColor.magenta,
    MyColor.cyan,
  ];

  static String random() {
    return colors[Random().nextInt(6)];
  }

  static String success(String content) {
    return '${MyColor.green}$content${MyColor.reset}';
  }

  static String error(String content) {
    return '${MyColor.red}$content${MyColor.reset}';
  }

  // 封装成一个函数方便使用
  static void print(
    Object? data,
    String colorCode, {
    String? bgColorCode,
    bool bold = false,
  }) {
    if (data == null) {
      return;
    }
    String prefix = colorCode;
    if (bgColorCode != null) {
      prefix += bgColorCode;
    }
    if (bold) {
      prefix += MyColor.bold;
    }
    debugPrint('$prefix${data.toString()}${MyColor.reset}');
  }
}
