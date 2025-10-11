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
    switch (type) {
      case MessageType.info:
        return Colors.blue.withAlpha(229); // 0.9 * 255 = 229
      case MessageType.success:
        return Colors.green.withAlpha(229);
      case MessageType.warning:
        return Colors.amber.shade800; //.withAlpha(229);
      case MessageType.error:
        return Colors.red.withAlpha(229);
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
    return Material(
      color: Colors.transparent, // 确保背景透明，以便动画正常工作
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
        // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: _decoration(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon) ..._icon(),
            Expanded(child: _text()),
            if (onClose != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
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
      // boxShadow: [
      //   BoxShadow(
      //     color: backgroundColor.withAlpha(125),
      //     blurRadius: 10,
      //     offset: const Offset(0, 4),
      //   ),
      // ],
    );
  }

  Widget _text() {
    return Text(message, style: TextStyle(color: Colors.white, fontSize: 14));
  }

  List<Widget> _icon() {
    return [
      Icon(_getIcon(type), color: Colors.white),
      const SizedBox(width: 8),
    ];
  }
}
