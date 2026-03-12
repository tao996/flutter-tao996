import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:tao996/tao996.dart';

class GetUtil {
  const GetUtil();

  /// 获取通过 locator.registerSingleton 注册的单例服务
  T getService<T extends Object>() {
    return GetIt.instance<T>();
  }

  /// 注册服务，如果已经注册，则跳过
  void putService<T extends Object>(T dependency, {bool overwrite = false}) {
    if (isServiceRegistered<T>()) {
      dprint('registerService: ${T.toString()} is already registered');
      if (!overwrite) {
        return;
      }
    }
    GetIt.instance.registerSingleton<T>(dependency);
  }

  /// 懒注册一个服务，如果已经注册，则跳过
  void lazyPutService<T extends Object>(
    T Function() factoryFunc, {
    bool overwrite = false,
  }) {
    if (isServiceRegistered<T>()) {
      dprint('lazyPutService: ${T.toString()} is already registered');
      if (!overwrite) {
        return;
      }
    }
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

  bool isControllerRegistered<T>({String? tag}) {
    return Get.isRegistered<T>(tag: tag);
  }

  /// 注册一个控制器，如果已经注册，则跳过
  /// `tu.get.putController(SimpleReportController(Get.arguments));`
  S putController<S>(S dependency, {String? tag, bool overwrite = false}) {
    if (isControllerRegistered<S>(tag: tag)) {
      dprint('putController: ${S.toString()} is already registered');
      if (!overwrite) {
        return Get.find<S>(tag: tag);
      }
    }
    return Get.put(dependency, tag: tag);
  }

  /// 懒注册一个控制器，如果已经注册，则跳过
  void lazyPutController<T extends Object>(
    T Function() factoryFunc, {
    String? tag,
    bool overwrite = false,
  }) {
    if (isControllerRegistered<T>(tag: tag)) {
      dprint('lazyPutController: ${T.toString()} is already registered');
      if (!overwrite) {
        return;
      }
    }
    Get.lazyPut(factoryFunc, tag: tag);
  }

  dynamic arguments() {
    return Get.arguments;
  }
}
