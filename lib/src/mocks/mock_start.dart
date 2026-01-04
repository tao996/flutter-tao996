import 'package:flutter/foundation.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996/testing.dart';

void mockStart() {
  if (!kDebugMode) {
    return;
  }

  /// 注册服务
  tu.get.putService<IDebugService>(MockIDebugService());
  tu.get.putService<IMessageService>(MockIMessageService());
  tu.get.putService<IDatabaseService>(MockIDatabaseService());
}
