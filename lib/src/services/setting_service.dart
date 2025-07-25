import 'package:shared_preferences/shared_preferences.dart';

abstract class ISettingsService {
  String get language;

  set language(String value);

  int get themeMode;

  set themeMode(int value);

  String get themeFont;

  set themeFont(String value);

  bool get useDynamicColor;

  set useDynamicColor(bool value);

  bool get useLowDataMode;

  set useLowDataMode(bool value);

  String get transition;

  set transition(String value);

  double get textScaleFactor;

  set textScaleFactor(double value);

  int get readFontSize;

  set readFontSize(int value);

  double get readLineHeight;

  set readLineHeight(double value);

  int get readPagePadding;

  set readPagePadding(int value);

  String get readTextAlign;

  set readTextAlign(String value);

  bool get useProxy;

  set useProxy(bool value);

  String get proxyAddress;

  set proxyAddress(String value);

  String get proxyPort;

  set proxyPort(String value);

  /// 获取服务器域名，不需要以 / 结尾
  String get serverHost;

  void updateServerHost(String value);

  Future<void> init(); // 添加 init 方法到接口
}

abstract class SettingService implements ISettingsService {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs;

  @override
  String get language => _prefs.getString('language') ?? 'system';

  @override
  set language(String value) => _prefs.setString('language', value);

  @override
  int get themeMode => prefs.getInt('themeMode') ?? 0;

  @override
  set themeMode(int value) => prefs.setInt('themeMode', value);

  @override
  String get themeFont => prefs.getString('themeFont') ?? 'system';

  @override
  set themeFont(String value) => prefs.setString('themeFont', value);

  @override
  bool get useDynamicColor => prefs.getBool('useDynamicColor') ?? true;

  @override
  set useDynamicColor(bool value) => prefs.setBool('useDynamicColor', value);

  @override
  bool get useLowDataMode => prefs.getBool('useLowDataMode') ?? true;

  @override
  set useLowDataMode(bool value) => prefs.setBool('useLowDataMode', value);

  @override
  String get transition => prefs.getString('transition') ?? 'cupertino';

  @override
  set transition(String value) => prefs.setString('transition', value);

  @override
  double get textScaleFactor => prefs.getDouble('textScaleFactor') ?? 1.0;

  @override
  set textScaleFactor(double value) =>
      prefs.setDouble('textScaleFactor', value);

  @override
  int get readFontSize => prefs.getInt('readFontSize') ?? 16;

  @override
  set readFontSize(int value) => prefs.setInt('readFontSize', value);

  @override
  double get readLineHeight => prefs.getDouble('readLineHeight') ?? 1.5;

  @override
  set readLineHeight(double value) => prefs.setDouble('readLineHeight', value);

  @override
  int get readPagePadding => prefs.getInt('readPagePadding') ?? 18;

  @override
  set readPagePadding(int value) => prefs.setInt('readPagePadding', value);

  @override
  String get readTextAlign => prefs.getString('readTextAlign') ?? 'justify';

  @override
  set readTextAlign(String value) => prefs.setString('readTextAlign', value);

  @override
  bool get useProxy => _prefs.getBool('useProxy') ?? false;

  @override
  set useProxy(bool value) => _prefs.setBool('useProxy', value);

  @override
  String get proxyAddress => _prefs.getString('proxyAddress') ?? '';

  @override
  set proxyAddress(String value) => _prefs.setString('proxyAddress', value);

  @override
  String get proxyPort => _prefs.getString('proxyPort') ?? '';

  @override
  set proxyPort(String value) => _prefs.setString('proxyPort', value);

  @override
  void updateServerHost(String value) {
    final newHost =
        value.endsWith('/') ? value.substring(0, value.length - 1) : value;
    _prefs.setString('serverHost', newHost);
  }
}
