import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

abstract class IMessageService extends IDebugMessageService {
  // 操作确认
  Future<bool?> confirm({
    String? title,
    String? content,
    String? cancelText,
    String? confirmText,
    void Function()? yes,
    void Function()? no,
  });

  // 删除确认
  Future<bool?> deleteConfirm(String title, [void Function()? yes]);

  void toast(String message);

  /// 成功提示，如果使用 [snackBar]，则不会有 Future 效果，你需要提前调用 Get.back();
  @override
  Future<void> success(
    String message, {
    Duration? duration = const Duration(seconds: 3),
    double offsetY = -0.2, // 核心：向上偏移（默认比正中央上移 20% 屏幕高度
    bool snackBar = false,
  });

  /// 错误提示，如果使用 [snackBar]，则不会有 Future 效果
  @override
  Future<void> error(
    String message, {
    Duration? duration = const Duration(seconds: 4),
    double offsetY = -0.2, // 核心：向上偏移（默认比正中央上移 20% 屏幕高度
    bool snackBar = false,
  });
}

class MessageService implements IMessageService {
  @override
  Future<bool?> confirm({
    String? title,
    String? content,
    String? cancelText,
    String? confirmText,
    void Function()? yes,
    void Function()? no,
  }) async {
    return Get.dialog(
      AlertDialog(
        icon: title == null ? null : const Icon(Icons.info),
        title: title == null ? null : Text(title),
        content: content == null ? null : Text(content),
        actions: [
          TextButton(
            onPressed: () {
              no?.call();
              Get.back(result: false);
            },
            child: Text((cancelText ?? 'cancel').tr),
          ),
          ElevatedButton(
            onPressed: () {
              yes?.call();
              Get.back(result: true);
            },
            child: Text((confirmText ?? 'confirm').tr),
          ),
        ],
      ),
    );
  }

  @override
  Future<bool?> deleteConfirm(String title, [void Function()? yes]) async {
    return Get.dialog(
      AlertDialog(
        title: Text('deleteConfirmTitle'.tr),
        content: Text('deleteConfirmContent'.trParams({'title': title})),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(result: true); // 必须提前关闭
              yes?.call();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  @override
  void toast(
    String message, {
    Duration duration = const Duration(seconds: 3),
    double offsetY = -0.2, // 核心：向上偏移（默认比正中央上移 20% 屏幕高度
    VoidCallback? onClose,
  }) async {
    if (message.startsWith('DioException')) {
      message = message.substring(message.lastIndexOf(':') + 1).trim();
    }
    // 显示成功 Toast（居中弹窗，无 SnackBar 悬浮）
    BotToast.showCustomText(
      // 自定义 Toast 内容（图标+文字）
      toastBuilder: (cancelFunc) => _buildToastContent(message: message),
      align: Alignment(0, offsetY),
      // x=0（水平居中），y=offsetY（垂直偏移）
      // 显示时长
      duration: duration,
      // 点击空白处是否关闭（可选，false 表示仅自动关闭）
      clickClose: true,
    );
  }

  /// 私有方法：构建 Toast 通用样式（避免重复代码）
  Widget _buildToastContent({
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
  }) {
    // 限制最大宽度，确保整体偏正方形
    final maxWidth = MediaQuery.of(Get.context!).size.width * 0.55;

    return Container(
      // 正方形比例约束
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: 110,
        minHeight: 110,
      ),
      decoration: BoxDecoration(
        // 常规浅色背景
        color: Colors.white,
        // 轻微圆角
        borderRadius: BorderRadius.circular(10),
        // 柔和阴影
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // 内边距适配垂直布局
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      // 垂直布局：图标在上，文字在下
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 32, // 适中的图标大小
              color: iconColor ?? Colors.grey[700], // 图标默认深灰色
            ),
            const SizedBox(height: 14), // 图标与文字间距
          ],
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: textColor ?? Colors.grey[800], // 文字默认深灰色
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center, // 文字居中
          ),
        ],
      ),
    );
  }



  @override
  // 使用 BotToast 显示成功提示，自带动画结束回调
  Future<void> success(
    String message, {
    Duration? duration = const Duration(seconds: 3),
    double offsetY = -0.2, // 核心：向上偏移（默认比正中央上移 20% 屏幕高度
    bool snackBar = false,
    VoidCallback? onClose,
  }) async {
    if (snackBar) {
      Get.snackbar(
        'success'.tr,
        message,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        duration: duration,
        icon: Icon(Icons.check_circle_outline, color: Colors.green),
        onTap: (snack) {
          Get.back();
        },
      );
      return;
    }
    final completer = Completer<void>();

    // 显示成功 Toast（居中弹窗，无 SnackBar 悬浮）
    BotToast.showCustomText(
      // 自定义 Toast 内容（图标+文字）
      toastBuilder: (cancelFunc) => _buildToastContent(
        message: message,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        // textColor: Colors.green[800]!,
      ),
      align: Alignment(0, offsetY),
      // x=0（水平居中），y=offsetY（垂直偏移）
      // 显示时长
      duration: duration,
      // 点击空白处是否关闭（可选，false 表示仅自动关闭）
      clickClose: false,
      // Toast 关闭后触发（包括自动关闭/手动关闭）
      onClose: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    // 等待 Toast 关闭（外部可通过 await 等待）
    await completer.future;
  }

  @override
  Future<void> error(
    String message, {
    Duration? duration = const Duration(seconds: 4),
    double offsetY = -0.2, // 统一向上偏移，保持样式一致
    bool snackBar = false,
  }) async {
    if (snackBar) {
      Get.snackbar(
        'failed'.tr,
        message,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        duration: duration,
        icon: Icon(Icons.error_outline, color: Colors.red),
        colorText: Colors.red[800],
        mainButton: TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('close'.tr),
        ),
        onTap: (snack) {
          Get.back();
        },
      );
      return;
    }
    final completer = Completer<void>();

    // 显示错误 Toast（居中弹窗，无 SnackBar 悬浮）
    BotToast.showCustomText(
      toastBuilder: (cancelFunc) => _buildToastContent(
        message: message,
        icon: Icons.error_outline,
        iconColor: Colors.red,
        textColor: Colors.red[800]!,
      ),
      align: Alignment(0, offsetY),
      // 与成功提示保持相同偏移
      duration: duration,
      clickClose: true,
      onClose: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    await completer.future;
    return;
  }
}
