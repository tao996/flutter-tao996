import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceService {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double statusBarHeight = 0;

  static void calScreenSize(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    statusBarHeight = MediaQuery.of(context).padding.top;
  }

  /// 获取平台（小写）
  static String platform() {
    return defaultTargetPlatform.toString().toLowerCase();
  }
}
