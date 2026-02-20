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

  void lazyPutService<T extends Object>(T Function() factoryFunc) {
    GetIt.instance.registerLazySingleton<T>(factoryFunc);
  }

  /// 服务是否存在
  bool isServiceRegistered<T extends Object>() {
    return GetIt.instance.isRegistered<T>();
  }

  /// 获取控制器
  T getController<T extends Object>({String? tag}) {
    return Get.find<T>(tag: tag);
  }

  bool isControllerRegistered<T extends Object>({String? tag}) {
    return Get.isRegistered<T>(tag: tag);
  }

  /// 注册一个控制
  /// `tu.get.putController(SimpleReportController(Get.arguments));`
  S putController<S>(S dependency, {String? tag}) {
    return Get.put(dependency, tag: tag);
  }

  void lazyPutController<T extends Object>(
    T Function() factoryFunc, {
    String? tag,
  }) {
    Get.lazyPut(factoryFunc, tag: tag);
  }

  dynamic arguments() {
    return Get.arguments;
  }
}
