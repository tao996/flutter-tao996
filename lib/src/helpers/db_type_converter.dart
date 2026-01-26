// 封装工具类处理类型转换
import 'dart:convert';
import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:tao996/tao996.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

class BoolConverter implements JsonConverter<bool, int> {
  const BoolConverter();

  @override
  bool fromJson(int json) => DbTypeConverter.boolFromJson(json);

  @override
  int toJson(bool object) => DbTypeConverter.boolToJson(object);
}

class MapStringStringConverter
    implements JsonConverter<Map<String, String>, String> {
  const MapStringStringConverter();

  @override
  Map<String, String> fromJson(String? json) =>
      DbTypeConverter.mapStringFromJson(json);

  @override
  String toJson(Map<String, String>? data) =>
      DbTypeConverter.mapStringToJson(data);
}

class MapStringBoolConverter
    implements JsonConverter<Map<String, bool>, String> {
  const MapStringBoolConverter();

  @override
  Map<String, bool> fromJson(String? json) =>
      DbTypeConverter.mapBoolFromJson(json);

  @override
  String toJson(Map<String, bool>? data) => DbTypeConverter.mapBoolToJson(data);
}

class MapStringIntConverter implements JsonConverter<Map<String, int>, String> {
  const MapStringIntConverter();

  @override
  Map<String, int> fromJson(String? json) =>
      DbTypeConverter.mapIntFromJson(json);

  @override
  String toJson(Map<String, int>? data) => DbTypeConverter.mapIntToJson(data);
}

class MapStringDoubleConverter
    implements JsonConverter<Map<String, double>, String> {
  const MapStringDoubleConverter();

  @override
  Map<String, double> fromJson(String? json) =>
      DbTypeConverter.mapDoubleFromJson(json);

  @override
  String toJson(Map<String, double>? data) =>
      DbTypeConverter.mapDoubleToJson(data);
}

class ListIntConverter implements JsonConverter<List<int>, String> {
  const ListIntConverter();

  @override
  List<int> fromJson(String? json) => DbTypeConverter.listIntFromJson(json);

  @override
  String toJson(List<int>? data) => DbTypeConverter.listIntToJson(data);
}

class ListDoubleConverter implements JsonConverter<List<double>, String> {
  const ListDoubleConverter();

  @override
  List<double> fromJson(String? json) =>
      DbTypeConverter.listDoubleFromJson(json);

  @override
  String toJson(List<double>? data) => DbTypeConverter.listDoubleToJson(data);
}

class ListStringConverter implements JsonConverter<List<String>, String> {
  const ListStringConverter();
  @override
  List<String> fromJson(String? json) =>
      DbTypeConverter.listStringFromJson(json);
  @override
  String toJson(List<String>? data) => DbTypeConverter.listStringToJson(data);
}

class DbTypeConverter {
  static bool boolFromJson(int value) => value == 1;

  static int boolToJson(bool value) => value ? 1 : 0;

  // Map<String, String>
  static Map<String, String> mapStringFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapStringFromJson(json);
  }

  static String mapStringToJson(Map<String, String>? data) {
    return TypeCastUtil.mapToJson(data);
  }

  // Map<String, bool>
  static String mapBoolToJson(Map<String, bool>? data) {
    return TypeCastUtil.mapToJson(data);
  }

  static Map<String, bool> mapBoolFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapBoolFromJson(json);
  }

  // Map<String, int>
  static String mapIntToJson(Map<String, int>? data) {
    return TypeCastUtil.mapToJson(data);
  }

  static Map<String, int> mapIntFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapIntFromJson(json);
  }

  // Map<String, double>
  static String mapDoubleToJson(Map<String, double>? data) {
    return TypeCastUtil.mapToJson(data);
  }

  static Map<String, double> mapDoubleFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapDoubleFromJson(json);
  }

  static String mapToJson<T extends DbTypeModel<T>>(Map<String, T>? data) {
    if (data == null || data.isEmpty) {
      return '';
    }
    final Map<String, dynamic> map = data.map((key, value) {
      return MapEntry(key, value.toMap());
    });
    return jsonEncode(map);
  }

  static Map<String, T> mapFromJson<T extends DbTypeModel<T>>(
    String? json, {
    required T Function(Map<String, dynamic>) fromMap,
  }) {
    if (json == null || json.isEmpty) {
      return {};
    }
    final Map<String, dynamic> map = TypeCastUtil.mapFromJson(json);
    return map.map((key, value) {
      return MapEntry(key, fromMap(value));
    });
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

  // List<int>
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

  /// 处理任何继承自 DbTypeModel 的嵌套对象
  ///
  /// ```
  /// @JsonKey(
  ///   fromJson: (v) => DbObjectConverter.fromJson(v, SaveSetting.fromJson),
  ///   toJson: DbObjectConverter.toJson,
  /// )
  /// ```
  static T fromJson<T>(dynamic json, T Function(Map<String, dynamic>) factory) {
    if (json == null) return null as T;
    if (json is String) {
      return factory(jsonDecode(json));
    }
    return factory(json as Map<String, dynamic>);
  }

  static String toJson(dynamic model) {
    if (model == null) return '';
    return jsonEncode(model.toJson());
  }
}
