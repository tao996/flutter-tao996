import 'package:get_it/get_it.dart';
import 'package:tao996_example/example.dart';


RouteHelper getRouteHelper() {
  return GetIt.instance<RouteHelper>();
}

SettingHelper getSettingHelper() {
  return GetIt.instance<SettingHelper>();
}

ThemeHelper getThemeHelper() {
  return GetIt.instance<ThemeHelper>();
}

// 模型服务
// YourModelService getYourModelService() {
//   return GetIt.instance<YourModelService>();
// }

// 控制器
// YourController getYourController() {
//   return Get.find<YourController>();
// }