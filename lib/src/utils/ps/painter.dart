import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyPainter extends CustomPainter {
  final MyPs ps; // 传入 MyPs 的整体样式
  final bool enableHitTest; // 新增：是否开启点击检测支持
  MyPainter(
    this.ps, {
    this.enableHitTest = false, // 默认关闭，仅在交互界面开启
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 坐标系适配：确保逻辑尺寸与物理尺寸一致

    final canvasSize = ps.style.drawSize;
    canvas.scale(
      size.width / canvasSize.width,
      size.height / canvasSize.height,
    );
    // --- 新增：强制画布边界裁切，防止任何元素（包括线头）超出 ---
    canvas.clipRect(Offset.zero & canvasSize);
    // --- 关键修正：绘制画布背景色 ---
    if (ps.style.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = ps.style.backgroundColor!
        ..style = PaintingStyle.fill;
      // 绘制撑满 canvasSize 的矩形
      canvas.drawRect(Offset.zero & canvasSize, backgroundPaint);
    }
    // 2. 处理全局蒙版
    if (ps.mask != null) {
      canvas.clipRRect(
        RRect.fromRectAndRadius(
          ps.mask!.rect,
          Radius.circular(ps.mask!.radius),
        ),
      );
    }

    // 3. 遍历并绘制节点
    // 1. 获取排序后的节点列表 (稳定排序)
    // 增加 zIndex 支持
    final sortedNodes = List<PsNode>.from(ps.nodes);

    // 按照 zIndex 排序
    sortedNodes.sort((a, b) {
      int cmp = (a.style.zIndex).compareTo(b.style.zIndex);
      if (cmp != 0) return cmp;
      // 如果 zIndex 相同，则维持原 List 中的顺序 (即谁先加进来谁在下面)
      return ps.nodes.indexOf(a).compareTo(ps.nodes.indexOf(b));
    });
    for (var node in sortedNodes) {
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
    // --- 3. 背景填充 (包含颜色、渐变、背景图片) ---
    final bool hasBgGradient = style.backgroundGradient != null;
    final bool hasBgColor =
        style.backgroundColor != null &&
        style.backgroundColor != Colors.transparent;
    final bool hasBgImage = style.backgroundImage != null;
    final bool hasBlur = style.blur != null && style.blur! > 0;

    if (hasBgGradient || hasBgColor || hasBgImage || hasBlur) {
      canvas.save(); // 开启局部状态

      // 【统一裁切口】只要定义好这个“洞”的形状，里面的填充逻辑就变简单了
      if (node.type == PsNodeType.circle) {
        canvas.clipPath(Path()..addOval(rect));
      } else {
        canvas.clipRRect(rrect);
      }

      // --- 新增：毛玻璃模糊逻辑 ---
      if (hasBlur) {
        // 开启一个带有模糊滤镜的图层
        canvas.saveLayer(
          rect,
          Paint()
            ..imageFilter = ui.ImageFilter.blur(
              sigmaX: style.blur!,
              sigmaY: style.blur!,
            ),
        );
      }

      // A. 填充底色/渐变 (直接画 Rect 即可，会被 clip 裁切成形状)
      if (hasBgGradient || hasBgColor) {
        final fillPaint = Paint()..style = PaintingStyle.fill;
        if (hasBgGradient) {
          fillPaint.shader = style.backgroundGradient!.createShader(rect);
        } else {
          fillPaint.color = style.backgroundColor!.withOpacity(
            style.opacity ?? 1.0,
          );
        }
        canvas.drawRect(rect, fillPaint);
      }

      // B. 填充背景图
      if (hasBgImage) {
        paintImage(
          canvas: canvas,
          rect: rect,
          image: style.backgroundImage!,
          fit: style.backgroundFit,
          opacity: style.opacity ?? 1.0,
          alignment: Alignment.center,
        );
      }
      if (hasBlur) {
        canvas.restore(); // 结束模糊图层
      }
      canvas.restore(); // 恢复状态，关闭裁切
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
      // 因为边框是画在形状“边缘”上的线，而不是填满内部
      if (node.type == PsNodeType.circle) {
        canvas.drawCircle(rect.center, rect.shortestSide / 2, borderPaint);
      } else {
        canvas.drawRRect(rrect, borderPaint);
      }
    }
    if (enableHitTest &&
        ps.selectedTag != null &&
        ps.selectedTag!.isNotEmpty &&
        ps.selectedTag == node.tag) {
      _drawSelectionBox(canvas, node, ps.dashOffset);
    }

    // --- 6. 恢复变换状态 ---
    if (hasScale || hasRotate) {
      canvas.restore();
    }
  }

  void _drawSelectionBox(Canvas canvas, PsNode node, double dashOffset) {
    final rect = node.rect.inflate(4.0); // 稍微比节点大一点点
    final style = node.style;

    // 1. 准备虚线画笔
    final Paint dashPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 2. 创建路径（考虑圆角）
    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular((style.radius ?? 0) + 4)),
    );

    // 3. 绘制虚线（核心逻辑）
    final double dashWidth = 5.0; // 实线长度
    final double dashSpace = 5.0; // 间隔长度

    final Path dashPath = Path();
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = dashOffset % (dashWidth + dashSpace); // 应用偏移量实现动态效果
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashPaint);

    // 4. 可选：在四个角画小手柄
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint dotBorder = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke;
    for (var offset in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      canvas.drawCircle(offset, 4, dotPaint);
      canvas.drawCircle(offset, 4, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) => true;
}
