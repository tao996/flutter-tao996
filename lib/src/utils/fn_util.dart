import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tao996/tao996.dart';

void dprint(dynamic message, {bool stack = true}) {
  if (kDebugMode) {
    debugPrint(message.toString());
    if (stack) {
      StackUtil.output(
        color: MyColor.yellow,
        filterNames: ['fn_util.dart'],
        first: true,
      );
    }
  }
}

void ddprint(dynamic message, dynamic args) {
  if (kDebugMode) {
    getIDebugService().d(message, args: args);
  }
}

class FnUtil {
  static Timer? _debounce;

  static void _debounceCancel() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
  }

  /// 防抖：在指定 [milliseconds] 时间内，如果再次调用该方法，则取消上一次调用。
  static void debounce(VoidCallback callback, {int milliseconds = 500}) {
    _debounceCancel();
    _debounce = Timer(Duration(milliseconds: milliseconds), () {
      callback();
      _debounceCancel();
    });
  }

  /// 随机延时 [minMilliseconds] 毫秒 到 [maxMilliseconds] 毫秒的函数。
  ///
  /// 该函数会暂停当前执行，等待一个随机生成的持续时间。
  static Future<void> randomDelay({
    int minMilliseconds = 500,
    int maxMilliseconds = 2000,
  }) async {
    final Random random = Random();

    final int randomMilliseconds = random.nextInt(
      maxMilliseconds - minMilliseconds + 1,
    );
    final int delayMilliseconds = minMilliseconds + randomMilliseconds;

    // 使用 Future.delayed 进行延时
    await Future.delayed(Duration(milliseconds: delayMilliseconds));
  }

  /// 延时指定时间，支持秒或毫秒（优先使用毫秒）
  /// [seconds]：秒数（1秒=1000毫秒）
  /// [milliseconds]：毫秒数（若不为null，会覆盖seconds）
  static Future<void> delayed({int? seconds, int? milliseconds}) async {
    // 计算延时毫秒数：若指定了milliseconds则用它，否则用seconds转换（默认1秒）
    final int delayMs = milliseconds ?? (seconds ?? 1) * 1000;
    // 使用正确的毫秒参数
    await Future.delayed(Duration(milliseconds: delayMs));
  }
}
