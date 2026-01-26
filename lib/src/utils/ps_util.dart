/*
* RenderNode (渲染节点): 存储图形数据（位置、大小、资源引用）。
* Mask (蒙板定义): 仅作为一个 Path 或 Alpha 区域。
* Composite (合成器): 遍历节点，按顺序在 saveLayer 的上下文中绘制。
*/
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

/*
// 仅修改属性
// 如果只是想移动位置（修改 position）或改变透明度（修改 style）
void moveNode() {
  setState(() {
    // 假设我们要移动第一个节点
    final firstNode = testLayer!.nodes[0];
    
    // 直接替换列表中的节点，由于 data (ui.Image) 没变，不需要 dispose
    testLayer!.nodes[0] = PsNode(
      type: firstNode.type,
      size: firstNode.size,
      position: firstNode.position + const Offset(10, 10), // 每一帧移动 10 像素
      radius: firstNode.radius,
      data: firstNode.data, // 复用之前的 ui.Image
      style: firstNode.style,
    );
  });
}

// 修改数据并更新
// 当你需要修改数据（例如改变某个节点的位置、颜色，或替换文字）时：
void updateLayer() async {
  // 1. 如果需要生成新的 ui.Image 资源
  final newTextImage = await const DrawUtil().renderText(
    "Updated!", 
    size: const Size(200, 100),
    color: Colors.red,
  );

  // 2. 释放旧资源 (非常重要，防止内存泄漏)
  for (var node in testLayer!.nodes) {
    if (node.data is ui.Image) {
      (node.data as ui.Image).dispose();
    }
  }

  // 3. 构建新的 Layer 并通知 UI
  setState(() {
    testLayer = MyLayer(
      mask: PsMask(rect: const Rect.fromLTWH(0, 0, 400, 400), radius: 20),
      nodes: [
        PsNode(
          type: PsNodeType.text,
          size: const Size(200, 100),
          position: const Offset(50, 50), // 修改了位置
          radius: 0,
          data: newTextImage,
        ),
      ],
    );
  });
}
*/
class PsUtil {
  const PsUtil();
  CustomPaint renderLayer(PsLayer layer) {
    return CustomPaint(painter: MyPainter(layer));
  }

  /// 创建一个文字节点
  ///
  /// [text] 文本内容
  /// [position] 节点在画布上的起始坐标（左上角）
  /// [size] 极其重要：定义了文字的“排版容器”大小。
  /// 用于实现多行排版或自动折行；如果为 null 或 Size.zero 则自动计算文字实际尺寸
  /// [radius] 定义了该文字容器的“圆角裁剪”半径。制作“胶囊文字”或“圆角背景”,在 style['color'] 时可用
  Future<PsNode> textNode(
    String text, {
    required Offset position,
    Size? size,
    Color color = Colors.black,
    Color? backgroundColor,
    double? fontSize,
    FontWeight fontWeight = FontWeight.normal,
    double opacity = 1.0,
    double radius = 0,
  }) async {
    // 1. 预计算文字实际需要的物理尺寸
    final textStyle = TextStyle(
      fontSize: fontSize ?? 20,
      fontWeight: fontWeight,
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // 2. 如果没有指定 size，则使用文字的实际布局尺寸 (贴边关键)
    final finalSize = size ?? Size(tp.width, tp.height);
    // 3. 调用 DrawUtil 生成 GPU 图片
    // 注意：这里需要修改 DrawUtil 逻辑，确保它不再居中，而是从 (0,0) 开始画
    final ui.Image textImage = await tu.draw.renderText(
      text,
      size: finalSize, // 传入计算出的精确尺寸
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      // 这里的 DrawUtil 需要确保 offset 是 Offset.zero 才能贴边
    );

    return PsNode(
      type: PsNodeType.text,
      size: finalSize,
      position: position,
      radius: radius,
      data: textImage,
      style: {'opacity': opacity, 'backgroundColor': backgroundColor},
    );
  }
}

class PsClass {}

class PsStyle {}

enum PsNodeType { rect, circle, svg, text, image }

class PsNode {
  final PsNodeType type; // Rect, Circle, SVG, Text, Image
  final Size size; // 大小
  final Offset position; // 世界坐标
  final double radius; // 圆角
  final dynamic data; // 图片对象、SVG字符串或文字内容
  final Map<String, dynamic>? style; // 颜色、缩放等

