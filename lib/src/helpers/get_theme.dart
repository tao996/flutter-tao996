import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 确保在 GetX 环境中安全获取当前的 BuildContext
BuildContext? getThemeContext() {
  // 使用 Get.context 获取当前激活的 BuildContext
  return Get.context;
}

ThemeData getTheme({BuildContext? context}) {
  context ??= getThemeContext();
  if (context == null) {
    return ThemeData.light();
  }
  return Theme.of(Get.context!);
}

// 获取当前主题的 ColorScheme
ColorScheme getColorScheme({BuildContext? context}) {
  context ??= getThemeContext();
  // 如果 context 不可用，返回一个默认的 ColorScheme 防止崩溃
  if (context == null) {
    return const ColorScheme.light();
  }
  return Theme.of(context).colorScheme;
}

TextTheme getTextTheme({BuildContext? context}) {
  context ??= getThemeContext();
  if (context == null) {
    return const TextTheme();
  }
  return Theme.of(context).textTheme;
}
