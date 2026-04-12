import 'package:get/get.dart';
import 'package:tao996/app.dart';
import 'package:tao996/src/app/pages/app_setting/app_setting_page.dart';
import 'package:tao996/src/app/pages/i18n.dart';
import 'package:tao996/tao996.dart';

import 'app_about/app_about_page.dart';

const _appSetting = '/tao996/appSettings';
const _appAbout = '/tao996/appAbout';

void gotoAppSettingPage() {
  Get.toNamed(_appSetting);
}

void gotoAppAboutPage(AppAboutArguments args) {
  Get.toNamed(_appAbout, arguments: args);
}

AppContactService getAppContactService() {
  /// 你可能需要自己创建一个
  if (!tu.get.isServiceRegistered<AppContactService>()) {
    tu.get.putService<AppContactService>(AppContactService());
  }
  return tu.get.getService<AppContactService>();
}

class AppPageModule {
  static void init({bool useMock = false}) {
    addAppPageI18n();
    _registerServices();
    _registerRoutes();
  }

  static void _registerServices() {}

  static void _registerRoutes() {
    Get.addPages([
      GetPage(name: _appSetting, page: () => AppSettingPage()),
      GetPage(name: _appAbout, page: () => AppAboutPage(tu.get.arguments())),
    ]);
  }
}
