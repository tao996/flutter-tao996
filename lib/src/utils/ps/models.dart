import 'dart:ui' as ui;

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
  double scale; // 新增缩放属性
  EdgeInsets? padding; // 仅供 MyPs 使用
  EdgeInsets? margin; // 供节点使用
  double rotate; // 旋转弧度，默认 0.0

  // --- 新增：渐变属性 ---
  Gradient? backgroundGradient; // 用于背景填充的渐变
  Gradient? foregroundGradient; // 用于前景（比如文字颜色或边框颜色）的渐变
  BoxShadow? textShadow; // 新增文字阴影

  ui.Image? backgroundImage; // 背景图片
  BoxFit backgroundFit; // 背景图片适配方式，默认 cover
  double? blur; // 模糊半径，用于制作毛玻璃效果，若为 null 则不模糊
  int zIndex; //

  PsStyle({
    this.size,
    this.radius,
    this.opacity,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.position = Offset.zero,
    this.scale = 1.0, // 默认为 1.0 (不缩放)
    this.center = true,
    this.inherit = true,
    this.borderWidth,
    this.borderColor,
    this.shadow,
    this.canvasSize,
    this.padding,
    this.margin,
    this.rotate = 0.0,
    this.backgroundGradient,
    this.foregroundGradient,
    this.textShadow,
    this.backgroundImage,
    this.backgroundFit = BoxFit.cover,
    this.blur,
    this.zIndex = 0,
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
      scale: other.scale != 1.0 ? other.scale : scale, // 简单的合并逻辑
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      rotate: other.rotate != 0.0 ? other.rotate : rotate,
      backgroundGradient: other.backgroundGradient ?? backgroundGradient,
      foregroundGradient: other.foregroundGradient ?? foregroundGradient,
      textShadow: other.textShadow ?? textShadow,
      backgroundImage: other.backgroundImage ?? backgroundImage,
      backgroundFit: other.backgroundFit,
      blur: other.blur ?? blur,
      zIndex: other.zIndex != 0 ? other.zIndex : zIndex,
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
    // 1. 获取画布尺寸和由 MyPs padding 转化来的 margin
    final cs = style.canvasSize ?? Size.zero;
    final m = style.margin ?? EdgeInsets.zero;

    // 2. 计算节点的基础尺寸
    // 如果 inherit 为 true，基础尺寸应该是画布尺寸减去四周的 margin
    Size baseSize;
    if (style.size != null) {
      baseSize = style.size!;
    } else if (style.inherit) {
      baseSize = Size(
        cs.width - m.left - m.right,
        cs.height - m.top - m.bottom,
      );
    } else {
      baseSize = Size.zero;
    }

    // 3. 应用缩放 (如果有 scale 属性)
    final s = baseSize * style.scale;

    // 4. 计算最终位置
    if (style.center) {
      // 居中模式：在画布中心点基础上，叠加 margin 带来的偏移量偏移
      // 公式：画布中心 - 节点中心 + (左偏移-右偏移)/2 (用于处理非对称margin)
      return Offset(
            (cs.width - s.width) / 2 +
                (m.left - m.right) / 2 +
                style.position.dx,
            (cs.height - s.height) / 2 +
                (m.top - m.bottom) / 2 +
                style.position.dy,
          ) &
          s;
    } else {
      // 绝对定位模式：从画布左上角 (0,0) 出发，先移过 margin，再移过 style.position
      return Offset(m.left + style.position.dx, m.top + style.position.dy) & s;
    }
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
