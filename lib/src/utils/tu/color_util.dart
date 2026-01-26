import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class ColorUtil {
  const ColorUtil();

  /// 完全透明
  bool isFullyTransparent(Color color) => color.a == 0.0;

  /// 透明
  bool isTransparent(Color color) => color.a < 1.0;

  /// 创建一个 8x8 的棋盘背景
  Widget buildCheckerboard({double squareSize = 8}) {
    return CustomPaint(painter: CheckerboardPainter(squareSize: squareSize));
  }

  /// 代表成功的颜色，通常用于表示成功、完成、通过等操作
  Color success() => tu.colorScheme.secondary;

  /// 代表失败的颜色，通常用于表示失败、错误、拒绝等操作
  Color error() => tu.colorScheme.error;
  Color danger() => tu.colorScheme.error;

  /// 高亮或信息提示
  Color info() => tu.colorScheme.primary;
  Color warning() => tu.colorScheme.tertiary;
  Color text(double opacity) =>
      tu.colorScheme.onSurface.withAlpha((255 * opacity).toInt());

  /// Color c1 = hexToColor("#fef7ff", opacity: 0.5);
  Color hexToColor(String hexCode, {double opacity = 1.0}) {
    // 1. 去掉 # 号
    String cleanHex = hexCode.replaceAll('#', '');

    // 2. 将十六进制转为整数
    int val = int.parse(cleanHex, radix: 16);

    // 3. 使用 withOpacity 动态设置透明度
    // 注意：0xFF000000 是为了确保它是一个不透明的底色，然后再应用 opacity
    return Color(val | 0xFF000000).withAlpha((opacity * 255).toInt());
  }

  /// Color c2 = rgbToColor("255, 247, 255", opacity: 0.8);
  Color rgbToColor(String rgbString, {double opacity = 1.0}) {
    // 1. 切割并转为整数列表
    List<int> parts = rgbString
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();

    if (parts.length != 3) return Colors.black; // 兜底处理

    // 2. 构造颜色
    // 现代写法 (3.27+)：Color.from(r: ..., g: ..., b: ..., a: ...)
    return Color.from(
      red: parts[0] / 255,
      green: parts[1] / 255,
      blue: parts[2] / 255,
      alpha: opacity,
    );
  }

  Color parseToColor(String input, {double opacity = 1.0}) {
    try {
      if (input.contains('#')) {
        return hexToColor(input, opacity: opacity);
      } else if (input.contains(',')) {
        return rgbToColor(input, opacity: opacity);
      }
    } catch (e) {
      debugPrint("解析颜色失败: $e");
    }
    return Colors.transparent;
  }
}

class CheckerboardPainter extends CustomPainter {
  final double squareSize;
  CheckerboardPainter({this.squareSize = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.white;
    final paint2 = Paint()..color = const Color(0xFFE0E0E0); // 浅灰色

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        // 交替绘制颜色
        final paint =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0
            ? paint1
            : paint2;
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
