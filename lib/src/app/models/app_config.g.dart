// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) =>
    AppConfig(
        gname: json['gname'] as String,
        name: json['name'] as String,
        value: json['value'] as String,
        remark: json['description'] as String? ?? '',
      )
      ..id = (json['id'] as num).toInt()
      ..createdAt = json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String)
      ..updatedAt = json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String)
      ..deletedAt = json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'gname': instance.gname,
  'name': instance.name,
  'value': instance.value,
  'description': instance.remark,
};
