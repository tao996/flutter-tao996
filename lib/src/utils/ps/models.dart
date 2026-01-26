import 'package:flutter/material.dart';

/// 定义支持叠加的样式对象
class PsStyle {
  Size? size;
  double? radius;
  double? opacity;
  Color? color;
  Color? backgroundColor;
  double? fontSize;
  FontWeight? fontWeight;
  // 距离中心的偏移量
  Offset position;
  // 是否以画布中心为参考点
  bool center;
  // 是否继承父级样式（比如 ps 的 canvasSize）
  bool inherit;

  /// 边框 borderWidth: 2
  double? borderWidth;

  /// 边框颜色: Colors.blueGrey
  Color? borderColor;

  /// 阴影 BoxShadow(  color: Colors.black.withOpacity(0.2),  blurRadius: 10, offset: const Offset(5, 5),)
  BoxShadow? shadow; // 使用 Flutter 原生的 BoxShadow 方便配置颜色、模糊和偏移
  Size? canvasSize; // 将画布尺寸整合进样式

  PsStyle({
    this.size,
    this.radius,
    this.opacity,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.position = Offset.zero,
    this.center = true,
    this.inherit = true,
    this.borderWidth,
    this.borderColor,
    this.shadow,
    this.canvasSize,
  });

  PsStyle copyWith(PsStyle? other) {
    if (other == null) return this;
    return PsStyle(
      position: other.position,
      size: other.size ?? size,
      radius: other.radius ?? radius,
      opacity: other.opacity ?? opacity,
      color: other.color ?? color,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      center: other.center, // 确保合并逻辑包含 center
      inherit: other.inherit,
      borderWidth: other.borderWidth ?? borderWidth,
      borderColor: other.borderColor ?? borderColor,
      shadow: other.shadow ?? shadow,
      canvasSize: other.canvasSize ?? canvasSize,
    );
  }

  Size get drawSize => canvasSize ?? size ?? Size.zero;
}

class PsClass {
  final String name;
  final PsStyle style;
  PsClass({required this.name, required this.style});
}

enum PsNodeType { rect, circle, svg, text, image, line }

class PsNode {
  final String? tag;
  final List<String> classes;
  final PsNodeType type;
  final dynamic data;
  final PsStyle style;

  PsNode({
    this.tag,
    this.classes = const [],
    required this.type,
    required this.data,
    required this.style,
  });

  /// 计算节点在画布上的物理 Rect
  Rect get rect {
    // 逻辑：如果设置了 inherit 且没有 size，则继承 style 里的 canvasSize
    final s =
        style.size ??
        (style.inherit ? (style.canvasSize ?? Size.zero) : Size.zero);
    final p = style.position;
    final cs = style.canvasSize ?? Size.zero;

    if (style.center && cs != Size.zero) {
      return Offset(
            (cs.width - s.width) / 2 + p.dx,
            (cs.height - s.height) / 2 + p.dy,
          ) &
          s;
    }
    return p & s;
  }
}

class PsMask {
  final Rect rect; // 蒙板区域
  final double radius; // 圆角
  final bool showBorder; // 新增：是否显示调试边框

  PsMask({required this.rect, this.radius = 0, this.showBorder = false});
}

class PsLayer {
  final List<PsNode> nodes; // 图形列表
  final PsMask? mask; // 蒙板

  PsLayer({required this.nodes, this.mask});
}
