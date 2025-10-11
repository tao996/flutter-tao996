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
      appBar: AppBar(title: Text('DEMO SmartRefresher')),
      body: SafeArea(
        child: Obx(
          () => MySmartRefresher.body(
            c,
            child: c.items.isNotEmpty
                ? ListView.builder(
                    itemCount: c.items.length,
                    itemBuilder: (context, index) {
                      final t = c.items[index];
                      return ListTile(title: Text('$t -- $index'));
                    },
                  )
                : Center(child: Text('无数据')),
          ),
        ),
      ),
    );
  }
}
