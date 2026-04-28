import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

abstract class ILocaleService {
  // 获取地区 ，zh_CN, en_US 等
  Locale? get locale;
  String get localLanguage;

  /// 获取系统语言，由小写字母组成，如 en, zh
  String languageCode();

  void changeLanguage(String newLang);
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

  /// zh_CN
  Locale? _locale;

  /// 默认的地区
  // static Locale defaultLocale = const Locale('en', 'US');

  LocaleService() {
    _locale = settingsService.language == 'system'
        ? Get.deviceLocale
        : Locale(
            settingsService.language.split('_').first,
            settingsService.language.split('_').last,
          );
    dprint('==================== 默认地区: $_locale');
    Get.updateLocale(_locale!);
  }

  /// 修改語言
  @override
  void changeLanguage(String newLang) {
    if (kDebugMode) {
      dprint('修改显示语言: $newLang');
    }
    if (newLang == 'system') {
      Get.updateLocale(Get.deviceLocale ?? const Locale('en', 'US'));
    } else {
      final ll = newLang.split('_');
      if (ll.length != 2) {
        throw Exception('errorLanguageData'.tr);
      }
      Get.updateLocale(Locale(ll.first, ll.last));
    }
    settingsService.language = newLang;
  }

  @override
  Locale get locale => _locale!;

  /// 语言 zh_CN
  @override
  String get localLanguage => _locale?.toString() ?? defaultLocalLanguage;

  /// 语言 zh，注意不是 zh_CN
  @override
  String languageCode() {
    return _locale!.languageCode;
  }
}
