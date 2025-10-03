import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../tao996.dart';

abstract class MySmartRefresherController<T>
    extends MySmartRefresherBodyController {
  int pageIndex = 1;
  int pageSize = 15;
  final RxBool hasMore = true.obs;
  final RxList<T> items = <T>[].obs;

  RxBool isRequesting = false.obs;

  MySmartRefresherController({bool autoLoad = true}) {
    refreshController = RefreshController(initialRefresh: autoLoad);
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  void pageIndexReset() {
    pageIndex = 1;
  }

  /// 初始化数据，在控制器 onInit 时被调用
  Future<void> initData();

  /// 加载数据，在 smartRefresh 中被调用；不需要设置 isRequesting 或者 assignItems 等操作
  /// [isRefresh] 是否是刷新，如果是，则需要重置搜索条件
  /// ```dart
  /// Future<List<ServerFeed>?> loadData() async {
  ///    final res = await getServerFeedService().search(page: currentPage,pageSize: pageSize);
  ///    return Future.value(res.rows as List<ServerFeed>);
  /// }
  /// ```
  Future<List<T>?> loadData({required bool isRefresh});

  void assignItems(List<T> newItems) {
    items.assignAll(newItems);
  }

  void loadNoData() {
    refreshController.loadNoData();
    hasMore.value = false;
  }

  Future<void> smartRefresh({bool isRefresh = false}) async {
    if (isRefresh) {
      pageIndex = 1;
      hasMore.value = true;
    }
    if (hasMore.value) {
      dprint('smartRefresh hasMore');
      final newItems = await loadData(isRefresh: isRefresh);
      if (newItems == null || newItems.isEmpty) {
        hasMore.value = false;
        if (isRefresh) {
          dprint('refreshController.refreshCompleted()');
          refreshController.refreshCompleted();
        } else {
          dprint('refreshController.loadComplete()');
          refreshController.loadComplete();
        }
        loadNoData();
        assignItems([]);
      } else {
        assignItems(newItems);
        if (newItems.length < pageSize) {
          hasMore.value = false;
        }
        if (isRefresh) {
          dprint('refreshController.refreshCompleted()');
          refreshController.refreshCompleted();
        } else {
          dprint('refreshController.loadComplete()');
          refreshController.loadComplete();
        }
        pageIndex++;
      }
    } else {
      dprint('smartRefresh noMore');
      if (!isRefresh) {
        dprint('!isRefresh');
        loadNoData();
      } else {
        dprint('refreshController.refreshCompleted()');
        refreshController.refreshCompleted();
      }
    }
    dprint('hasMore: $hasMore');
  }

  Future<void> afterOnRefresh() async {}

  /// 普通搜索
  Future<void> onReSearch()async{
    dprint('smartRefreshController onReSearch');
    isRequesting.value = true;
    try {
      await smartRefresh(isRefresh: true);
      items.refresh();
    } catch (error, stackTrace) {
      getIDebugService().exception(error, stackTrace);
      getIMessageService().toast(error.toString());
    } finally {
      isRequesting.value = false;
    }
  }

  /// 下拉刷新
  @override
  Future<void> onRefresh() async {
    dprint('smartRefreshController onRefresh');
    isRequesting.value = true;
    try {
      await smartRefresh(isRefresh: true);
      items.refresh();
      await afterOnRefresh();
    } catch (error, stackTrace) {
      getIDebugService().exception(error, stackTrace);
      getIMessageService().toast(error.toString());
    } finally {
      isRequesting.value = false;
      // refreshController.refreshCompleted();
    }
  }
  /// 回调
  Future<void> afterOnLoadMore() async {}

  /// 加载更多
  @override
  Future<void> onLoadMore() async {
    dprint('smartRefreshController onLoadMore');
    isRequesting.value = true;
    try {
      await smartRefresh();
      items.refresh();
      await afterOnLoadMore();
    } catch (error, stackTrace) {
      getIDebugService().exception(error, stackTrace);
      getIMessageService().toast(error.toString());
    } finally {
      isRequesting.value = false;
      // refreshController.loadComplete();
    }
  }

  @override
  bool hasMoreData(){
    return hasMore.value;
  }
}
