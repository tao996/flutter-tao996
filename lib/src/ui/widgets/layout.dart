import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyLayout {
  static Widget emptyWidget() => const SizedBox.shrink();

  static Widget height() => const SizedBox(height: 16);

  static Widget height8() => const SizedBox(height: 8);

  static Widget width() => const SizedBox(width: 16);

  static Widget width8() => const SizedBox(width: 8);

  static Widget miniColumn(
    List<Widget> children, {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    double spacing = 0.0,
    bool block = false,
  }) {
    final child = MyEvents.unfocusOnTap(
      Column(
        mainAxisSize: MainAxisSize.min,
        // 推荐：只占用所需的垂直空间
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        spacing: spacing,
        children: children,
      ),
    );
    return block ? MyBlockWidget(child) : child;
  }

  static Widget miniRow(
    List<Widget> children, {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    double spacing = 0.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      spacing: spacing,
      children: children,
    );
  }

  static Widget miniListView(
    int? itemCount,
    Widget? Function(BuildContext, int) itemBuilder,
  ) {
    return ListView.builder(
      // 保持 shrinkWrap: true，让 ListView 根据内容高度收缩
      shrinkWrap: true,
      // 保持 NeverScrollableScrollPhysics()，禁用内部滚动，让外部的处理滚动
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  /// [crossAxisCount] 列数；[itemCount] 总记录数量;
  ///
  /// [crossAxisSpacing] 列间距；[mainAxisSpacing] 行间距; [childAspectRatio] 宽度比
  static Widget gridView(
    BuildContext context, {
    required int crossAxisCount,
    required int itemCount,
    EdgeInsetsGeometry? padding,
    required Widget? Function(BuildContext, int) itemBuilder,
    double crossAxisSpacing = 8,
    double mainAxisSpacing = 8,
    double childAspectRatio = 1.0,
  }) {
    return GridView.builder(
      // 使用 GridView 使得名称可以多列布局，更美观
      shrinkWrap: true,
      // 根据内容收缩，避免占用过多空间
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      // 禁用内部滚动，由父级滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 列数
        crossAxisSpacing: crossAxisSpacing, // 列间距
        mainAxisSpacing: mainAxisSpacing, // 行间距
        childAspectRatio: childAspectRatio, // 宽高比
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  static Widget leftLabel(String label, Widget child, {double width = 80}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          child: Text(
            label,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }

  static Widget right(Widget child) {
    return Align(alignment: Alignment.centerRight, child: child);
  }

  static Widget left(Widget child) {
    return Align(alignment: Alignment.centerLeft, child: child);
  }

  static Widget card(Widget child) {
    return Card(
      margin: EdgeInsets.zero,
      child: MyPadding(child: child),
    );
  }
}

/// 自定义 FAB 位置，使其向上偏移指定的距离
class CustomEndFloatFabLocation extends FloatingActionButtonLocation {
  final double offsetY;

  const CustomEndFloatFabLocation(this.offsetY);

  // 1. 实现 getOffsetX: 确定 FAB 的 X 坐标 (标准 endFloat 逻辑)

  double getOffsetX(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    // 默认的右侧定位逻辑：Scaffold 宽度 - FAB 宽度 - 16.0 边距
    final double end = scaffoldGeometry.scaffoldSize.width;
    final double x =
        end - scaffoldGeometry.floatingActionButtonSize.width - 16.0;

    // 减去 adjustment (通常用于处理 bottomSheet 或 SnackBar 的宽度变化，一般为 0)
    return x - adjustment;
  }

  // 2. 实现 getOffsetY: 确定 FAB 的 Y 坐标 (标准 endFloat 逻辑)
  double getOffsetY(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    // 默认的底部定位逻辑：
    // 使用 contentBottom (内容区域的底部 Y 坐标) 减去 FAB 高度，再减去底部边距 (16.0)。
    // contentBottom 已经考虑了 bottomNavigationBar 和系统插边。
    final double contentBottom = scaffoldGeometry.contentBottom;

    final double standardY =
        contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height -
        16.0; // 默认底部边距

    // 扣除 adjustment
    return standardY;
  }

  // 3. 核心覆盖 getOffset：应用自定义偏移
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // 调用实现的 getOffsetX 和 getOffsetY 获得标准位置
    final double standardX = getOffsetX(scaffoldGeometry, 0.0);
    final double standardY = getOffsetY(scaffoldGeometry, 0.0);

    // 返回调整后的坐标：Y 坐标减去我们需要的偏移量 (向上移动)
    return Offset(
      standardX,
      standardY - offsetY, // <-- 核心修改点：向上偏移
    );
  }

  @override
  String toString() => 'FloatingActionButtonLocation.customEndFloat($offsetY)';
}
