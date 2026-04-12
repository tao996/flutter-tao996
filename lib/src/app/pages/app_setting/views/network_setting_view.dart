import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'network_setting_controller.dart';

class NetworkSettingView extends StatelessWidget {
  final c = Get.put(NetworkSettingController());

  NetworkSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => SwitchListTile(
            value: c.useProxy.value,
            onChanged: c.changeUseProxy,
            title: Text('proxyUse'.tr),
            subtitle: Text('proxyUseDesc'.tr),
            secondary: const Icon(Icons.public_rounded),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.link_rounded),
          title: Text('proxyAddress'.tr),
          subtitle: Obx(
            () => Text(
              c.proxyAddress.value.isEmpty
                  ? 'proxyNotSet'.tr
                  : c.proxyAddress.value,
            ),
          ),
          onTap: () {
            final controller = TextEditingController(
              text: c.proxyAddress.value,
            );
            Get.dialog(
              AlertDialog(
                icon: const Icon(Icons.link_rounded),
                title: Text('proxyAddress'.tr),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: 'proxyAddress'.tr,
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('cancel'.tr),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  TextButton(
                    child: Text('confirm'.tr),
                    onPressed: () {
                      c.changeProxyAddress(controller.text);
                      Get.back();
                    },
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.tag_rounded),
          title: Text('proxyPort'.tr),
          subtitle: Obx(
            () => Text(
              c.proxyPort.value.toString().isEmpty
                  ? 'proxyNotSet'.tr
                  : c.proxyPort.value.toString(),
            ),
          ),
          onTap: () {
            final controller = TextEditingController(
              text: c.proxyPort.value.toString(),
            );
            Get.dialog(
              AlertDialog(
                icon: const Icon(Icons.tag_rounded),
                title: Text('proxyPort'.tr),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: 'proxyPort'.tr,
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('cancel'.tr),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  TextButton(
                    child: Text('confirm'.tr),
                    onPressed: () {
                      c.changeProxyPort(controller.text);
                      Get.back();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
