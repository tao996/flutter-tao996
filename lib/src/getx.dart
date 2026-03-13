import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tao996/tao996.dart';
import '../tao996_platform_interface.dart';

class Tao996 {
  Future<String?> getPlatformVersion() {
    return Tao996Platform.instance.getPlatformVersion();
  }
}

/// 注册无依赖的服务
/// [packages] 需要打印日志的包名
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
  locator.registerLazySingleton<IMessageService>(() => MessageService());
  final LogService logService = LogService();
  locator.registerSingleton<ILogService>(logService);
  if (kDebugMode) {
    debugPrint('日志目录：${(await LogService.getLogDir()).path}');
  }
  locator.registerLazySingleton<IDebugService>(() => DebugService());
  locator.registerLazySingleton<TranslationService>(() => TranslationService());
  locator.registerLazySingleton<IPathService>(() => PathService());
  locator.registerLazySingleton<INetworkService>(() => NetworkService());
  locator.registerLazySingleton<IShareService>(() => ShareService());
  locator.registerLazySingleton<IFilePickerService>(() => tu.file);
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

IDatabaseService getIDatabaseService() {
  return GetIt.instance<IDatabaseService>();
}

/// 如果你自己手动注册（通常用于替换数据库）
SqfliteDatabaseService getSqfliteDatabaseService() {
  return GetIt.instance<SqfliteDatabaseService>();
}

IDebugService getIDebugService() {
  return GetIt.instance<IDebugService>();
}

IFilePickerService getIFilePickerService() {
  return GetIt.instance<IFilePickerService>();
}

FontService getIFontService() {
  return GetIt.instance<FontService>();
}

IDioHttpService getIDioHttpService() {
  return GetIt.instance<DioHttpService>();
}

DioHttpService getDioHttpClient() {
  return GetIt.instance<DioHttpService>();
}

ILocaleService getILocaleService() {
  return GetIt.instance<ILocaleService>();
}

ILogService getILogService() {
  return GetIt.instance<ILogService>();
}

IMessageService getIMessageService() {
  return GetIt.instance<IMessageService>();
}

INetworkService getINetworkService() {
  return GetIt.instance<INetworkService>();
}

IPathService getIPathService() {
  return GetIt.instance<IPathService>();
}

/// 注意：你需要在项目中为其注册
ISettingsService getISettingsService() {
  return GetIt.instance<ISettingsService>();
}

IShareService getIShareService() {
  return GetIt.instance<IShareService>();
}

IThemeService getIThemeService() {
  return GetIt.instance<IThemeService>();
}

TranslationService getTranslationService() {
  return GetIt.instance<TranslationService>();
}

IWebviewService getIWebviewService() {
  return GetIt.instance<IWebviewService>();
}
