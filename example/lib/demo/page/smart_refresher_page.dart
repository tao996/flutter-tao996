import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

// class DemoSmartRefresherController extends GetxController
//     implements IMySmartRefresherBodyController {
//   var items = [].obs;
//
//   @override
//   RefreshController refreshController = RefreshController(
//     initialRefresh: false,
//   );
//
//   @override
//   Future<void> onLoadMore() async {
//     await Future.delayed(Duration(milliseconds: 1000));
//     // if failed,use loadFailed(),if no data return,use LoadNodata()
//     items.addAll(["1", "2", "3", "4", "5", "6", "7", "8"]);
//     refreshController.loadComplete();
//   }
//
//   @override
//   Future<void> onRefresh() async {
//     await Future.delayed(Duration(milliseconds: 1000));
//     items.clear();
//     items.addAll(["1", "2", "3", "4", "5", "6", "7", "8"]);
//     refreshController.refreshCompleted();
//   }
// }

class MyDemoSmartRefresherController extends MySmartRefresherController<String> {
  @override
  Future<List<String>?> loadData({required bool isRefresh}) async {
    await Future.delayed(Duration(milliseconds: 1000));
    final l = isRefresh ? 0 : items.length;
    if (l >= 85) {
      return null;
    }
    return List.generate(pageSize, (index) {
      return "${l + index}";
    });
  }
}

class MyDemoSmartRefresherPage extends StatelessWidget {
  late final MyDemoSmartRefresherController c;

  MyDemoSmartRefresherPage({super.key}) {
    c = Get.put(MyDemoSmartRefresherController());
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
