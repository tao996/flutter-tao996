import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class MyEasyRefreshController extends GetxController {
  ScrollController scrollController = ScrollController();
  RxBool canLoadMore = false.obs;
  RxDouble loadMoreDisplacement = 40.0.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        await onLoadMore();
      }
    });
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> onRefresh();

  Future<void> onLoadMore();
}

class EasyRefresh {
  /// 为列表提供下拉刷新功能；
  ///
  /// [itemBuilder] 列表项构造函数；[itemCount] 列表项数量
  /// [physics] 默认提供 iOS 回弹效果；
  static Widget listView(
    MyEasyRefreshController c, {
    required Widget? Function(BuildContext, int) itemBuilder,
    required int itemCount,
    bool physics = false,
    Widget Function(BuildContext, int)? separatorBuilder,
    EdgeInsetsGeometry? padding,
  }) {
    return RefreshIndicator(
      onRefresh: c.onRefresh,
      displacement: c.canLoadMore.value ? c.loadMoreDisplacement.value : 0,
      child: ListView.separated(
        controller: c.canLoadMore.value ? c.scrollController : null,
        physics: physics
            ? const AlwaysScrollableScrollPhysics() // 强制可滚动，无论内容是否溢出
            : const BouncingScrollPhysics(),
        // 只有内容溢出时，才允许滚动，并有回弹效果
        separatorBuilder:
            separatorBuilder ?? (context, index) => const SizedBox(height: 4),
        itemCount: itemCount,
        padding: padding ?? const EdgeInsets.all(4),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
