import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyPainter extends CustomPainter {
  final PsLayer layer;
  final PsStyle psStyle; // 传入 MyPs 的整体样式
  MyPainter(this.layer, this.psStyle);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 坐标系适配：确保逻辑尺寸与物理尺寸一致

    final canvasSize = psStyle.drawSize;
    canvas.scale(
      size.width / canvasSize.width,
      size.height / canvasSize.height,
    );
    // --- 新增：强制画布边界裁切，防止任何元素（包括线头）超出 ---
    canvas.clipRect(Offset.zero & canvasSize);
    // --- 关键修正：绘制画布背景色 ---
    if (psStyle.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = psStyle.backgroundColor!
        ..style = PaintingStyle.fill;
      // 绘制撑满 canvasSize 的矩形
      canvas.drawRect(Offset.zero & canvasSize, backgroundPaint);
    }
    // 2. 处理全局蒙版
    if (layer.mask != null) {
      canvas.clipRRect(
        RRect.fromRectAndRadius(
          layer.mask!.rect,
          Radius.circular(layer.mask!.radius),
        ),
      );
    }

    // 3. 遍历并绘制节点
    for (var node in layer.nodes) {
      _drawNode(canvas, node);
    }
  }

  /// 具体的节点绘制逻辑：处理阴影、填充、内容和边框
  void _drawNode(Canvas canvas, PsNode node) {
    final style = node.style;
    final rect = node.rect; //
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(style.radius ?? 0),
    );

    // --- 1. 绘制阴影 (修正：解决透明背景下的阴影渗透问题) ---
    if (style.shadow != null) {
      canvas.save();
      final Path shadowPath = Path()..addRRect(rrect);

      // 创建一个无限大的外部矩形，并与当前的 rrect 路径取差集
      // 这样 Canvas 就只会渲染 rrect 外部的模糊效果
      final Path clipPath = Path()
        ..addRect(rect.inflate(style.shadow!.blurRadius))
        ..addRRect(rrect)
        ..fillType = PathFillType.evenOdd;

      canvas.clipPath(clipPath);
      canvas.drawPath(shadowPath, style.shadow!.toPaint());
      canvas.restore();
    }

    // --- 2. 准备填充 Paint ---

    final fillColor = style.backgroundColor ?? Colors.transparent;
    final bool shouldFill = fillColor != Colors.transparent;
    Paint? fillPaint;
    if (shouldFill) {
      fillPaint = Paint()
        ..color = fillColor.withOpacity(style.opacity ?? 1.0)
        ..style = PaintingStyle.fill;

      if (node.type == PsNodeType.circle) {
        canvas.drawCircle(rect.center, rect.shortestSide / 2, fillPaint);
      } else {
        canvas.drawRRect(rrect, fillPaint);
      }
    }

    // --- 3. 内容绘制 ---
    switch (node.type) {
      case PsNodeType.line:
        final linePaint = Paint()
          ..color = style.borderColor ?? style.color ?? Colors.black
          ..strokeWidth = style.borderWidth ?? 1.0
          ..strokeCap = StrokeCap
              .round // 让线条两端圆润一点
          ..style = PaintingStyle.stroke;
        // 从 Rect 的左上角画到右下角
        canvas.drawLine(rect.topLeft, rect.bottomRight, linePaint);
        break;
      case PsNodeType.rect:
        if (shouldFill) canvas.drawRRect(rrect, fillPaint!);
        break;
      case PsNodeType.circle:
        if (shouldFill) {
          canvas.drawCircle(rect.center, rect.shortestSide / 2, fillPaint!);
        }
        break;
      case PsNodeType.text:
      case PsNodeType.image:
      case PsNodeType.svg:
        if (node.data is ui.Image) {
          if (shouldFill) {
            canvas.drawRRect(rrect, fillPaint!);
          }
          final img = node.data as ui.Image;
          canvas.drawImageRect(
            img,
            Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
            rect,
            Paint()..color = Colors.white.withOpacity(style.opacity ?? 1.0),
          );
        }
        break;
    }

    // --- 4. 绘制边框 ---
    if (node.type != PsNodeType.line &&
        style.borderWidth != null &&
        style.borderWidth! > 0) {
      final borderPaint = Paint()
        ..color = style.borderColor ?? Colors.black
        ..strokeWidth = style.borderWidth!
        ..style = PaintingStyle.stroke;

      if (node.type == PsNodeType.circle) {
        canvas.drawCircle(rect.center, rect.shortestSide / 2, borderPaint);
      } else {
        canvas.drawRRect(rrect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) => true;
}
