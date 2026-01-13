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

class MyIconSvg extends StatelessWidget {
  final String? iconPath;
  final IconData? iconData;
  final double size;
  final Color? color;

  const MyIconSvg({
    super.key,
    this.iconPath,
    this.iconData,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return iconData != null
        ? Icon(iconData, size: size, color: color)
        : SizedBox(
            width: size, // 🚀 修改点：使用 SizedBox 封装
            height: size,
            child: SvgPicture.asset(
              iconPath!,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                color ?? Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          );
  }
}
