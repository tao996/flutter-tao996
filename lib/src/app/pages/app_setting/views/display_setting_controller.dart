import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class DisplaySettingController extends GetxController {
  final _settingHelper = getISettingsService();
  final FontService _fontSer = getIFontService();

  /// 主题模式
  late RxInt themeMode;

  /// 是否启用动态颜色
  late RxBool enableDynamicColor;

  /// 全局字体
  late RxString globalFont;

  /// 字体列表
  RxList<String> fontList = ["system"].obs;

  /// 过渡动画
  late RxString transition;
  late RxDouble textScaleFactor;
  late RxString language;

  DisplaySettingController() {
    themeMode = _settingHelper.themeMode.obs;
    enableDynamicColor = _settingHelper.useDynamicColor.obs;
    globalFont = _settingHelper.themeFont.obs;
    transition = _settingHelper.transition.obs;
    textScaleFactor = _settingHelper.textScaleFactor.obs;
    language = _settingHelper.language.obs;
  }

  void changeThemeMode(int value, BuildContext context) {
    if (value == themeMode.value) return;
    themeMode.value = value;
    _settingHelper.themeMode = value;

    final nTM = [ThemeMode.system, ThemeMode.light, ThemeMode.dark][value];
    Get.changeThemeMode(nTM);
    final theme = Theme.of(context);
    getIThemeService().systemUIOverlayStyle(
      theme.appBarTheme.backgroundColor,
      theme.brightness,
    );
  }

  void changeEnableDynamicColor(bool value) {
    if (value == enableDynamicColor.value) return;
    enableDynamicColor.value = value;
    _settingHelper.useDynamicColor = value;
    Get.forceAppUpdate();
  }

  void changeGlobalFont(String value) {
    if (value == globalFont.value) return;
    globalFont.value = value;
    _settingHelper.themeFont = value;
    Get.forceAppUpdate();
  }

  void changeTransition(String value) {
    if (value == transition.value) return;
    transition.value = value;
    _settingHelper.transition = value;
    Get.forceAppUpdate();
  }

  void changeTextScaleFactor(double value) {
    if (value == textScaleFactor.value) return;
    textScaleFactor.value = value;
    _settingHelper.textScaleFactor = value;
    Get.forceAppUpdate();
  }

  void changeLanguage(String value) {
    if (value == language.value) return;
    language.value = value;
    _settingHelper.language = value;
    if (value != 'system') {
      Get.updateLocale(Locale(value.split('_').first, value.split('_').last));
    } else {
      Get.updateLocale(Get.deviceLocale ?? const Locale('en', 'US'));
    }
  }

  Future<void> deleteFont(String font) async {
    await _fontSer.deleteFont(font);
    await refreshFontList();
    changeGlobalFont("system");
  }

  Future<void> refreshFontList() async {
    await tu.font.loadFonts().then(
      (value) => fontList.value = ["system", ...value],
    );
  }

  // import font
  Future<void> importFont() async {
    await tu.font.loadFonts();
    await refreshFontList();
  }
}
