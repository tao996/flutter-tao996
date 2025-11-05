import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  /// child: Obx(() => MySmartRefresher.body(c,enablePullUp: c.hasMore.value,
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
    // 注意：在 PC 端需要 app.dart 中添加配置 https://github.com/peng8350/flutter_pulltorefresh/issues/544
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

  /// 为了方便使用 Obx，只需要将 child 包裹在 Obx 中即可
  static SmartRefresher obxBody(
    IMySmartRefresherBodyController controller, {
    Widget? child,
    required RxBool canLoadMore,
  }) {
    // 注意：在 PC 端需要 app.dart 中添加配置 https://github.com/peng8350/flutter_pulltorefresh/issues/544
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: footer(controller),
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoading: () {
        if (canLoadMore.value) {
          controller.onLoadMore();
        } else {
          controller.refreshController.loadNoData();
        }
      },
      child: child,
    );
  }

  static CustomFooter footer(IMySmartRefresherBodyController controller) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        // dprint('CustomFooter: $mode');
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
