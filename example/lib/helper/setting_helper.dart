import 'package:tao996/tao996.dart';

class SettingHelper extends SettingService {
  @override
  String get serverHost => throw UnimplementedError();

  /// 是否已经导入了测试数据
  bool get debugData => prefs.getBool('debugData') ?? false;

  set debugData(bool value) => prefs.setBool('debugData', value);
}
