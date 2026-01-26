/*
* RenderNode (渲染节点): 存储图形数据（位置、大小、资源引用）。
* Mask (蒙板定义): 仅作为一个 Path 或 Alpha 区域。
* Composite (合成器): 遍历节点，按顺序在 saveLayer 的上下文中绘制。
*/
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyPs extends ChangeNotifier {
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
    style.margin =
        (this.style.padding ?? EdgeInsets.zero) +
        (inline?.margin ?? EdgeInsets.zero);
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
  ///
  /// ```dart
  /// // 如何在 Rx 中应用，在 Controller 中
  /// var scaleFactor = 1.0.obs;
  /// // 在 UI 中
  /// myPs.build(),
  /// // 监听 Rx 变化并同步给 MyPs
  /// once(scaleFactor, (val) {
  ///   myPs.scale(val, tag: 'logo');
  /// });
  /// ```
  Widget build() {
    return ListenableBuilder(
      listenable: this, // 监听 myPs 的变化
      builder: (context, child) {
        // 每当 notifyListeners 被调用，这里都会重新执行
        return SizedBox(
          width: canvasSize.width,
          height: canvasSize.height,
          child: CustomPaint(
            painter: MyPainter(PsLayer(nodes: nodes, mask: mask), style),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// 缩放功能
  void scale(double factor, {String? tag}) {
    bool changed = false;
    if (tag == null) {
      for (var node in nodes) {
        node.style.scale = factor;
        changed = true;
      }
    } else {
      for (var node in nodes) {
        if (node.tag == tag) {
          node.style.scale = factor;
          changed = true;
        }
      }
    }

    // 2. 关键：通知 UI 刷新
    if (changed) notifyListeners();
  }

  // move 方法也需要加上
  void move(String tag, Offset offset) {
    for (var node in nodes) {
      if (node.tag == tag) {
        node.style.position = (node.style.position) + offset;
        notifyListeners(); // 刷新
      }
    }
  }

  /// 旋转功能：angle 为角度（0-360）
  void rotate(double angle, {String? tag}) {
    final double radians = angle * (math.pi / 180); // 角度转弧度
    bool changed = false;

    if (tag == null) {
      for (var node in nodes) {
        node.style.rotate = radians;
        changed = true;
      }
    } else {
      for (var node in nodes) {
        if (node.tag == tag) {
          node.style.rotate = radians;
          changed = true;
        }
      }
    }

    if (changed) notifyListeners();
  }
}
