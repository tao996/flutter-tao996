import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

void dprint(dynamic message) => debugPrint(message.toString());

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

  /// 延时指定秒，默认为 1 秒
  static Future<void> delayed({int? seconds, int? milliseconds}) async {
    milliseconds = milliseconds ?? (seconds == null ? 1000 : 1000 * seconds);
    await Future.delayed(Duration(microseconds: milliseconds));
  }
}
