import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class GetUtil {
  const GetUtil();

  /// 获取通过 locator.registerSingleton 注册的单例服务
  T getService<T extends Object>() {
    return GetIt.instance<T>();
  }

  /// 如果不存在则注册
  void putService<T extends Object>(T dependency) {
    if (!GetIt.instance.isRegistered<T>()) {
      GetIt.instance.registerSingleton<T>(dependency);
    }
  }

  /// 获取控制器
  T getController<T extends Object>() {
    return Get.find<T>();
  }

  /// 注册一个控制
  S putController<S>(S dependency) {
    return Get.put(dependency);
  }
}
