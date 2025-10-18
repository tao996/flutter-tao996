import 'package:flutter/material.dart';

// 消息类型枚举
enum MessageType { info, success, warning, error }

/// 一个通用的提示信息组件，可以根据类型显示不同的颜色和图标。
class MessageBar extends StatelessWidget {
  /// 提示信息文本
  final String message;

  /// 消息类型，默认为 info
  final MessageType type;

  /// 点击关闭按钮的回调
  final VoidCallback? onClose;
  final bool icon;

  const MessageBar(
    this.message, {
    this.icon = true,
    super.key,
    this.onClose,
    this.type = MessageType.info,
  });

  Color _getBackgroundColor(BuildContext context, MessageType type) {
    final colors = Theme.of(context).colorScheme;
    switch (type) {
      case MessageType.info:
        return colors.primary;
      case MessageType.success:
        return colors.secondary;
      case MessageType.warning:

        /// 警告色没有内置
        return Colors.amber.shade700; //.withAlpha(229);
      case MessageType.error:
        return colors.error;
    }
  }

  // 2. 根据背景色获取前景文本/图标颜色
  Color _getForegroundColor(BuildContext context, MessageType type) {
    final colors = Theme.of(context).colorScheme;
    switch (type) {
      case MessageType.info:
        // Primary Color 上的文本颜色
        return colors.onPrimary;
      case MessageType.success:
        // Secondary Color 上的文本颜色
        return colors.onSecondary;
      case MessageType.warning:
        // 警告色前景使用黑色或深灰色确保可读性
        return Colors.black87;
      case MessageType.error:
        // Error Color 上的文本颜色
        return colors.onError;
    }
  }

  IconData _getIcon(MessageType type) {
    switch (type) {
      case MessageType.info:
        return Icons.info_outline;
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = _getForegroundColor(context, type);
    return Material(
      color: Colors.transparent, // 确保背景透明，以便动画正常工作
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
        // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: _decoration(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon) ..._icon(foregroundColor),
            Expanded(child: _text(foregroundColor)),
            if (onClose != null)
              IconButton(
                icon: Icon(Icons.close, color: foregroundColor),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }

  Decoration _decoration(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context, type);
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: backgroundColor.withAlpha(100),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _text(Color foregroundColor) {
    return Text(
      message,
      style: TextStyle(color: foregroundColor, fontSize: 14),
    );
  }

  List<Widget> _icon(Color foregroundColor) {
    return [
      Icon(_getIcon(type), color: foregroundColor),
      const SizedBox(width: 8),
    ];
  }
}
