import 'package:tao996/src/app/models/app_config.dart';
import 'package:tao996/tao996.dart';

class AppConfigService extends ModelHelper<AppConfig> {
  AppConfigService() : super('tao996_app_config', smallTable: true);

  @override
  AppConfig fromMap(Map<String, dynamic> map) => AppConfig.fromMap(map);
}
