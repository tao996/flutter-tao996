import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

import 'app_setting_controller.dart';
import 'views/debug_setting_view.dart';
import 'views/display_setting_view.dart';
import 'views/network_setting_view.dart';

class AppSettingPage extends StatelessWidget {
  final c = Get.put(AppSettingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settingSystem'.tr)),
      body: SafeArea(
        child: CustomScrollView(
          // physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList.list(
              children: [
                // 显示设置
                MyText.groupText('settingDisplay'.tr),
                DisplaySettingView(),
                // 网络设置
                MyText.groupText('settingNetwork'.tr),
                NetworkSettingView(),
                if (kDebugMode) ...[
                  // 调试设置
                  MyText.groupText('Debug Test'.tr),
                  DebugSettingView(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
