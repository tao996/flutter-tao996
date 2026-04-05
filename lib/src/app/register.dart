import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tao996/tao996.dart';

/// 注册无依赖的服务
/// [packages] 需要打印日志的包名；
/// 稍后你还需要调用 registerTao996Services
Future<GetIt> registerTao996Dependencies(List<String> packages) async {
  final locator = GetIt.instance;
  // 在桌面平台上初始化数据库工厂
  // 这行代码必须在调用 openDatabase() 或 getDatabasesPath() 之前执行
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  StackUtil.logPackages(packages);

  await initSharedPreferences();
  tu.get.lazyPutService<IMessageService>(() => MessageService());
  final LogService logService = LogService();
  tu.get.putService<ILogService>(logService);
  if (kDebugMode) {
    debugPrint('日志目录：${(await LogService.getLogDir()).path}');
  }
  tu.get.putService<IDebugService>(DebugService());
  tu.get.lazyPutService<TranslationService>(() => TranslationService());
  tu.get.lazyPutService<IPathService>(() => PathService());
  tu.get.putService<INetworkService>(NetworkService());
  tu.get.lazyPutService<IShareService>(() => ShareService());
  tu.get.lazyPutService<IFilePickerService>(() => tu.file);
  return locator;
}

/// 在使用 registerTao996Services 之前你需要手动注册以下服务
/// ISettingsService, IThemeService,
void registerTao996Services(GetIt locator) {
  // final locator = GetIt.instance;
  // 用户需要自己注册
  // ISettingsService, IThemeService, IDatabaseService, IRouteService,ModelActionHelper
  // locator.registerLazySingleton<IThemeService>(() => ThemeService());
  // locator.registerLazySingleton<IDatabaseService>(() => SqfliteDatabaseService());

  locator.registerLazySingleton<FontService>(() => FontService());
  locator.registerLazySingleton<DioHttpService>(() => DioHttpService());
  // locator.registerLazySingleton<IHttpService>(() => DioHttpClient());
  final localService = LocaleService();
  locator.registerLazySingleton<ILocaleService>(() => localService);
  locator.registerLazySingleton<IWebviewService>(() => WebviewService());

  // 设置全局异常捕获
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   print('------------');
  //   print(details.stack);
  //   // 打印错误信息
  //   logService.e('Flutter Error: ${details.exception}');
  //   // https://sentry.io/welcome/ 使用了 google 登录
  //   // https://pub.dev/packages/sentry_flutter
  // };
}
