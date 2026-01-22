import 'package:get_it/get_it.dart';
import 'package:tao996/tao996.dart';
import '../tao996_platform_interface.dart';

class Tao996 {
  Future<String?> getPlatformVersion() {
    return Tao996Platform.instance.getPlatformVersion();
  }
}

/// 注册无依赖的服务
void registerTao996Dependencies(GetIt locator) {
  locator.registerLazySingleton<IMessageService>(() => MessageService());
  final ILogService logService = LogService();
  locator.registerSingleton<ILogService>(logService);
  locator.registerLazySingleton<IDebugService>(() => DebugService());
  locator.registerLazySingleton<TranslationService>(() => TranslationService());
}

/// 注册有依赖的服务
void registerTao996Services(GetIt locator) {
  // final locator = GetIt.instance;
  // 用户需要自己注册
  // ISettingsService, IThemeService, IDatabaseService, IRouteService,ModelActionHelper
  // locator.registerLazySingleton<IThemeService>(() => ThemeService());
  // locator.registerLazySingleton<IDatabaseService>(() => SqfliteDatabaseService());

  locator.registerLazySingleton<IFontService>(() => FontService());
  locator.registerLazySingleton<DioHttpService>(() => DioHttpService());
  // locator.registerLazySingleton<IHttpService>(() => DioHttpClient());
  final localService = LocaleService();
  locator.registerLazySingleton<ILocaleService>(() => localService);
  locator.registerLazySingleton<INetworkService>(() => NetworkService());
  locator.registerLazySingleton<IPathService>(() => PathService());
  locator.registerLazySingleton<IShareService>(() => ShareService());
  locator.registerLazySingleton<IFilePickerService>(() => tu.file);
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

IFontService getIFontService() {
  return GetIt.instance<IFontService>();
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

IRouteService getIRouteService() {
  return GetIt.instance<IRouteService>();
}

IWebviewService getIWebviewService() {
  return GetIt.instance<IWebviewService>();
}
