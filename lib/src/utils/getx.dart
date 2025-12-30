import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

/// 获取通过 locator.registerSingleton 注册的单例服务
T getXService<T extends Object>() {
  return GetIt.instance<T>();
}

/// 注册一个服务
void getXRegisterService<T extends Object>(T dependency) {
  GetIt.instance.registerSingleton<T>(dependency);
}

/// 获取控制器
T getGetController<T extends Object>() {
  return Get.find<T>();
}

/// 注册一个控制
S getPutController<S>(S dependency) {
  return Get.put(dependency);
}
