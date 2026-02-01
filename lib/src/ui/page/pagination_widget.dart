import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pagination_controller.dart';

/// 简单的分页控制器，通过 “上一页”，“下一页” 按钮进行翻页
class MyPaginationWidget extends StatelessWidget {
  final MyPaginationController c;
  final bool showTotalPages;

  const MyPaginationWidget(this.c, {super.key, this.showTotalPages = true});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _child());
  }

  Widget _child() {
    int totalPages = (c.total.value / c.pageSize.value).ceil();
    return Row(
      mainAxisAlignment: showTotalPages
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      children: [
        // 记录数量
        if (showTotalPages)
          Text(
            '显示 ${(c.pageIndex.value - 1) * c.pageSize.value + 1}-${(c.pageIndex.value * c.pageSize.value).clamp(0, c.total.value)} 条，共 ${c.total.value} 条',
          ),
        // 分页按钮
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: c.pageIndex.value > 1
                  ? () => c.bindPageIndexChange(c.pageIndex.value - 1)
                  : null,
            ),
            Text('第 ${c.pageIndex.value} 页 / 共 $totalPages 页'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: c.pageIndex.value < totalPages
                  ? () => c.bindPageIndexChange(c.pageIndex.value + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
