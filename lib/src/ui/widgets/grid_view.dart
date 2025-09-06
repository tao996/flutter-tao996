import 'package:flutter/material.dart';

/// [crossAxisCount] 列数；[itemCount] 总记录数量;
///
/// [crossAxisSpacing] 列间距；[mainAxisSpacing] 行间距; [childAspectRatio] 宽度比
Widget myGridView(
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
