import 'package:tao996/tao996.dart';

class DemoSmartRefresherController extends MySmartRefresherController<int> {
  @override
  Future<List<int>?> loadData({required bool isRefresh}) async {
    if (items.length < 100) {
      int start = items.length;
      return List.generate(20, (i) {
        return i + start;
      });
    } else {
      return null;
    }
  }

  DemoSmartRefresherController() : super(autoLoad: false);
}
