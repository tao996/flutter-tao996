import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 动画状态的图标
class MyAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final bool isLoading;
  final Color? color;

  const MyAnimatedIcon({
    super.key,
    this.icon = Icons.refresh,
    this.size = 18,
    this.isLoading = false,
    this.color,
  });

  @override
  State<MyAnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<MyAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MyAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.0; // 停止后重置为初始状态
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.isLoading
          ? RotationTransition(
              turns: _controller,
              child: Icon(widget.icon, size: widget.size, color: widget.color),
            )
          : Icon(widget.icon, size: widget.size, color: widget.color),
    );
  }
}

/// 显示图像或图标的组件,优先级：IconData > 本地文件 > Asset 资源
///
/// [assetPath] Assets 中图标路径；
///
/// [filePath] 本地文件系统路径（必须拥有访问权限）, 优先为 SVG 格式（支持 PNG/JPG）；示例 `/Users/name/Downloads/icon.svg`；
class MyIconSvg extends StatelessWidget {
  final String? assetPath;
  final String? filePath;
  final IconData? iconData;
  final double size;
  final Color? color;

  const MyIconSvg({
    super.key,
    this.assetPath,
    this.filePath,
    this.iconData,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 优先级：IconData > 本地文件 > Asset 资源
    if (iconData != null) {
      return Icon(iconData, size: size, color: color);
    }

    final Color finalColor =
        color ?? Theme.of(context).iconTheme.color ?? Colors.black;
    final ColorFilter colorFilter = ColorFilter.mode(
      finalColor,
      BlendMode.srcIn,
    );

    return SizedBox(width: size, height: size, child: _buildSvg(colorFilter));
  }

  Widget _buildSvg(ColorFilter colorFilter) {
    // 1. 如果有本地路径，尝试从文件加载
    if (filePath != null && filePath!.isNotEmpty) {
      final file = File(filePath!);
      // 这里可以使用之前讨论过的 sync 方法快速检查
      if (file.existsSync()) {
        if (filePath!.toLowerCase().endsWith('.svg')) {
          return SvgPicture.file(
            file,
            fit: BoxFit.contain,
            colorFilter: colorFilter,
          );
        }
        return Image.file(
          File(filePath!),
          width: size,
          height: size,
          fit: BoxFit.contain,
          color: color, // 注意：Image 的 color 会覆盖整个图片，通常仅用于纯色图标
        );
      }
    }

    // 2. 如果有 Asset 路径，从资源加载
    if (assetPath != null && assetPath!.isNotEmpty) {
      return SvgPicture.asset(
        assetPath!,
        fit: BoxFit.contain,
        colorFilter: colorFilter,
      );
    }

    // 3. 兜底：返回空占位
    return const SizedBox.shrink();
  }
}