  PsNode({
    required this.type,
    required this.size,
    required this.position,
    required this.radius,
    required this.data,
    this.style,
  });

  Rect get rect => position & size;

  // 在 PsNode 中添加
  PsNode move(Offset newPos) {
    return PsNode(
      type: type,
      size: size,
      position: newPos,
      radius: radius,
      data: data,
      style: style,
    );
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

  CustomPaint draw() {
    return tu.ps.renderLayer(this);
  }
}

class MyPainter extends CustomPainter {
  final PsLayer layer;
  MyPainter(this.layer);

  @override
  void paint(Canvas canvas, Size size) {
    // 调用我们封装的 paintLayer
    _paintLayer(canvas, layer);
  }

  void _paintLayer(Canvas canvas, PsLayer layer) {
    canvas.save();

    // --- 1. 处理蒙板 ---
    RRect? maskRRect;
    if (layer.mask != null) {
      maskRRect = RRect.fromRectAndRadius(
        layer.mask!.rect,
        Radius.circular(layer.mask!.radius),
      );
      // 开启抗锯齿裁剪
      canvas.clipRRect(maskRRect, doAntiAlias: true);
    }

    // --- 2. 遍历渲染节点 ---
    for (final node in layer.nodes) {
      final Rect destRect = node.rect; // 使用你定义的 get rect

      // --- 新增：绘制节点背景 (常用于文字或容器) ---
      if (node.style?.containsKey('backgroundColor') == true &&
          node.style!['backgroundColor'] != null) {
        final bgPaint = Paint()
          ..color = (node.style!['backgroundColor'] as Color).withOpacity(
            node.style?['opacity'] ?? 1.0,
          )
          ..style = PaintingStyle.fill;

        // 背景也需要遵循节点的圆角属性
        if (node.radius > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(destRect, Radius.circular(node.radius)),
            bgPaint,
          );
        } else {
          canvas.drawRect(destRect, bgPaint);
        }
      }

      // A. 基础矩形 (Rect)
      if (node.type == PsNodeType.rect && node.data == null) {
        final paint = Paint()..color = node.style?['color'] ?? Colors.black;
        if (node.radius > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(destRect, Radius.circular(node.radius)),
            paint,
          );
        } else {
          canvas.drawRect(destRect, paint);
        }
      }
      // B. 基础圆形 (Circle)
      else if (node.type == PsNodeType.circle && node.data == null) {
        final paint = Paint()..color = node.style?['color'] ?? Colors.black;
        final radius = node.size.shortestSide / 2;
        canvas.drawCircle(
          node.position + Offset(radius, radius),
          radius,
          paint,
        );
      }
      // C. 图像类节点 (文字图片等)
      else if (node.data is ui.Image) {
        final ui.Image img = node.data;
        final paint = Paint()
          ..isAntiAlias = true
          ..filterQuality = ui.FilterQuality.medium;

        if (node.style?.containsKey('opacity') == true) {
          paint.color = Colors.white.withOpacity(node.style!['opacity']);
        }

        if (node.radius > 0) {
          canvas.save();
          canvas.clipRRect(
            RRect.fromRectAndRadius(destRect, Radius.circular(node.radius)),
            doAntiAlias: true,
          );
          canvas.drawImageRect(
            img,
            Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
            destRect,
            paint,
          );
          canvas.restore();
        } else {
          canvas.drawImageRect(
            img,
            Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
            destRect,
            paint,
          );
        }
      }
    }

    // 3. 关键：在 restore 之前绘制调试边框
    // 此时 Canvas 还在 clip 状态内，如果边框刚好在边缘，可能会被切掉一半
    // 所以我们可以稍微处理一下 Paint 逻辑
    if (layer.mask != null && layer.mask!.showBorder) {
      final borderPaint = Paint()
        ..color = Colors.red
            .withRed(200) // 调试用红色
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // 绘制边框线
      canvas.drawRRect(maskRRect!, borderPaint);

      // 辅助线：画一个对角线，确认蒙板区域
      canvas.drawLine(
        layer.mask!.rect.topLeft,
        layer.mask!.rect.bottomRight,
        borderPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
