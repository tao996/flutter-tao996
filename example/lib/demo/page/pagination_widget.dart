import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyDemoPaginationController extends MyPaginationController<String> {
  @override
  void onInit() {
    super.onInit();
    total.value = 100;
    loadItemsData();
  }

  @override
  Future<void> loadItemsData() async {
    items.assignAll(
      List.generate(pageSize.value, (index) {
        final i = pageSize.value * (pageIndex.value - 1) + index;
        return 'item $i';
      }),
    );
  }
}

class MyDemoPagination extends StatelessWidget {
  late final MyDemoPaginationController c;

  MyDemoPagination({super.key}) {
    c = Get.put(MyDemoPaginationController());
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: false,
      appBar: AppBar(title: Text('Demo Pagination')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: c.items.length,
                itemBuilder: (context, index) {
                  final item = c.items[index];
                  return ListTile(title: Text(item));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          MyPaginationWidget(c, showTotalPages: true),
        ],
      ),
    );
  }
}
