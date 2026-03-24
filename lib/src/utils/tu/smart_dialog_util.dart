import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// https://pub.dev/packages/flutter_smart_dialog
class SmartDialogUtil {
  const SmartDialogUtil();

  void showLoading(String message) {
    SmartDialog.showLoading(msg: message);
  }

  void loading() {
    SmartDialog.showLoading();
  }

  void dismiss() {
    SmartDialog.dismiss();
  }

  void hideLoading() {
    SmartDialog.dismiss();
  }

  // 通知类
  void success(String message, {void Function()? onDismiss}) {
    SmartDialog.dismiss();
    SmartDialog.showNotify(
      msg: message,
      notifyType: NotifyType.success,
      onDismiss: onDismiss,
    );
  }

  void failure(String message, {void Function()? onDismiss}) {
    SmartDialog.dismiss();
    SmartDialog.showNotify(
      msg: message,
      notifyType: NotifyType.failure,
      onDismiss: onDismiss,
    );
  }

  void warning(String message, {void Function()? onDismiss}) {
    SmartDialog.dismiss();
    SmartDialog.showNotify(
      msg: message,
      notifyType: NotifyType.warning,
      onDismiss: onDismiss,
    );
  }

  void error(
    String message, {
    void Function()? onDismiss,
    bool clickMaskDismiss = false,
  }) {
    SmartDialog.dismiss();
    SmartDialog.showNotify(
      msg: message,
      notifyType: NotifyType.error,
      onDismiss: onDismiss,
      clickMaskDismiss: clickMaskDismiss,
    );
  }

  void toast(String msg) {
    SmartDialog.dismiss();
    SmartDialog.showToast(msg);
  }

  void showToast(String msg) {
    SmartDialog.dismiss();
    SmartDialog.showToast(msg);
  }

  void notice(String message, {void Function()? onDismiss}) {
    SmartDialog.dismiss();
    SmartDialog.showNotify(
      msg: message,
      notifyType: NotifyType.alert,
      onDismiss: onDismiss,
    );
  }

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
}
