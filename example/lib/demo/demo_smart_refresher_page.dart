import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996_example/demo/demo_smart_refresher_controller.dart';

class DemoSmartRefresherPage extends StatelessWidget {
  late final DemoSmartRefresherController c;

  DemoSmartRefresherPage({super.key}) {
    c = Get.put(DemoSmartRefresherController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SmartRefresher')),
      body: MyBodyPadding(MySmartRefresher.body(c)),
    );
  }
}
