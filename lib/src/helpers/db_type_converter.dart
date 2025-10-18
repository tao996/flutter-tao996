// 封装工具类处理类型转换
import 'dart:convert';

import 'package:tao996/tao996.dart';

class DbTypeConverter {
  static bool boolFromJson(int value) => value == 1;

  static int boolToJson(bool value) => value ? 1 : 0;

  static String mapStringToJson(Map<String, String>? data) {
    return TypeCastUtil.mapToJson(data);
  }

  static Map<String, String> mapStringFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapStringFromJson(json);
  }

  static String mapIntToJson(Map<String, int>? data) {
    return TypeCastUtil.mapToJson(data);
  }

  static Map<String, int> mapIntFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapIntFromJson(json);
  }

  /// 调用 toMap 来生成字符串
  static String listToJson<T extends DbTypeModel<T>>(List<T>? items) {
    if (items == null || items.isEmpty) {
      return '';
    }
    return TypeCastUtil.listToJsonString<T>(items, (e) {
      return e.toMap();
    });
  }

  static List<T> listFromJson<T extends DbTypeModel<T>>(
    String? json, {
    required T Function(Map<String, dynamic>) fromMap,
  }) {
    if (json == null || json.isEmpty) {
      return [];
    }
    return TypeCastUtil.listFromJsonString<T>(json, (data) {
      return fromMap(data); // 这里是错误的，应该如何改写
    });
  }

  /// 将 JSON 字符串转为 `List<int>`
  /// 支持的 JSON 格式：[1,2,3] 或 null / 空字符串
  static List<int> listIntFromJson(String? json) {
    if (json == null || json.isEmpty || json == 'null' || json == '[]') {
      return [];
    }
    try {
      final List<dynamic> data = jsonDecode(json);
      return data
          .map(
            (item) => item is int ? item : int.tryParse(item.toString()) ?? 0,
          )
          .toList();
    } catch (e) {
      // 解析失败时返回空列表，可根据需求改为抛出异常
      return [];
    }
  }

  /// 将 `List<int>`转为 JSON 字符串
  /// 空列表会转为 "[]"，null 会转为 "[]"
  static String listIntToJson(List<int>? items) {
    if (items == null) {
      return '[]';
    }
    try {
      return jsonEncode(items);
    } catch (e) {
      return '[]';
    }
  }

  /// 将 JSON 字符串转为 `List<double>`
  /// 支持的 JSON 格式：[1.2, 3.4, 5] 或 null / 空字符串
  static List<double> listDoubleFromJson(String? json) {
    if (json == null || json.isEmpty || json == 'null' || json == '[]') {
      return [];
    }
    try {
      final List<dynamic> data = jsonDecode(json);
      return data.map((item) {
        if (item is double) return item;
        if (item is int) return item.toDouble();
        return double.tryParse(item.toString()) ?? 0.0;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 将 `List<double>`转为 JSON 字符串
  /// 空列表会转为 "[]"，null 会转为 "[]"
  static String listDoubleToJson(List<double>? items) {
    if (items == null) {
      return '[]';
    }
    try {
      return jsonEncode(items);
    } catch (e) {
      return '[]';
    }
  }

  /// 将 JSON 字符串转为 `List<String>`
  /// 支持的 JSON 格式：["a", "b", 123]（非字符串元素会转为字符串）或 null / 空字符串
  static List<String> listStringFromJson(String? json) {
    if (json == null || json.isEmpty || json == 'null' || json == '[]') {
      return [];
    }
    try {
      final List<dynamic> data = jsonDecode(json);
      return data.map((item) => item?.toString() ?? '').toList();
    } catch (e) {
      return [];
    }
  }

  /// 将 `List<String>`转为 JSON 字符串
  /// 空列表会转为 "[]"，null 会转为 "[]"
  static String listStringToJson(List<String>? items) {
    if (items == null) {
      return '[]';
    }
    try {
      return jsonEncode(items);
    } catch (e) {
      return '[]';
    }
  }
}
