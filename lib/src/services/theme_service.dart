import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

// import 'dart:io';
abstract class IThemeService {
  ThemeData buildDarkTheme(ColorScheme? dynamicDart);

  ThemeData buildLightTheme(ColorScheme? dynamicLight);

  /// 设置 System UI 样式的方法
  void systemUIOverlayStyle(Color backgroundColor, Brightness brightness);
}

abstract class ThemeService implements IThemeService {
  @override
  void systemUIOverlayStyle(Color backgroundColor, Brightness brightness) {
    tu.fn.debounce(() {
      final isLight = brightness == Brightness.light;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          // 作用： 控制设备状态栏（顶部的通知区域）内容的亮度。
          // 它决定了顶部状态栏背景是浅色还是深色，从而影响前景文字和图标的颜色。
          // Brightness.dark: 意味着状态栏背景是深色的，因此状态栏上的文字和图标会是浅色的（白色或亮色）。
          // Brightness.light: 意味着状态栏背景是浅色的，因此状态栏上的文字和图标会是深色的（黑色或暗色）。
          statusBarIconBrightness: isLight ? Brightness.light : Brightness.dark,
          // Android
          // 控制设备底部导航栏（系统按钮区域）图标的颜色。
          // Brightness.dark: 导航栏图标是深色的（黑色）。
          // Brightness.light: 导航栏图标是浅色的（白色）。
          systemNavigationBarColor: backgroundColor,
          // systemNavigationBarIconBrightness:
          //     isLight ? Brightness.dark : Brightness.light, // 根据背景色调整导航栏图标颜色

          // 以下的 iOS
          statusBarBrightness: brightness, // iOS
        ),
      );
    }, milliseconds: 100);
  }

  void defaultSystemUIOverlayStyle() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  /// 修改主题
  /// Get.changeTheme(Get.isDarkMode? ThemeData.light(): ThemeData.dark());
  void changeTheme(ThemeData theme) {
    Get.changeTheme(theme);
  }
}
