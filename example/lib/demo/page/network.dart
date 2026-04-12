import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyDemoNetwork extends StatelessWidget {
  late final MyNetworkController c;

  MyDemoNetwork({super.key}) {
    c = Get.put(MyNetworkController());
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: false,
      appBar: AppBar(title: Text('网络')),
      body: Column(
        children: [
          MyText.h3('MyNetworkWidget'),
          const SizedBox(height: 16),
          MyNetworkWidget(
            builder: (context, result) {
              if (result.isWifi) {
                return tu.image.placeholder('wifi 高清图片');
              } else if (result.isMobile) {
                return tu.image.placeholder('mobile 普通图片');
              } else {
                return tu.image.placeholder('No internet connection');
              }
            },
          ),
          const SizedBox(height: 16),
          MyText.h3('MyNetworkController'),
          const SizedBox(height: 16),
          Obx(() {
            if (c.results.isWifi) {
              return tu.image.placeholder('wifi 高清图片');
            } else if (c.results.isConnected) {
              return tu.image.placeholder('mobile 普通图片');
            }
            return tu.image.placeholder('No internet connection');
          }),
        ],
      ),
    );
  }
}
