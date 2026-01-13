import 'package:get/get.dart';
import 'package:tao996/src/helpers/model_delegate.dart';

abstract class MyPaginationController<T> extends GetxController {
  RxList<T> get items => delegate.rxItems;

  RxInt get total => delegate.rxTotal;

  final MyListDelegate<T> delegate = MyListDelegate();

  /// 总的记录数量，通常使用 count 查询
  RxInt pageIndex = 1.obs;
  RxInt pageSize = 20.obs;

  /// 加载数据
  Future<void> loadItemsData();

  /// 修改分页
  void bindPageIndexChange(int newPage) async {
    pageIndex.value = newPage;
    await loadItemsData();
  }
}
