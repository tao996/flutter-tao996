import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyDemoEasyRefreshController extends MyEasyRefreshController {
  RxList<String> items = <String>[].obs;

  @override
  Future<void> onLoadMore() {
    return Future.delayed(Duration(milliseconds: 200), () {
      final length = items.length;
      if (length >= 60) {
        hasMore.value = false;
        return;
      }
      items.addAll(List.generate(15, (index) => 'Item ${index + length}'));
    });
  }

  @override
  Future<void> onRefresh() {
    return Future.delayed(Duration(milliseconds: 200), () {
      hasMore.value = true;
      items.clear();
      items.addAll(List.generate(15, (index) => 'Item $index'));
    });
  }
}

class MyDemoEasyRefresh extends StatelessWidget {
  late final MyDemoEasyRefreshController c;

  MyDemoEasyRefresh({super.key}) {
    c = Get.put(MyDemoEasyRefreshController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EasyRefresh')),
      body: MyBodyPadding(
        Column(
          children: [
            Expanded(
              child: Obx(
                () => EasyRefresh.listView(
                  c,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(c.items[index]));
                  },
                  itemCount: c.items.length,
                ),
              ),
            ),
            Obx(() {
              if (!c.hasMore.value) {
                return Center(child: Text('没有更多数据了'));
              }
              return Container();
            }),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
