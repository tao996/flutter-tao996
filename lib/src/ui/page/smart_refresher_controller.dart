import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../tao996.dart';

abstract class MySmartRefresherController<T>
    extends IMySmartRefresherBodyController {
  int pageIndex = 1;
  int pageSize = 15;

  /// 是否有更多数据
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

  /// 重置页码
  void pageIndexReset() {
    pageIndex = 1;
  }

  /// 绑定搜索，通常是关键字搜索
  void bindSearch(String text) {
    FnUtil.debounce(() {
      pageIndexReset();
      onReSearch();
    }, milliseconds: 1000);
  }

  /// 初始化数据，在控制器 onInit 时被调用
  Future<void> initData() async {}

  /// 加载数据，在 smartRefresh 中被调用；不需要设置 isRequesting 或者 assignItems 等操作
  /// [isRefresh] 是否是刷新，如果是，则需要重置搜索条件
  /// ```dart
  /// Future<List<ServerFeed>?> loadData() async {
  ///    return await userService.getPaginationData(where: _getWhere(), pageSize: pageSize,pageIndex: pageIndex,);
  /// }
  /// ```
  Future<List<T>?> loadData({required bool isRefresh});

  void assignItems(List<T> newItems, {bool isRefresh = false}) {
    if (isRefresh) {
      items.clear();
    }
    // dprint('--------:'+items.toString());
    // dprint(newItems);
    items.addAll(newItems);
    // dprint(items);
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
        dprint('loadData return null or empty');
        hasMore.value = false;
        if (isRefresh) {
          dprint('refreshController.refreshCompleted()');
          refreshController.refreshCompleted();
        } else {
          dprint('refreshController.loadComplete()');
          refreshController.loadComplete();
        }
        loadNoData();
        assignItems([], isRefresh: isRefresh);
      } else {
        dprint('loadData return not empty');
        assignItems(newItems, isRefresh: isRefresh);
        if (newItems.length < pageSize) {
          hasMore.value = false;
        }
        dprint('hasMore: ${hasMore.value}');
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
  Future<void> onReSearch() async {
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
}
