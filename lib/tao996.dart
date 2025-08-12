export 'src/const/color.dart';

export 'src/utils/color_util.dart';
export 'src/utils/data_util.dart';
export 'src/utils/datetime_util.dart';
export 'src/utils/fn_util.dart';
export 'src/utils/json_util.dart';
export 'src/utils/url_util.dart';

export 'src/helpers/api_response_handler.dart';
export 'src/helpers/form_helper.dart';
export 'src/helpers/model.dart';
export 'src/helpers/model_helper.dart';

export 'src/services/database_service.dart';
export 'src/services/debug_service.dart';
export 'src/services/device_service.dart';
export 'src/services/file_picker_service.dart';
export 'src/services/font_service.dart';
export 'src/services/http_getx_service.dart';
export 'src/services/http_dio_service.dart';
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

export 'src/ui/page/easy_refresh.dart';
export 'src/ui/page/image_viewer.dart';
export 'src/ui/page/network_controller.dart';
export 'src/ui/page/network_widget.dart';
export 'src/ui/page/qrcode_view.dart';
export 'src/ui/page/search_controller.dart';
export 'src/ui/page/search_widget.dart';
export 'src/ui/page/smart_refresher_controller.dart';
export 'src/ui/page/smart_refresher_widget.dart';

export 'src/ui/widgets/avatar.dart';
export 'src/ui/widgets/buttons.dart';
export 'src/ui/widgets/dialog.dart';
export 'src/ui/widgets/event.dart';
export 'src/ui/widgets/list_checkbox.dart';
export 'src/ui/widgets/grid_checkbox.dart';
export 'src/ui/widgets/image.dart';
export 'src/ui/widgets/loading.dart';
export 'src/ui/widgets/padding.dart';
export 'src/ui/widgets/scaffold.dart';
export 'src/ui/widgets/separator_line.dart';
export 'src/ui/widgets/text.dart';

export 'src/ui/app.dart';

import 'package:get_it/get_it.dart';
import 'package:tao996/tao996.dart';
import 'tao996_platform_interface.dart';

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
}

/// 注册有依赖的服务
void registerTao996Services(GetIt locator) {
  // final locator = GetIt.instance;
  // 用户需要自己注册
  // ISettingsService, IThemeService, IDatabaseService, ITranslationService,IRouteService
  // locator.registerLazySingleton<IThemeService>(() => ThemeService());
  // locator.registerLazySingleton<IDatabaseService>(() => SqfliteDatabaseService());

  locator.registerLazySingleton<IFontService>(() => FontService());
  locator.registerLazySingleton<DioHttpService>(() => DioHttpService());
  // locator.registerLazySingleton<IHttpService>(() => DioHttpClient());
  locator.registerLazySingleton<ILocaleService>(() => LocaleService());
  locator.registerLazySingleton<INetworkService>(() => NetworkService());
  locator.registerLazySingleton<IPathService>(() => PathService());
  locator.registerLazySingleton<IShareService>(() => ShareService());
  locator.registerLazySingleton<IFilePickerService>(() => FilePickerService());
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

ITranslationService getITranslationService() {
  return GetIt.instance<ITranslationService>();
}

IRouteService getIRouteService() {
  return GetIt.instance<IRouteService>();
}

IWebviewService getIWebviewService() {
  return GetIt.instance<IWebviewService>();
}
