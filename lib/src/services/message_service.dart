import 'dart:async';

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

  Future<void> alert(String title, {String? content, Widget? icon});

  /// 删除确认
  /// [textIsContent] 为 true 时，[text] 为内容，否则为标题
  Future<bool?> deleteConfirm(
    String text,
    void Function() yes, {
    bool textIsContent = false,
  });

  /// 成功提示，提前调用 Get.back() 后再调用 [success]
  @override
  void success(String message);

  /// 错误提示
  @override
  void error(String message);

  @override
  void notice(String message);

  @override
  void warning(String message);
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
  Future<void> alert(String title, {String? content, Widget? icon}) async {
    return await tu.sd.alert(title, content: content, icon: icon);
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
  void success(String message) {
    tu.sd.success(message);
  }

  @override
  void error(String message) {
    tu.sd.error(message);
  }

  @override
  void notice(String message) {
    tu.sd.notice(message);
  }

  @override
  void warning(String message) {
    tu.sd.warning(message);
  }
}
