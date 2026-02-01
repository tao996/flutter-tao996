import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tao996/tao996.dart';

abstract class MySmartRefresherController<T>
    extends IMySmartRefresherBodyController {
  AbstractListDelegate<T> delegate;

  /// 当前页面，默认为1
  int pageIndex = 1;
  int pageSize = 15;

  /// 是否有更多数据
  final RxBool hasMore = true.obs;

  RxList<T> get items => delegate.rxItems;

  /// 数据请求中
  RxBool isRequesting = false.obs;

  /// [autoLoad] 是否自动加载数据；注意：如果 [autoLoad] 设置为 false，则需要将 delegate 的绑定存放到构造函数中
  ///
  /// [pageSize] 每页数量
  MySmartRefresherController({
    bool autoLoad = false,
    this.pageSize = 15,
    AbstractListDelegate<T>? delegate,
  }) : delegate = delegate ?? MyListDelegate<T>() {
    refreshController = RefreshController(initialRefresh: autoLoad);
  }

  int _initCount = 0;

  @override
  void onInit() {
    super.onInit();
    if (_initCount == 0 && refreshController.initialRefresh == false) {
      _initCount++;

      /// 必须提前设计好 delegate，才能请求成功
      initData();
    }
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
    tu.fn.debounce(() {
      pageIndexReset();
      onReSearch();
    }, milliseconds: 1000);
  }

  /// 初始化数据，在控制器 onInit 时被调用
  Future<void> initData() async {
    isIniting.value = true;
    try {
      await smartRefresh(isRefresh: true);
    } catch (e, st) {
      getIDebugService().exception(e, st, errorMessage: e.toString());
    } finally {
      isIniting.value = false;
    }
  }

  /// 加载数据，在 smartRefresh 中被调用；不需要设置 isRequesting 或者 assignItems 等操作
  /// [isRefresh] 是否是刷新，如果是，则需要重置搜索条件
  /// ```dart
  /// 控制器 通常 extends MySmartRefresherController<T> implements MySearchInputMethods
  /// 1. 创建搜索条件
  /// class _SearchCondition {
  ///   String keyword = '';
  ///   String toString(){
  ///     if (keyword.isNotEmpty){
  ///       return "name like '%$keyword%'";
  ///     }
  ///     return '';
  ///   }
  /// }
  /// 2. 实现加载数据方法
  /// Future<List<ServerFeed>?> loadData() async {
  ///    return await userService.getPaginationData(where: _getWhere(), pageSize: pageSize,pageIndex: pageIndex,);
  /// }
  /// 3. 实现搜索方法
  /// @override
  /// Future<void> onChanged(String text, {data}) async {
  ///    searchConditions.keyword = text;
  ///    await onReSearch();
  /// }
  ///
  /// @override
  /// Future<void> onSubmitted(String text, {data}) async {}
  ///
  /// 视图
  /// body: Column(
  ///    children: [
  ///       FormHelper.search( c,
  ///          hintText: 'search'.tr,
  ///          value: c.searchConditions.keyword,
  ///       ),
  ///       Expanded(child: MyEvents.unfocusOnTap(body())),
  ///     ],
  /// )
  /// Widget body(BuildContext context) {
  ///     return Obx( () => MySmartRefresher.obxListView( c,
  ///         canLoadMore: c.hasMore,
  ///         empty:  MyEmptyStateWidget(title: 'record'.tr, onAction: c.bindInsertRecord,),
  ///         itemCount: c.items.value.length,
  ///         itemBuilder: (context, index) {
  ///           return Obx( () => ?, );
  ///         },
  ///       ),
  ///     );
  /// }
  /// ```
  Future<List<T>?> loadData({required bool isRefresh});

  /// 在搜索结果之后调用
  void assignItems(List<T> newItems, {bool isRefresh = false}) {
    if (isRefresh) {
      items.clear();
      items.value = newItems;
    } else {
      items.addAll(newItems);
    }
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
    dprint(
      '|<-- smartRefresh {hasMore: ${hasMore.value}, isRefresh: $isRefresh}',
    );
    if (hasMore.value) {
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

  /// 普通条件搜索
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
      refreshController.refreshCompleted();
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
