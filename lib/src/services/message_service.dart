import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future<void> alert(String title, {String? content, Widget? icon});

  /// 删除确认
  /// [textIsContent] 为 true 时，[text] 为内容，否则为标题
  Future<bool?> deleteConfirm(
    String text,
    void Function() yes, {
    bool textIsContent = false,
  });

  void toast(String message);

  SnackbarController snackbar(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    bool? successIcon,
    int seconds = 3,
  });

  /// 成功提示，提前调用 Get.back() 后再调用 [success]
  @override
  void success(String message, {bool snackBar = false});

  /// 错误提示
  @override
  void error(String message, {bool snackBar = false});
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
        icon: const Icon(Icons.info),
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
  Future<void> alert(String title, {String? content, Widget? icon}) {
    return Get.dialog(
      AlertDialog(
        icon: icon,
        title: Text(title),
        content: content == null ? null : Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Future<bool?> deleteConfirm(
    String text,
    void Function() yes, {
    bool textIsContent = false,
  }) async {
    return Get.dialog(
      AlertDialog(
        title: Text('deleteConfirmTitle'.tr),
        content: Text(
          textIsContent
              ? text
              : 'deleteConfirmContent'.trParams({'title': text}),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tu.colorScheme.error, // 使用 Error Color 强调删除操作
              foregroundColor: tu.colorScheme.onError,
            ),
            onPressed: () async {
              Get.back(result: true); // 必须提前关闭
              yes.call();
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
    Color? textColor,
    String? title,
    bool? successIcon,
  }) {
    if (message.startsWith('DioException')) {
      message = message.substring(message.lastIndexOf(':') + 1).trim();
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      snackbar(
        title ?? 'detail'.tr,
        message,
        successIcon: successIcon,
        colorText: textColor,
      );
      return;
    }
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, textColor: tu.colorScheme.onSurface);
  }

  @override
  SnackbarController snackbar(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.TOP,
    bool? successIcon,
    int seconds = 3,
    Color? colorText,
  }) {
    return Get.snackbar(
      title,
      colorText: colorText,
      message,
      snackPosition: snackPosition,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      duration: seconds == 0 ? null : Duration(seconds: seconds),
      icon: successIcon == null
          ? null
          : (successIcon
                ? Icon(Icons.check_outlined, color: MyColor.success())
                : Icon(Icons.close_outlined, color: MyColor.error())),
      onTap: (snack) {
        Get.back();
      },
    );
  }

  @override
  void success(String message, {bool snackBar = false}) {
    if (snackBar) {
      snackbar('success'.tr, message, successIcon: true);
      return;
    }
    toast(
      message,
      textColor: MyColor.success(),
      title: 'success'.tr,
      successIcon: true,
    );
  }

  @override
  void error(
    String message, {
    Duration? duration = const Duration(seconds: 4),
    double offsetY = -0.2, // 统一向上偏移，保持样式一致
    bool snackBar = false,
  }) {
    if (snackBar) {
      snackbar('error'.tr, message, successIcon: false);
      return;
    }
    toast(
      message,
      textColor: MyColor.error(),
      title: 'error'.tr,
      successIcon: false,
    );
  }
}
