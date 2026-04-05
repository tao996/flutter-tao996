import 'package:tao996/tao996.dart';

import 'package:json_annotation/json_annotation.dart';
part 'app_config.g.dart';

@JsonSerializable()
class AppConfig extends IModel<AppConfig> {
  // 配置表
  final String gname;
  final String name;
  final String value;
  final String remark;

  AppConfig({
    this.gname = '',
    required this.name,
    this.value = '',
    this.remark = '',
  });

  @override
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
  @override
  Map<String, dynamic> toMap() => toJson();
  @override
  AppConfig fromMap(Map<String, dynamic> map) => AppConfig.fromMap(map);
  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
  factory AppConfig.fromMap(Map<String, dynamic> map) =>
      AppConfig.fromJson(map);
}
