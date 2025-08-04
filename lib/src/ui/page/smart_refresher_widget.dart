import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class MySmartRefresherBodyController extends GetxController {
  late final RefreshController refreshController;

  Future<void> onLoadMore();

  Future<void> onRefresh();
}

class MySmartRefresher {
  static SmartRefresher body(
    MySmartRefresherBodyController controller, {
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
      footer: customFooter ?? footer(),
      controller: controller.refreshController,
      onRefresh: onRefresh ?? controller.onRefresh,
      onLoading: onLoading ?? controller.onLoadMore,
      child: child,
    );
  }

  static CustomFooter footer() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.noMore) {
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
