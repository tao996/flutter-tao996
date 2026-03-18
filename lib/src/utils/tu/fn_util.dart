import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class FnUtil {
  const FnUtil();

  static Timer? _debounce;

  void _debounceCancel() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
  }

  /// 防抖：在指定 [milliseconds] 时间内，如果再次调用该方法，则取消上一次调用。
  /// 在覆盖上一个函数（不支持在运行过程中手动取消）
  void debounce(VoidCallback callback, {int milliseconds = 500}) {
    _debounceCancel();
    _debounce = Timer(Duration(milliseconds: milliseconds), () {
      callback();
      _debounceCancel();
    });
  }

  /// 非阻塞的延时（支持手动取消），返回一个取消函数
  /// ```dart
  /// // 使用方式：
  /// final cancel = startTimeout(Duration(seconds: 5), () => print("Boom!"));
  /// // ... 在 5 秒内如果想后悔：
  /// cancel();
  /// ```
  void Function() startTimeout(Duration duration, void Function() onTimeout) {
    final timer = Timer(duration, onTimeout);

    // 返回一个闭包，用于外部手动取消
    return () {
      if (timer.isActive) {
        timer.cancel();
        print("计时已手动拦截");
      }
    };
  }

  /// 随机延时 [minMilliseconds] 毫秒 到 [maxMilliseconds] 毫秒的函数。
  ///
  /// 该函数会暂停当前执行，等待一个随机生成的持续时间。
  Future<void> randomDelay({
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

  /// (阻塞）延时指定时间（默认为1秒）
  /// [seconds]：秒数（1秒=1000毫秒）， [milliseconds]：毫秒数
  Future<void> delayed({int? seconds, int? milliseconds}) async {
    // 建议：将两者相加，或者明确优先级
    final totalMs = (milliseconds ?? 0) + (seconds ?? 0) * 1000;
    // 如果都没传，给一个默认值（比如 1000ms）
    await Future.delayed(Duration(milliseconds: totalMs > 0 ? totalMs : 1000));
  }
}
