import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class GetUtil {
  const GetUtil();

  /// 获取通过 locator.registerSingleton 注册的单例服务
  T getService<T extends Object>() {
    return GetIt.instance<T>();
  }

  /// 注册服务
  void putService<T extends Object>(T dependency) {
    GetIt.instance.registerSingleton<T>(dependency);
  }

  /// 服务是否存在
  bool isServiceRegistered<T extends Object>() {
    return GetIt.instance.isRegistered<T>();
  }

  /// 获取控制器
  T getController<T extends Object>() {
    return Get.find<T>();
  }

  bool isControllerRegistered<T extends Object>() {
    return Get.isRegistered<T>();
  }

  /// 注册一个控制
  /// `tu.get.putController(SimpleReportController(Get.arguments));`
  S putController<S>(S dependency) {
    return Get.put(dependency);
  }
}
