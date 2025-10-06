import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tao996/src/utils/fn_util.dart';

abstract class IMySmartRefresherBodyController extends GetxController {
  late final RefreshController refreshController;

  Future<void> onLoadMore();

  Future<void> onRefresh();

  bool hasMoreData();
}
/// 静态方法，提供刷新和加载更多
class MySmartRefresher {
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
        // dprint('smartRefreshMode: $mode; hasMoreData: ${controller.hasMoreData()}');
        if (mode == LoadStatus.noMore || !controller.hasMoreData()) {
          body = Text("noMoreData".tr);
          // body = Container(); // Text("noMoreData".tr);
        } else if (mode == LoadStatus.failed) {
          body = Text("loadFailedRetry".tr);
        } else if (mode == LoadStatus.idle) {
          body = Text("pullUpLoadMore".tr);
        } else if (mode == LoadStatus.loading) {
          body = CircularProgressIndicator();
        } else {
          body = Text("pullUpLoadMore".tr);
        }
        return SizedBox(height: 30.0, child: Center(child: body));
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

return  return SmartRefresher(
  enablePullDown: true,
  enablePullUp: true,
  header: const WaterDropHeader(),
  footer: MySmartRefresher.footer(),
  controller: c.refreshController,
  onRefresh: c.onRefresh,
  onLoading: c.onLoadMore,
  child: ListView.separated(
    physics:
        c.postList.isEmpty
            ? const AlwaysScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
    controller: c.scrollController,
    itemBuilder: (context, index) {
      final post = c.postList[index];
      return PostCardSwipeActionCell(
        post,
        itemOnTap: () {
          c.toPost(c.postList[index], index: index);
        },
      );
    },
    separatorBuilder: (context, index) => const SizedBox(height: 8),
    itemCount: c.postList.length,
  ),
);
 */
