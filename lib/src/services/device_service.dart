import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 内核/系统家族， 用于判断核心架构、API 兼容性和基本文件系统结构。这是跨发行版保持一致的底层属性。
/// 注意区分 发行版/OS 标识符
enum OS { unknown, windows, linux, unix, macos, android, ios, fuchsia }

class MyDeviceService {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double statusBarHeight = 0;

  static void calScreenSize(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; // Get.width
    screenHeight = MediaQuery.of(context).size.height; // Get.height
    statusBarHeight = MediaQuery.of(context).padding.top;
  }

  /// 获取平台（小写）
  /// https://github.com/jonataslaw/getx?tab=readme-ov-file#other-advanced-apis
  static String platform() {
    return defaultTargetPlatform.toString().toLowerCase();
    /*
GetPlatform.isAndroid
GetPlatform.isIOS
GetPlatform.isMacOS
GetPlatform.isWindows
GetPlatform.isLinux
GetPlatform.isFuchsia

//Check the device type
GetPlatform.isMobile
GetPlatform.isDesktop
//All platforms are supported independently in web!
//You can tell if you are running inside a browser
//on Windows, iOS, OSX, Android, etc.
GetPlatform.isWeb
     */
  }

  static bool isPc() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static OS runtimeOS() {
    if (Platform.isAndroid) {
      return OS.android;
    } else if (Platform.isIOS) {
      return OS.ios;
    } else if (Platform.isLinux) {
      return OS.linux;
    } else if (Platform.isMacOS) {
      return OS.macos;
    } else if (Platform.isWindows) {
      return OS.windows;
    } else if (Platform.isFuchsia) {
      return OS.fuchsia;
    } else {
      return OS.unknown;
    }
  }
}
