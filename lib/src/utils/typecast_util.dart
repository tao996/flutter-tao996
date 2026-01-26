import 'dart:convert';

import 'package:flutter/foundation.dart';

class TypeCastUtil {
  // 私有辅助函数：安全地解码 JSON 字符串
  static dynamic safeJsonDecode(String? jsonString, {required bool isList}) {
    if (jsonString == null || jsonString.isEmpty) {
      return isList ? [] : {};
    }
    try {
      final decoded = jsonDecode(jsonString);
      // 根据预期类型进行初步检查
      if ((isList && decoded is List) || (!isList && decoded is Map)) {
        return decoded;
      }
    } on FormatException catch (e) {
      debugPrint('Invalid JSON format: $e');
    } on TypeError catch (e) {
      debugPrint('Type error during JSON decode: $e');
    }
    return isList ? [] : {};
  }

  /// A generic helper to safely cast a map from dynamic to a specific type
  static Map<K, V> castMap<K, V>(dynamic data) {
    if (data is Map) {
      return data.cast<K, V>();
    }
    return {};
  }

  /// and handling element-level type casting.
  static List<T> castList<T>(
    dynamic data,
    T Function(dynamic) converter, {
    bool throwOnError = true,
  }) {
    if (data == null) {
      return [];
    }
    if (data is! List) {
      if (throwOnError) {
        throw ArgumentError('Expected a List but got ${data.runtimeType}');
      }
      debugPrint('Error: Expected a List but got ${data.runtimeType}');
      return [];
    }
    try {
      return data.map<T>(converter).toList();
    } catch (e) {
      if (throwOnError) {
        throw ArgumentError('Error parsing List<${T.toString()}>: $e');
      }
      return [];
    }
  }

  /// 将 map 转为 json string
  static String mapToJson(Map<String, dynamic>? map) {
    if (map == null) {
      return "{}";
    }
    return jsonEncode(map);
  }

  /// 将 json string 还原为 `Map<String,dynamic>`
  static Map<String, dynamic> mapFromJson(String? jsonString) {
    final dynamic decoded = safeJsonDecode(jsonString, isList: false);
    return castMap<String, dynamic>(decoded);
  }

  /// 将 JSON 字符串还原为 `Map<String, T>`
  ///
  /// [jsonString]: 从数据库中读取的 JSON 字符串。
  /// [fromData]: 一个从 Map 中的值（dynamic 类型）构造 T 实例的函数。通常是类型的 fromMap 方法；如果是基础类型 (value) => value as int;
  ///
  /// 返回值：恢复后的 `Map<String, T>`。
  static Map<String, T> mapObjectFromJson<T>(
    String jsonString,
    T Function(dynamic) fromData,
  ) {
    if (jsonString.isEmpty) {
      return {};
    }
    final Map<String, dynamic> decoded = mapFromJson(jsonString);

    return decoded.map((key, value) => MapEntry(key, fromData(value)));
  }

  /// 将 json string 还原为 `Map<String,String>`
  static Map<String, String> mapStringFromJson(String? jsonString) {
    final dynamic decoded = safeJsonDecode(jsonString, isList: false);
    return castMap<String, String>(decoded);
  }

  /// 将 json string 还原为 `Map<String,int>`
  static Map<String, int> mapIntFromJson(String? jsonString) {
    final dynamic decoded = safeJsonDecode(jsonString, isList: false);
    return castMap<String, int>(decoded);
  }

  static Map<String, double> mapDoubleFromJson(String? jsonString) {
    final dynamic decoded = safeJsonDecode(jsonString, isList: false);
    return castMap<String, double>(decoded);
  }

  static Map<String, bool> mapBoolFromJson(String? jsonString) {
    final dynamic decoded = safeJsonDecode(jsonString, isList: false);
    return castMap<String, bool>(decoded);
  }

  /// 将 `List<T>` 转为 `List<Map<String, dynamic>>`
  static List<Map<String, dynamic>> listToMapList<T>(
    List<T>? list,
    Map<String, dynamic> Function(T) toMap,
  ) {
    if (list == null || list.isEmpty) return [];
    return list.map(toMap).toList();
  }

  /// 将 `List<T>` 转为 JSON 字符串
  static String listToJsonString<T>(
    List<T>? list,
    Map<String, dynamic> Function(T) toMap,
  ) {
    if (list == null || list.isEmpty) return '[]';
    final mapList = listToMapList(list, toMap);
    return jsonEncode(mapList);
  }

  /// 将 JSON 字符串转为 `List<T>`
  static List<T> listFromJsonString<T>(
    String? jsonString,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final decoded = safeJsonDecode(jsonString, isList: true);
    if (decoded is List) {
      // 安全地映射和转换
      return decoded
          .whereType<Map>()
          .map((e) => fromMap(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  static List<int> listIntFromDynamicList(
    dynamic data, {
    bool throwOnError = true,
  }) {
    return castList<int>(
      data,
      (e) => (e as num).toInt(),
      throwOnError: throwOnError,
    );
  }

  static List<double> listDoubleFromDynamicList(
    dynamic data, {
    bool throwOnError = true,
  }) {
    return castList<double>(
      data,
      (e) => (e as num).toDouble(),
      throwOnError: throwOnError,
    );
  }

  static List<String> listStringFromDynamicList(
    dynamic data, {
    bool throwOnError = true,
  }) {
    return castList<String>(
      data,
      (e) => (e as String).toString(),
      throwOnError: throwOnError,
    );
  }

  /// 将一个 `Map<Object?, Object?>` 还原为一个 T 对象
  static T objectFromMap<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromData,
  ) {
    if (data is! Map) {
      throw ArgumentError.value(
        data,
        'data',
        'Expected a Map but got ${data.runtimeType}',
      );
    }

    // 显式将 Map<Object?, Object?> 转换为 Map<String, dynamic>
    final typedData = (data).cast<String, dynamic>();

    return fromData(typedData);
  }

  static Map<String, Map<String, String>> stringToNestedMap(String jsonString) {
    // 1. 先解析为原始 Map
    final dynamic rawData = jsonDecode(jsonString);

    // 2. 显式转换为嵌套结构
    if (rawData is Map) {
      return rawData.map((key, value) {
        return MapEntry(
          key.toString(),
          // 关键点：将内部的 dynamic Map 转换为 Map<String, String>
          Map<String, String>.from(value as Map),
        );
      });
    }

    return {};
  }
}
