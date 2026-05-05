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

  Future<void> alert(String content, {String? title, Widget? icon}) {
    return SmartDialog.show(
      builder: (context) {
        return AlertDialog(
          icon: icon,
          title: Text(title ?? 'notice'.tr),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                dismiss();
              },
              child: Text('confirm'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> confirm({
    String? title,
    String? content,
    String? cancelBtnText,
    String? confirmBtnText,
    void Function()? yes,
    void Function()? no,
  }) async {
    return SmartDialog.show(
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.info),
          title: title == null ? null : Text(title),
          content: content == null ? null : Text(content),
          actions: [
            TextButton(
              onPressed: () {
                no?.call();
                dismiss();
              },
              child: Text(cancelBtnText ?? 'cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                SmartDialog.dismiss(result: true);
                yes?.call();
              },
              child: Text(confirmBtnText ?? 'confirm'.tr),
            ),
          ],
        );
      },
    );
  }

  /// 删除确认
  ///
  /// [content] 提示内容，默认为 "确定要删除该[name]吗？";
  /// [name] 名称，默认为 "记录";
  Future<bool?> deleteConfirm({
    String? name,
    String? content,
    void Function()? yes,
  }) async {
    return confirm(
      title: 'deleteConfirmTitle'.tr,
      content:
          content ??
          'deleteConfirmContent'.trParams({'title': name ?? 'record'.tr}),
      yes: yes,
    );
  }
}
