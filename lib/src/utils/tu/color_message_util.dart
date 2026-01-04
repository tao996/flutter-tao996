import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../tao996.dart';

class ColorMessageUtil {
  const ColorMessageUtil();

  static List<String> commonColors = [
    MyColor.green,
    MyColor.yellow,
    MyColor.blue,
    MyColor.magenta,
    MyColor.cyan,
  ];
  static List<String> colors = [MyColor.red, ...commonColors];

  String random() {
    return colors[Random().nextInt(6)];
  }

  String randomConsoleColor() {
    return commonColors[Random().nextInt(5)];
  }

  String success(String content) {
    return '${MyColor.green}$content${MyColor.reset}';
  }

  String error(String content) {
    return '${MyColor.red}$content${MyColor.reset}';
  }

  // 封装成一个函数方便使用
  void print(
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
