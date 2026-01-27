// 封装工具类处理类型转换
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tao996/tao996.dart';

class JsonColorConverter implements JsonConverter<Color, int> {
  const JsonColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

class JsonBoolConverter implements JsonConverter<bool, int> {
  const JsonBoolConverter();

  @override
  bool fromJson(int value) => value == 1;

  @override
  int toJson(bool value) => value ? 1 : 0;
}

class JsonMapStringStringConverter
    implements JsonConverter<Map<String, String>, String> {
  const JsonMapStringStringConverter();

  @override
  Map<String, String> fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapStringFromJson(json);
  }

  @override
  String toJson(Map<String, String>? data) {
    return TypeCastUtil.mapToJson(data);
  }
}

class JsonNestedMapStringConverter
    implements JsonConverter<Map<String, Map<String, String>>, String> {
  const JsonNestedMapStringConverter();

  @override
  Map<String, Map<String, String>> fromJson(String jsonString) {
    if (jsonString.isEmpty) return {};

    try {
      // 1. 解析字符串为原始 Map
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      // 2. 递归转换为正确的嵌套类型
      return decoded.map((key, value) {
        final innerMap = Map<String, dynamic>.from(value as Map);
        return MapEntry(key, innerMap.map((k, v) => MapEntry(k, v.toString())));
      });
    } catch (e) {
      print("JSON 转换错误: $e");
      return {};
    }
  }

  @override
  String toJson(Map<String, Map<String, String>> object) {
    // 将对象编码为 JSON 字符串以便存入数据库
    return jsonEncode(object);
  }
}

class JsonMapStringBoolConverter
    implements JsonConverter<Map<String, bool>, String> {
  const JsonMapStringBoolConverter();

  @override
  Map<String, bool> fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapBoolFromJson(json);
  }

  @override
  String toJson(Map<String, bool>? data) {
    return TypeCastUtil.mapToJson(data);
  }
}

class JsonMapStringIntConverter
    implements JsonConverter<Map<String, int>, String> {
  const JsonMapStringIntConverter();

  @override
  Map<String, int> fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapIntFromJson(json);
  }

  @override
  String toJson(Map<String, int>? data) {
    return TypeCastUtil.mapToJson(data);
  }
}

class JsonMapStringDoubleConverter
    implements JsonConverter<Map<String, double>, String> {
  const JsonMapStringDoubleConverter();

  @override
  Map<String, double> fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return {};
    }
    return TypeCastUtil.mapDoubleFromJson(json);
  }

  @override
  String toJson(Map<String, double>? data) {
    return TypeCastUtil.mapToJson(data);
  }
}

class JsonListIntConverter implements JsonConverter<List<int>, String> {
  const JsonListIntConverter();

