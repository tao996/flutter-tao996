import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tao996/src/translation/dict.dart';
import 'package:tao996/tao996.dart';

/// 系统语言
List<KV<String>> kvLanguages = [
  KV(label: 'systemLanguage'.tr, value: 'system'),
  // system 是 local_service.dart 中的值
  KV(label: '中文简体', value: 'zh_CN'),
  KV(label: '中文繁體', value: 'zh_TW'),
  KV(label: '日本語', value: 'ja_JP'),
  // 欧洲主要语言
  KV(label: 'English', value: 'en_US'),
  // KV(label: 'Deutsch', value: 'de_DE'),
  // // 德语 (German)
  // KV(label: 'Français', value: 'fr_FR'),
  // // 法语 (French) (可选)
  // KV(label: 'Español', value: 'es_ES'),
  // // 西班牙语 (Spanish) (可选)
];
final List<Locale> systemSupportedLocales = [
  Locale('zh', 'CN'), //
  Locale('zh', 'TW'), //
  Locale('en', 'US'), //
  Locale('ja', 'JP'),
  // Locale('de', 'DE'), // 德语 (German)
  // Locale('fr', 'FR'), // 法语 (French) (可选)
  // Locale('es', 'ES'), // 西班牙语 (Spanish) (可选)
  // 'zh_CN',
  // 'zh_TW',
  // 'en_US',
  // 'de_DE',
  // 'fr_FR',
  // 'es_ES',
];

// 其它语言
// {'zh_CN':{},'zh_TW':{},'en_US':{},'de_DE':{},'fr_FR':{},'es_ES':{}}
// language code
// {'cn':{},'tw':{},'ja':{},'en':{},'de':{},'fr':{},'es':{}}
// 请写出它们的繁体中文 zh_TW，英文 en_US，日本语 ja_JP，德语 de_DE，法语 fr_FR，西班牙语 es_ES 的翻译，输出格式为 Map<String, Map<String, String>>，key 只使用单引号
// http://www.lingoes.net/zh/translator/langcode.htm
// 使用注意：只有在 GetMaterialApp build 之后，才能使用到 .tr 否则无交
/*
class AppTranslation {
    static final Map<String, Map<String, String>> keys = {
      'zh_CN': { /* 简体中文翻译 */ },
      'zh_TW': { /* 繁體中文翻译 */ },
      'en_US': { /* English翻译 */ },
      'ja_JP': { /* 日本語翻译 */ },
      'de_DE': { /* Deutsch翻译 */ },
      'fr_FR': { /* Français翻译 */ },
      'es_ES': { /* Español翻译 */ },
    };
}
*/
class TranslationService extends Translations {
  // {'zh_CN':{'name':'名称'},'zh_TW':{'name':"名稱"},'en_US':{'name':'Name'},'de_DE':{},'fr_FR':{},'es_ES':{}}
  final Map<String, Map<String, String>> _keys = words;

  @override
  Map<String, Map<String, String>> get keys => _keys;

  void addDict(Map<String, Map<String, String>> newKeys) {
    newKeys.forEach((key, value) {
      if (_keys.containsKey(key)) {
        _keys[key]!.addAll(value);
      } else {
        _keys[key] = value;
      }
    });
  }

  // 将翻译添加到语言上
  void addKeys(Map<String, String> newKeys, {String locale = 'zh_CN'}) {
    if (_keys.containsKey(locale)) {
      _keys[locale]!.addAll(newKeys);
    } else {
      _keys[locale] = Map<String, String>.from(newKeys);
    }
  }

  /// 加载翻译文件 [jsonPth] `lib/extensions/app_beian/i18n/zh_CN.json`
  /// 你只能在 debug 模式下使用此方法
  Future<void> addJsonFile(String jsonPth, {String locale = 'zh_CN'}) async {
    if (!kDebugMode) {
      throw Exception('loadJsonKeys 只能在 debug 模式下运行');
    }
    // 直接使用相对于当前工作目录的路径
    final file = File(jsonPth);

    if (!file.existsSync()) {
      throw Exception('Translation file not found: ${file.path}');
    }
    final content = await file.readAsString();
    final Map<String, dynamic> json = jsonDecode(content);

    addKeys(
      json.map((key, value) => MapEntry(key, value.toString())),
      locale: locale,
    );
  }
}

/*
带参数的翻译
'message': '同步了 @count 个订阅',
使用
 'message'.trParams({'count': })

class ChildTranslation extends MyTranslation {
    @override
    Map<String, Map<String, String>> get keys => {
        ...super.keys,
        'zh_CN': {
            ...(super.keys['zh_CN'] ?? {}),
            'submit': '提交',
        },
    };
}

// 使用服务
class AppTranslation {
  static const Map<String, Map<String, String>> keys = {
    'zh_CN': {'appTitle': 'TAO996 DEMO'},
  };
}
getTranslationService().addKeys(AppTranslation.keys);
dprint(getTranslationService().keys);
 */
