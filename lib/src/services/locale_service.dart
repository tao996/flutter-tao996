import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

abstract class ILocaleService {
  Future<void> changeLocale(String locale);

  // 获取地区
  Locale? get locale;

  /// 获取系统语言，由小写字母组成，如 en, zh
  String languageCode();
}

/*
PlatformDispatcher.instance.locale 在 Flutter 中返回的是当前用户界面的首选 Locale
由两部分组成
1.语言代码 (languageCode): 一个由两个或三个小写字母组成的 ISO 639-1 或 ISO 639-2 语言代码。
如 en, zh
2.国家/地区代码 (countryCode, 可选): 一个由两个大写字母组成的 ISO 3166-1 alpha-2 国家/地区代码。
如 US, CN
 */
class LocaleService implements ILocaleService {
  final ISettingsService settingsService = getISettingsService();
  Locale? _locale;

  LocaleService() {
    _locale = settingsService.language == 'system'
        ? Get.deviceLocale
        : Locale(
            settingsService.language.split('_').first,
            settingsService.language.split('_').last,
          );
    Get.updateLocale(_locale!);
  }

  @override
  Future<void> changeLocale(String language) async {
    final ll = language.split('_');
    if (ll.length != 2 && language != 'system') {
      throw Exception('error language data'.tr);
    }
    settingsService.language = language;
    if (ll.length == 2) {
      _locale = Locale(language.split('_').first, language.split('_').last);
      Get.updateLocale(_locale!);
    } else {
      _locale = Get.deviceLocale;
    }
    return;
  }

  @override
  Locale get locale => _locale!;

  @override
  String languageCode() {
    return _locale!.languageCode;
  }
}
