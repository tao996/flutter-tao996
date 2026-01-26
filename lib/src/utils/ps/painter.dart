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

  void _drawNode(Canvas canvas, PsNode node) {
    final style = node.style;
    final rect = node.rect;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(style.radius ?? 0),
    );

    // --- 1. 坐标变换 (旋转 & 缩放) ---
    final bool hasScale = style.scale != 1.0;
    final bool hasRotate = style.rotate != 0.0;

    if (hasScale || hasRotate) {
      canvas.save();
      final center = rect.center;
      canvas.translate(center.dx, center.dy);
      if (hasRotate) canvas.rotate(style.rotate);
      if (hasScale) canvas.scale(style.scale);
      canvas.translate(-center.dx, -center.dy);
    }

    // --- 2. 绘制阴影 (镂空处理，防止渗透) ---
    if (style.shadow != null) {
      canvas.save();
      final Path shadowPath = Path()..addRRect(rrect);
      final Path clipPath = Path()
        ..addRect(rect.inflate(style.shadow!.blurRadius))
        ..addRRect(rrect)
        ..fillType = PathFillType.evenOdd;

      canvas.clipPath(clipPath);
      canvas.drawPath(shadowPath, style.shadow!.toPaint());
      canvas.restore();
    }

    // --- 3. 背景填充 (支持颜色或渐变) ---
    final bool hasBgGradient = style.backgroundGradient != null;
    final bool hasBgColor =
        style.backgroundColor != null &&
        style.backgroundColor != Colors.transparent;

    if (hasBgGradient || hasBgColor) {
      final fillPaint = Paint()..style = PaintingStyle.fill;

      if (hasBgGradient) {
        fillPaint.shader = style.backgroundGradient!.createShader(rect);
      } else {
        fillPaint.color = style.backgroundColor!.withOpacity(
          style.opacity ?? 1.0,
        );
      }

      if (node.type == PsNodeType.circle) {
        canvas.drawCircle(rect.center, rect.shortestSide / 2, fillPaint);
      } else {
        canvas.drawRRect(rrect, fillPaint);
      }
    }

    // --- 4. 内容绘制 (Line / Text / Image) ---
    switch (node.type) {
      case PsNodeType.line:
        final linePaint = Paint()
          ..strokeWidth = style.borderWidth ?? 1.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // 线条优先使用前景渐变，其次是边框色，最后是普通色
        if (style.foregroundGradient != null) {
          linePaint.shader = style.foregroundGradient!.createShader(rect);
        } else {
          linePaint.color = (style.borderColor ?? style.color ?? Colors.black)
              .withOpacity(style.opacity ?? 1.0);
        }
        canvas.drawLine(rect.topLeft, rect.bottomRight, linePaint);
        break;

      case PsNodeType.text:
        if (node.data is ui.Image) {
          final img = node.data as ui.Image;
          final rect = node.rect;

          // --- 1. 绘制文字阴影 (如果存在) ---
          if (style.textShadow != null) {
            final shadow = style.textShadow!;
            final shadowPaint = Paint()
              ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcIn)
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                shadow.blurRadius,
              );

            // 根据 shadow.offset 进行偏移绘制
            canvas.drawImageRect(
              img,
              Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
              rect.shift(shadow.offset),
              shadowPaint,
            );
          }

          // --- 2. 绘制渐变或普通文字 ---
          if (style.foregroundGradient != null) {
            canvas.saveLayer(rect, Paint());
            canvas.drawImageRect(
              img,
              Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
              rect,
              Paint(),
            );

            final gradientPaint = Paint()
              ..shader = style.foregroundGradient!.createShader(rect)
              ..blendMode = BlendMode.srcIn;

            canvas.drawRect(rect, gradientPaint);
            canvas.restore();
          } else {
            final Paint textPaint = Paint()
              ..colorFilter = ColorFilter.mode(
                (style.color ?? Colors.black).withOpacity(style.opacity ?? 1.0),
                BlendMode.srcIn,
              );
            canvas.drawImageRect(
              img,
              Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
              rect,
              textPaint,
            );
          }
        }
        break;

      case PsNodeType.image:
      case PsNodeType.svg:
        if (node.data is ui.Image) {
          final img = node.data as ui.Image;
          canvas.drawImageRect(
            img,
            Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
            rect,
            Paint()..color = Colors.white.withOpacity(style.opacity ?? 1.0),
          );
        }
        break;

      case PsNodeType.rect:
      case PsNodeType.circle:
        // 已经在背景填充步骤完成
        break;
    }

    // --- 5. 绘制边框 (支持渐变) ---
    if (node.type != PsNodeType.line &&
        style.borderWidth != null &&
        style.borderWidth! > 0) {
      final borderPaint = Paint()
        ..strokeWidth = style.borderWidth!
        ..style = PaintingStyle.stroke;

      if (style.foregroundGradient != null) {
        borderPaint.shader = style.foregroundGradient!.createShader(rect);
      } else {
        borderPaint.color = (style.borderColor ?? Colors.black).withOpacity(
          style.opacity ?? 1.0,
        );
      }

      if (node.type == PsNodeType.circle) {
        canvas.drawCircle(rect.center, rect.shortestSide / 2, borderPaint);
      } else {
        canvas.drawRRect(rrect, borderPaint);
      }
    }

    // --- 6. 恢复变换状态 ---
    if (hasScale || hasRotate) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) => true;
}
