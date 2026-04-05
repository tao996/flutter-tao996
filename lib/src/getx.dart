import 'package:get_it/get_it.dart';
import 'package:tao996/tao996.dart';

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

/// 普通接口服务，便于测试
IDioHttpService getIDioHttpService() {
  return GetIt.instance<DioHttpService>();
}

/// 使用的是 Dio 服务
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
