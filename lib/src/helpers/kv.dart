import 'package:tao996/tao996.dart';

class KV<T> {
  String label;
  T value;

  KV({required this.label, required this.value});

  @override
  String toString() {
    return 'KV{label: $label, value: $value}';
  }
}

List<KV<T>> kvCreateList<T>(Map<T, String> maps) {
  final List<KV<T>> list = [];
  maps.forEach((key, label) {
    list.add(KV(label: label, value: key));
  });
  return list;
}

/// 查询列表中指定值的键
/// [kvs] 键值对列表;
/// [valueString] 枚举属性的字符中,对于枚举类型必须使用 toString() 而不是 .name, name 比 toString 少了一个类型前辍
/// [firstIfNotFound] 如果找不到，是否返回第一个键
T kvGetValue<T>(
  final List<KV<T>> kvs,
  String? valueString, {
  bool firstIfNotFound = true,
}) {
  for (var kv in kvs) {
    if (kv.value.toString() == valueString) {
      return kv.value;
    }
  }
  if (firstIfNotFound) {
    ColorUtil.print(
      'warning:could not find value $valueString in kvs, return first value',
      MyColor.yellow,
    );
    return kvs.first.value;
  }
  throw 'could not find value $valueString in kvs';
}

T? kvTryGetValue<T>(final List<KV<T>> kvs, String? valueString) {
  if (valueString == null || valueString.isEmpty) {
    return null;
  }
  for (var kv in kvs) {
    if (kv.value.toString() == valueString) {
      return kv.value;
    }
  }
  return null;
}

String kvGetLabel<T>(List<KV<T>> kvs, T value, {String defaultLabel = ''}) {
  for (var kv in kvs) {
    if (kv.value == value) {
      return kv.label;
    }
  }
  return defaultLabel;
}
