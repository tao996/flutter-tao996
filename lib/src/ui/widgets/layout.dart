import 'package:flutter/cupertino.dart';

class MyLayout {

  static Widget emptyWidget() => const SizedBox.shrink();
  static Widget sizeHeight() => const SizedBox(height: 16,);
  static Widget miniColumn(
    List<Widget> children, {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    double spacing = 0.0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      // 推荐：只占用所需的垂直空间
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      spacing: spacing,
      children: children,
    );
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}
