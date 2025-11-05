import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class KV<T> {
  String label;
  final Widget? icon;
  T value;

  KV({required this.label, required this.value, this.icon});

  @override
  String toString() {
    return 'KV{label: $label, value: $value}';
  }
}

List<KV<T>> kvCreateList<T extends Enum>(Map<T, String> maps) {
  final List<KV<T>> list = [];
  maps.forEach((key, label) {
    list.add(KV(label: label, value: key));
  });
  return list;
}

/// 查询列表中指定值的键
/// [kvs] 键值对列表;
/// [name] 枚举属性的字符中,对于枚举类型必须使用 toString() 而不是 .name, name 比 toString 少了一个类型前辍
/// [firstIfNotFound] 如果找不到，是否返回第一个键
T kvGetValue<T extends Enum>(
  final List<KV<T>> kvs,
  String? name, {
  bool firstIfNotFound = true,
}) {
  for (var kv in kvs) {
    if (kv.value.name == name) {
      return kv.value;
    }
  }
  if (firstIfNotFound) {
    ColorUtil.print(
      'warning:could not find value $name in kvs, return first value',
      MyColor.yellow,
    );
    return kvs.first.value;
  }
  throw 'could not find value $name in kvs';
}

T? kvTryGetValue<T extends Enum>(final List<KV<T>> kvs, String? name) {
  if (name == null || name.isEmpty) {
    return null;
  }
  for (var kv in kvs) {
    if (kv.value.name == name) {
      return kv.value;
    }
  }
  return null;
}

String kvGetLabel<T extends Enum>(List<KV<T>> kvs, T value, {String defaultLabel = ''}) {
  for (var kv in kvs) {
    if (kv.value == value) {
      return kv.label;
    }
  }
  return defaultLabel;
}
