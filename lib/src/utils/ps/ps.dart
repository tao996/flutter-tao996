/*
* RenderNode (渲染节点): 存储图形数据（位置、大小、资源引用）。
* Mask (蒙板定义): 仅作为一个 Path 或 Alpha 区域。
* Composite (合成器): 遍历节点，按顺序在 saveLayer 的上下文中绘制。
*/
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyPs {
  final PsStyle style;
  final List<PsClass> classes = [];
  final List<PsNode> nodes = [];
  final List<ui.Image> _resources = [];
  late final Size canvasSize;
  PsMask? mask;

  MyPs({this.mask, required this.style}) {
    canvasSize = style.drawSize;
  }

  /// 内部工具：合并样式并注入 canvasSize
  PsStyle _prepareStyle(List<String>? names, PsStyle? inline) {
    PsStyle style = _mergeStyles(names, inline);
    style.canvasSize = canvasSize; // 强制注入当前画布尺寸
    return style;
  }

  Future<MyPs> addTextNode(
    String text, {
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) async {
    PsStyle finalStyle = _prepareStyle(classNames, inlineStyle);

    if (finalStyle.size == null) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: finalStyle.fontSize ?? 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      finalStyle.size = tp.size;
    }

    final img = await tu.draw.renderText(
      text,
      size: finalStyle.size!,
      fontSize: finalStyle.fontSize,
      color: finalStyle.color ?? Colors.black,
    );

    _resources.add(img);
    nodes.add(
      PsNode(type: PsNodeType.text, data: img, style: finalStyle, tag: tag),
    );
    return this;
  }

  /// 添加矩形节点
  MyPs addRectNode({
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) {
    nodes.add(
      PsNode(
        type: PsNodeType.rect,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 添加圆形节点
  MyPs addCircleNode({
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) {
    nodes.add(
      PsNode(
        type: PsNodeType.circle,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 3. 添加图片节点 (位图)
  Future<MyPs> addImageNode(
    ui.Image image, {
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) async {
    PsStyle finalStyle = _mergeStyles(classNames, inlineStyle);
    finalStyle.size ??= Size(image.width.toDouble(), image.height.toDouble());
    _resources.add(image);

    nodes.add(
      PsNode(
        type: PsNodeType.image,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 4. 添加 SVG 节点 (转换为位图以提高混合渲染性能)
  /// 添加 SVG 节点 (带缩放修正)
  Future<MyPs> addSvgNode(
    String svgString, {
    required Size size,
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) async {
    PsStyle finalStyle = _mergeStyles(classNames, inlineStyle);
    finalStyle.size ??= size;
    final img = await tu.draw.renderSvg(svgString, size: finalStyle.size!);
    _resources.add(img);
    nodes.add(
      PsNode(
        type: PsNodeType.svg,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 添加线条节点
  MyPs addLine({
    Offset? from,
    Offset? to,
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) {
    PsStyle finalStyle = _prepareStyle(classNames, inlineStyle);
    double halfWidth = (finalStyle.borderWidth ?? 1.0) / 2;

    if (from != null && to != null) {
      // 自动计算缩进：让线条的边缘刚好贴在画布边缘，而不是中心点贴边
      // 这里我们简单处理，直接微调 position 和 size
      finalStyle.position = Offset(from.dx + halfWidth, from.dy + halfWidth);
      finalStyle.size = Size(
        (to.dx - from.dx) - (halfWidth * 2),
        (to.dy - from.dy) - (halfWidth * 2),
      );
      finalStyle.center = false;
    } else if (finalStyle.inherit) {
      // 如果是继承画布，也要缩进
      finalStyle.position = Offset(halfWidth, halfWidth);
      finalStyle.size = Size(
        canvasSize.width - (halfWidth * 2),
        canvasSize.height - (halfWidth * 2),
      );
    }

    nodes.add(
      PsNode(type: PsNodeType.line, data: null, style: finalStyle, tag: tag),
    );
    return this;
  }

  /// 根据 Tag 修改位置
  void move(String tag, Offset offset) {
    for (var node in nodes) {
      if (node.tag == tag) {
        node.style.position = (node.style.position ?? Offset.zero) + offset;
      }
    }
  }

  /// 样式合并逻辑
  PsStyle _mergeStyles(List<String>? names, PsStyle? inline) {
    PsStyle base = PsStyle();
    if (names != null) {
      for (var name in names) {
        final matched = classes.firstWhere(
          (c) => c.name == name,
          orElse: () => PsClass(name: '', style: PsStyle()),
        );
        base = base.copyWith(matched.style);
      }
    }
    return base.copyWith(inline);
  }

  /// 资源释放：务必在 Widget 的 dispose 中调用
  void onDestroy() {
    for (var img in _resources) {
      img.dispose();
    }
    _resources.clear();
    nodes.clear();
  }

  /// 构建最终渲染组件
  Widget build() {
    return SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: CustomPaint(
        painter: MyPainter(PsLayer(nodes: nodes, mask: mask), style),
        size: Size.infinite,
      ),
    );
  }
}
