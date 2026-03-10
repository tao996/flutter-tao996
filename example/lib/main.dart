import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tao996/tao996.dart';

import 'helper/setting_helper.dart';
import 'helper/theme_helper.dart';
import 'translation/translation.dart';
import 'helper/route_helper.dart';

void main() async {
  try {
    await _initAppServices();
    runApp(MyTao996App(fallbackLocale: const Locale('zh', 'CN')));
  } catch (e, st) {
    // getIDebugService().exception(e, st);
    debugPrint(e.toString());
    debugPrintStack(stackTrace: st);

    // 在桌面端，你可以选择显示一个包含错误信息的界面，或者直接退出
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  '应用启动失败，请联系管理员。',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
              Center(
                child: Text(
                  '错误信息：${e.toString()}',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _initAppServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 在桌面平台上初始化数据库工厂
  // 这行代码必须在调用 openDatabase() 或 getDatabasesPath() 之前执行
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final locator = GetIt.instance;

  // 注册依赖项，也可以使用下面注释的代码替换
  await registerTao996Dependencies([]);

  // locator.registerLazySingleton<IMessageService>(() => MessageService());
  // final ILogService logService = LogService();
  // locator.registerSingleton<ILogService>(logService);
  //
  // final debugServer = DebugService();
  // debugServer.logPackages(['your_package_name']);
  // locator.registerLazySingleton<IDebugService>(() => debugServer);

  // 路由
  final routeSer = RouteHelper();
  locator.registerSingleton<RouteHelper>(routeSer);

  // 语言
  getTranslationService().addDict(AppTranslation.keys);
  // dprint(getTranslationService().keys);

  // 主题
  final themeHelper = ThemeHelper();
  locator.registerSingleton<IThemeService>(themeHelper);
  themeHelper.defaultSystemUIOverlayStyle();

  final setting = SettingHelper();
  locator.registerSingleton<SettingHelper>(setting);
  locator.registerSingleton<ISettingsService>(setting);

  // 通用服务
  registerTao996Services(locator);

  // 模型数据服务
  // final db = SqfliteDatabaseService(
  //   printSQL: kDebugMode,
  //   databaseName: 'your_database.db',
  // );
  // locator.registerSingleton<IDatabaseService>(db);
  // try {
  //   await DbSQL.execute(db);
  // } catch (e, st) {
  //   debugServer.exception(e, st);
  //   rethrow;
  // }
  /// 模型服务
  // locator.registerSingleton<YourModelService>(YourModelService());
}
