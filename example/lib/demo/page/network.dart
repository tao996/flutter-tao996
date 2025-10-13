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
          MyText.h3(context, 'MyNetworkWidget'),
          const SizedBox(height: 16),
          MyNetworkWidget(
            builder: (context, result) {
              if (result.isWifi) {
                return myImagePlaceholder('wifi 高清图片');
              } else if (result.isMobile) {
                return myImagePlaceholder('mobile 普通图片');
              } else {
                return myImagePlaceholder('No internet connection');
              }
            },
          ),
          const SizedBox(height: 16),
          MyText.h3(context, 'MyNetworkController'),
          const SizedBox(height: 16),
          Obx(() {
            if (c.results.isWifi) {
              return myImagePlaceholder('wifi 高清图片');
            } else if (c.results.isConnected) {
              return myImagePlaceholder('mobile 普通图片');
            }
            return myImagePlaceholder('No internet connection');
          }),
        ],
      ),
    );
  }
}
