import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class MyEasyRefreshController extends GetxController {
  ScrollController scrollController = ScrollController();
  var hasMore = true.obs;

  @override
  void onInit() { // 只有在 Get.put 中才能正确初始化
    super.onInit();
    scrollController.addListener(() async {
      if (!hasMore.value){
        return;
      }
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

  /// 当用户执行下拉刷新手势时，框架会调用这个异步函数。
  Future<void> onRefresh();

  Future<void> onLoadMore();
}

class EasyRefresh {
  /// 为列表提供下拉刷新功能；
  static Widget listView(
    MyEasyRefreshController c, {
    required Widget? Function(BuildContext, int) itemBuilder,
    required int itemCount,
    bool physics = true,
    Widget Function(BuildContext, int)? separatorBuilder,
    EdgeInsetsGeometry? padding,
  }) {
   return RefreshIndicator(
      onRefresh: c.onRefresh,
      child: ListView.separated(
        controller: c.scrollController,
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
/*
RefreshIndicator
color 加载指示器（圆圈）的颜色。 默认颜色取自主题的 colorScheme.primary
backgroundColor 加载指示器背景圆圈的颜色。 默认颜色取自主题的 canvasColor 或 scaffoldBackgroundColor。
displacement 加载指示器距离顶部边缘的距离（垂直偏移量）。 默认值为 40.0。你可以增加这个值让指示器在下拉时离顶部更远。
 */