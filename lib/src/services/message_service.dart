import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class IMessageService {
  // 操作确认
  Future<bool?> confirm({
    String? title,
    String? content,
    String? cancelText,
    String? confirmText,
  });

  // 删除确认
  Future<bool?> deleteConfirm(String title);

  Future<bool?> showToast({required String msg});

  /// [success] 如果为 true，则显示一个正确的图标，如果为 false 则显示一个错误的图标
  SnackbarController snackbar(
    String title,
    String message, {
    SnackPosition? snackPosition,
    bool? success,
  });

  SnackbarController success(String message);

  SnackbarController error(String message);
}

class MessageService implements IMessageService {
  @override
  Future<bool?> confirm({
    String? title,
    String? content,
    String? cancelText,
    String? confirmText,
  }) async {
    return Get.dialog(
      AlertDialog(
        icon: title == null ? null : const Icon(Icons.info),
        title: title == null ? null : Text(title),
        content: content == null ? null : Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text((cancelText ?? 'cancel').tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text((confirmText ?? 'confirm').tr),
          ),
        ],
      ),
    );
  }

  @override
  Future<bool?> showToast({required String msg}) async {
    Fluttertoast.cancel();
    if (msg.startsWith('DioException')) {
      msg = msg.substring(msg.lastIndexOf(':') + 1).trim();
    }
    return Fluttertoast.showToast(msg: msg);
  }

  @override
  Future<bool?> deleteConfirm(String title) async {
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
            onPressed: () {
              Get.back(result: true);
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  @override
  SnackbarController snackbar(
    String title,
    String message, {
    SnackPosition? snackPosition,
    bool? success,
  }) {
    return Get.snackbar(
      title,
      message,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      icon:
          success == null
              ? null
              : (success
                  ? Icon(Icons.check_circle_outline)
                  : Icon(Icons.close_outlined)),
    );
  }

  @override
  SnackbarController success(String message) {
    return snackbar('success'.tr, message, success: true);
  }

  @override
  SnackbarController error(String message) {
    return snackbar('error'.tr, message, success: false);
  }
}
