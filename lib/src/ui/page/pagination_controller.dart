import 'package:get/get.dart';

abstract class MyPaginationController<T> extends GetxController {
  /// 当前显示的记录
  RxList<T> items = <T>[].obs;

  /// 总的记录数量，通常使用 count 查询
  RxInt total = 0.obs;
  RxInt pageIndex = 1.obs;
  RxInt pageSize = 20.obs;

  Future<void> loadItemsData();

  /// 修改分页
  void bindPageIndexChange(int newPage) async {
    pageIndex.value = newPage;
    await loadItemsData();
  }
}
