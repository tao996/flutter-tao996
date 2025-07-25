export 'src/utils/data_util.dart';
export 'src/utils/datetime_util.dart';
export 'src/utils/fn_util.dart';
export 'src/utils/url_util.dart';

export 'src/helpers/api_response_handler.dart';
export 'src/helpers/model_helper.dart';

export 'src/services/database_service.dart';
export 'src/services/debug_service.dart';
export 'src/services/device_service.dart';
export 'src/services/file_picker_service.dart';
export 'src/services/font_service.dart';
export 'src/services/http_service.dart';
export 'src/services/locale_service.dart';
export 'src/services/log_service.dart';
export 'src/services/message_service.dart';
export 'src/services/network_service.dart';
export 'src/services/path_service.dart';
export 'src/services/route_service.dart';
export 'src/services/setting_service.dart';
export 'src/services/share_service.dart';
export 'src/services/theme_service.dart';
export 'src/services/webview_service.dart';

export 'src/translation/translation.dart';

import 'package:get_it/get_it.dart';
import 'package:tao996/tao996.dart';
import 'tao996_platform_interface.dart';

class Tao996 {
  Future<String?> getPlatformVersion() {
    return Tao996Platform.instance.getPlatformVersion();
  }
}

void registerTao996Dependencies(GetIt locator) {
  // final locator = GetIt.instance;
  // 用户需要自己注册
  // ISettingsService, IThemeService, IDatabaseService, ITranslationService,IRouteService
  // locator.registerLazySingleton<IThemeService>(() => ThemeService());
  // locator.registerLazySingleton<IDatabaseService>(() => SqfliteDatabaseService());

  locator.registerLazySingleton<IDebugService>(() => DebugService());
  final ILogService logService = LogService();
  locator.registerSingleton<ILogService>(logService);
  locator.registerLazySingleton<IFontService>(() => FontService());
  locator.registerLazySingleton<IHttpService>(() => DioHttpClient());
  locator.registerLazySingleton<ILocaleService>(() => LocaleService());
  locator.registerLazySingleton<INetworkService>(() => NetworkService());
  locator.registerLazySingleton<IPathService>(() => PathService());
  locator.registerLazySingleton<IShareService>(() => ShareService());
  locator.registerLazySingleton<IFilePickerService>(() => FilePickerService());
  locator.registerLazySingleton<IMessageService>(() => MessageService());
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

IDebugService getIDebugService() {
  return GetIt.instance<IDebugService>();
}

IFilePickerService getIFilePickerService() {
  return GetIt.instance<IFilePickerService>();
}

IFontService getIFontService() {
  return GetIt.instance<IFontService>();
}

IHttpService getIHttpService() {
  return GetIt.instance<IHttpService>();
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

ISettingsService getISettingsService() {
  return GetIt.instance<ISettingsService>();
}

IShareService getIShareService() {
  return GetIt.instance<IShareService>();
}

IThemeService getIThemeService() {
  return GetIt.instance<IThemeService>();
}

ITranslationService getITranslationService() {
  return GetIt.instance<ITranslationService>();
}

IRouteService getIRouteService() {
  return GetIt.instance<IRouteService>();
}

IWebviewService getIWebviewService() {
  return GetIt.instance<IWebviewService>();
}
