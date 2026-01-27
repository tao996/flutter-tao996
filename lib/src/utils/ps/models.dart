import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

part 'models.g.dart';

/// 定义支持叠加的样式对象
@JsonSerializable()
class PsStyle extends DbTypeModel<PsStyle> {
  @JsonSizeConverter()
  Size? size;

  double? radius;
  double? opacity;

  @JsonColorConverter()
  Color? color;

  @JsonColorConverter()
  Color? backgroundColor;

  double? fontSize;

  @JsonFontWeightConverter()
  FontWeight? fontWeight;
  // 距离中心的偏移量
  @JsonOffsetConverter()
  Offset position;
  // 是否以画布中心为参考点
  bool center;
  // 是否继承父级样式（比如 ps 的 canvasSize）
  bool inherit;

  /// 边框 borderWidth: 2
  double? borderWidth;

  /// 边框颜色: Colors.blueGrey
  @JsonColorConverter()
  Color? borderColor;

  /// 阴影 BoxShadow(  color: Colors.black.withOpacity(0.2),  blurRadius: 10, offset: const Offset(5, 5),)
  /// 使用 Flutter 原生的 BoxShadow 方便配置颜色、模糊和偏移
  @JsonBoxShadowConverter()
  BoxShadow? shadow;

  /// 将画布尺寸整合进样式
  @JsonSizeConverter()
  Size? canvasSize;

  /// 新增缩放属性
  double scale;

  // 仅供 MyPs 使用
  @JsonEdgeInsetsConverter()
  EdgeInsets? padding;

  // 供节点使用
  @JsonEdgeInsetsConverter()
  EdgeInsets? margin;

  double rotate; // 旋转弧度，默认 0.0

  // --- 新增：渐变属性 ---
  // 用于背景填充的渐变
  @JsonGradientConverter()
  Gradient? backgroundGradient;

  // 用于前景（比如文字颜色或边框颜色）的渐变
  @JsonGradientConverter()
  Gradient? foregroundGradient;

  // 新增文字阴影
  @JsonBoxShadowConverter()
  BoxShadow? textShadow;

  @JsonKey(includeFromJson: false, includeToJson: false)
  ui.Image? backgroundImage; // 背景图片

  // 背景图片适配方式，默认 cover
  @JsonBoxFitConverter()
  BoxFit backgroundFit;

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

  @override
  Map<String, dynamic> toJson() => _$PsStyleToJson(this);
  @override
  Map<String, dynamic> toMap() => toJson();
  @override
  PsStyle fromMap(Map<String, dynamic> map) => PsStyle.fromMap(map);
  factory PsStyle.fromJson(Map<String, dynamic> json) =>
      _$PsStyleFromJson(json);
  factory PsStyle.fromMap(Map<String, dynamic> map) => PsStyle.fromJson(map);
  static PsStyle instanceFromJson(Object? json) {
    if (json is String) return PsStyle.fromJson(jsonDecode(json));
    return PsStyle.fromJson(json as Map<String, dynamic>);
  }

  static String instanceToJson(PsStyle instance) =>
      jsonEncode(instance.toJson());
}

@JsonSerializable()
class PsClass extends DbTypeModel<PsClass> {
  final String name;
  final PsStyle style;
  PsClass({required this.name, required this.style});

  @override
  Map<String, dynamic> toJson() => _$PsClassToJson(this);
  @override
  Map<String, dynamic> toMap() => toJson();
  @override
  PsClass fromMap(Map<String, dynamic> map) => PsClass.fromMap(map);
  factory PsClass.fromJson(Map<String, dynamic> json) =>
      _$PsClassFromJson(json);
  factory PsClass.fromMap(Map<String, dynamic> map) => PsClass.fromJson(map);
  static PsClass instanceFromJson(Object? json) {
    if (json is String) return PsClass.fromJson(jsonDecode(json));
    return PsClass.fromJson(json as Map<String, dynamic>);
  }

  static String instanceToJson(PsClass instance) =>
      jsonEncode(instance.toJson());
}

enum PsNodeType { rect, circle, svg, text, image, line }

@JsonSerializable()
class PsNode extends DbTypeModel<PsNode> {
  final String? tag;

  @JsonListStringConverter()
  final List<String> classes;
  final PsNodeType type;
  final PsStyle style;
  dynamic data;

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

  @override
  Map<String, dynamic> toJson() => _$PsNodeToJson(this);
  @override
  Map<String, dynamic> toMap() => toJson();
  @override
  PsNode fromMap(Map<String, dynamic> map) => PsNode.fromMap(map);
  factory PsNode.fromJson(Map<String, dynamic> json) => _$PsNodeFromJson(json);
  factory PsNode.fromMap(Map<String, dynamic> map) => PsNode.fromJson(map);
  static PsNode instanceFromJson(Object? json) {
    if (json is String) return PsNode.fromJson(jsonDecode(json));
    return PsNode.fromJson(json as Map<String, dynamic>);
  }

  static String instanceToJson(PsNode instance) =>
      jsonEncode(instance.toJson());
}

@JsonSerializable()
class PsMask extends DbTypeModel<PsMask> {
  // 蒙板区域
  @JsonRectConverter()
  final Rect rect;

  final double radius; // 圆角

  // 新增：是否显示调试边框
  @JsonBoolConverter()
  final bool showBorder;

  PsMask({required this.rect, this.radius = 0, this.showBorder = false});
  @override
  Map<String, dynamic> toJson() => _$PsMaskToJson(this);
  @override
  Map<String, dynamic> toMap() => toJson();
  @override
  PsMask fromMap(Map<String, dynamic> map) => PsMask.fromMap(map);
  factory PsMask.fromJson(Map<String, dynamic> json) => _$PsMaskFromJson(json);
  factory PsMask.fromMap(Map<String, dynamic> map) => PsMask.fromJson(map);
  static PsMask instanceFromJson(Object? json) {
    if (json is String) return PsMask.fromJson(jsonDecode(json));
    return PsMask.fromJson(json as Map<String, dynamic>);
  }

  static String instanceToJson(PsMask instance) =>
      jsonEncode(instance.toJson());
}

@JsonSerializable()
class PsLayer extends DbTypeModel<PsLayer> {
  final List<PsNode> nodes; // 图形列表
  final PsMask? mask; // 蒙板

  PsLayer({required this.nodes, this.mask});

  @override
  Map<String, dynamic> toJson() => _$PsLayerToJson(this);
  @override
  Map<String, dynamic> toMap() => toJson();
  @override
  PsLayer fromMap(Map<String, dynamic> map) => PsLayer.fromMap(map);
  factory PsLayer.fromJson(Map<String, dynamic> json) =>
      _$PsLayerFromJson(json);
  factory PsLayer.fromMap(Map<String, dynamic> map) => PsLayer.fromJson(map);
  static PsLayer instanceFromJson(Object? json) {
    if (json is String) return PsLayer.fromJson(jsonDecode(json));
    return PsLayer.fromJson(json as Map<String, dynamic>);
  }

  static String instanceToJson(PsLayer instance) =>
      jsonEncode(instance.toJson());
}
