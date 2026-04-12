import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'debug_setting_controller.dart';

class DebugSettingView extends StatelessWidget {
  final DebugSettingController c = Get.put(DebugSettingController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.clear_all),
          title: const Text('清除应用设置'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            await c.clearSetting();
          },
        ),
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: const Text('打开日志目录'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            await c.openLogDir();
          },
        ),
      ],
    );
  }
}
