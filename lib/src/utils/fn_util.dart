import 'dart:async';
import 'dart:ui';

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
}