  @override
  List<int> fromJson(String? json) {
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

  @override
  String toJson(List<int>? items) {
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

class JsonListDoubleConverter implements JsonConverter<List<double>, String> {
  const JsonListDoubleConverter();

  @override
  List<double> fromJson(String? json) {
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

  @override
  String toJson(List<double>? items) {
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

class JsonListStringConverter implements JsonConverter<List<String>, String> {
  const JsonListStringConverter();
  @override
  List<String> fromJson(String? json) {
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

  @override
  String toJson(List<String>? items) {
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

/// Rect 转换器: {"left": 0.0, "top": 0.0, "width": 100.0, "height": 100.0}
class JsonRectConverter implements JsonConverter<Rect, String> {
  const JsonRectConverter();

  @override
  Rect fromJson(String jsonString) {
    if (jsonString.isEmpty) return Rect.zero;
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Rect.fromLTWH(
      (map['l'] as num).toDouble(),
      (map['t'] as num).toDouble(),
      (map['w'] as num).toDouble(),
      (map['h'] as num).toDouble(),
    );
  }

  @override
  String toJson(Rect object) => jsonEncode({
    'l': object.left,
    't': object.top,
    'w': object.width,
    'h': object.height,
  });
}

/// Size 转换器: {"w": 100.0, "h": 50.0}
class JsonSizeConverter implements JsonConverter<Size, String> {
  const JsonSizeConverter();
  @override
  Size fromJson(String jsonString) {
    if (jsonString.isEmpty) return Size.zero;
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Size((map['w'] as num).toDouble(), (map['h'] as num).toDouble());
  }

  @override
  String toJson(Size object) =>
      jsonEncode({'w': object.width, 'h': object.height});
}

/// Offset 转换器: {"x": 10.0, "y": 10.0}
class JsonOffsetConverter implements JsonConverter<Offset, String> {
  const JsonOffsetConverter();

  @override
  Offset fromJson(String jsonString) {
    if (jsonString.isEmpty) return Offset.zero;
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Offset((map['x'] as num).toDouble(), (map['y'] as num).toDouble());
  }

  @override
  String toJson(Offset object) => jsonEncode({'x': object.dx, 'y': object.dy});
}

/// EdgeInsets 转换器: [left, top, right, bottom]
class JsonEdgeInsetsConverter implements JsonConverter<EdgeInsets, String> {
  const JsonEdgeInsetsConverter();

  @override
  EdgeInsets fromJson(String jsonString) {
    if (jsonString.isEmpty) return EdgeInsets.zero;
    final List<dynamic> list = jsonDecode(jsonString);
    return EdgeInsets.fromLTRB(
      (list[0] as num).toDouble(),
      (list[1] as num).toDouble(),
      (list[2] as num).toDouble(),
      (list[3] as num).toDouble(),
    );
  }

  @override
  String toJson(EdgeInsets object) =>
      jsonEncode([object.left, object.top, object.right, object.bottom]);
}

/// BoxShadow 转换器
class JsonBoxShadowConverter implements JsonConverter<BoxShadow, String> {
  const JsonBoxShadowConverter();

  @override
  BoxShadow fromJson(String jsonString) {
    if (jsonString.isEmpty) return const BoxShadow();

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return BoxShadow(
        // 🚀 这里的颜色使用 int 存储，还原时直接传入即可
        color: Color(json['color'] as int),
        // 🚀 还原偏移量
        offset: Offset(
          (json['dx'] as num).toDouble(),
          (json['dy'] as num).toDouble(),
        ),
        blurRadius: (json['blur'] as num).toDouble(),
        spreadRadius: (json['spread'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint("BoxShadow 解析失败: $e");
      return const BoxShadow();
    }
  }

  @override
  String toJson(BoxShadow object) {
    return jsonEncode({
      // 🚀 使用新版 API 获取 32 位整型颜色值
      'color': object.color.toARGB32(),
      'dx': object.offset.dx,
      'dy': object.offset.dy,
      'blur': object.blurRadius,
      'spread': object.spreadRadius,
    });
  }
}

/// FontWeight 转换器 (存为索引 0-8)
class JsonFontWeightConverter implements JsonConverter<FontWeight, int> {
  const JsonFontWeightConverter();
  @override
  FontWeight fromJson(int json) => FontWeight.values[json];
  @override
  int toJson(FontWeight object) => object.index;
}

/// BoxFit 转换器 (存为名称: "cover", "contain" 等)
class JsonBoxFitConverter implements JsonConverter<BoxFit, String> {
  const JsonBoxFitConverter();
  @override
  BoxFit fromJson(String json) =>
      BoxFit.values.firstWhere((e) => e.name == json);
  @override
  String toJson(BoxFit object) => object.name;
}

/// LinearGradient 转换器
class JsonGradientConverter implements JsonConverter<Gradient, String> {
  const JsonGradientConverter();

  @override
  Gradient fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final type = json['type'] as String;

    // 解析颜色列表
    final List<Color> colors = (json['colors'] as List)
        .map((c) => Color(c as int))
        .toList();

    // 解析 Stops (选填)
    final List<double>? stops = (json['stops'] as List?)
        ?.map((s) => (s as num).toDouble())
        .toList();

    if (type == 'linear') {
      return LinearGradient(
        begin: _parseAlignment(json['begin']),
        end: _parseAlignment(json['end']),
        colors: colors,
        stops: stops,
      );
    } else if (type == 'radial') {
      return RadialGradient(
        center: _parseAlignment(json['center']),
        radius: (json['radius'] as num).toDouble(),
        colors: colors,
        stops: stops,
      );
    }

    // 默认兜底
    return LinearGradient(colors: colors);
  }

  @override
  String toJson(Gradient object) {
    final Map<String, dynamic> json = {
      'colors': object.colors.map((c) => c.toARGB32()).toList(),
      'stops': object.stops,
    };

    if (object is LinearGradient) {
      json['type'] = 'linear';
      json['begin'] = _alignmentToString(object.begin);
      json['end'] = _alignmentToString(object.end);
    } else if (object is RadialGradient) {
      json['type'] = 'radial';
      json['center'] = _alignmentToString(object.center);
      json['radius'] = object.radius;
    }

    return jsonEncode(json);
  }

  // 辅助方法：Alignment 转 字符串
  String _alignmentToString(AlignmentGeometry align) {
    return align.toString().replaceFirst('Alignment.', '');
  }

  // 辅助方法：字符串 转 Alignment
  Alignment _parseAlignment(String? s) {
    switch (s) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }
}

class DbTypeConverter {
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
