import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tao996/src/utils/fn_util.dart';

abstract class IMySmartRefresherBodyController extends GetxController {
  late final RefreshController refreshController;

  Future<void> onLoadMore();

  Future<void> onRefresh();
}

/// 静态方法，提供刷新和加载更多
class MySmartRefresher {
  /// [child] 必须是一个 ListView，其它写法特别是 Obx(()=> ListView.builder()) 不起作用
  ///
  /// ```dart
  /// child: Obx(() => MySmartRefresher.body(c,
  ///             child: c.items.isNotEmpty ? ListView.builder(
  ///   itemCount: c.items.length,
  ///   itemBuilder: (context, index) {
  ///     return ListTile(title: Text(index.toString()));
  /// },):const Center(child: Text('无数据')),),),
  /// ```
  static SmartRefresher body(
    IMySmartRefresherBodyController controller, {
    Widget? child,
    Widget? customFooter,
    Widget? customHeader,
    bool enablePullDown = true,
    bool enablePullUp = true,
    void Function()? onRefresh,
    void Function()? onLoading,
  }) {
    return SmartRefresher(
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      header: customHeader ?? const WaterDropHeader(),
      footer: customFooter ?? footer(controller),
      controller: controller.refreshController,
      onRefresh: onRefresh ?? controller.onRefresh,
      onLoading: onLoading ?? controller.onLoadMore,
      child: child,
    );
  }

  static CustomFooter footer(IMySmartRefresherBodyController controller) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.failed) {
          body = Text("loadFailedRetry".tr);
        } else if (mode == LoadStatus.idle) {
          body = Text("pullUpLoadMore".tr);
        } else if (mode == LoadStatus.loading) {
          body = CircularProgressIndicator();
        } else if (mode == LoadStatus.canLoading) {
          body = Text("pullUpLoadMore".tr);
        } else {
          body = Text("noMoreData".tr);
        }
        return SizedBox(height: 55.0, child: Center(child: body));
      },
    );
  }
}


/*
return Scaffold(
  appBar: AppBar(title: Text(title)),
  body: SafeArea(
    child: Obx(
      () => MySmartRefresher.body(
        controller,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            return PostCardSwipeActionCell(
              controller.posts[index],
              itemOnTap: () {},
            );
          },
        ),
      ),
    ),
  ),
);
 */