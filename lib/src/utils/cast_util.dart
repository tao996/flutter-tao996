import 'dart:convert';

class CastUtil {
  /// 将 map 转为 string，适合跨进程传递
  static String castMapToString(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  /// 将 string 转为 map，适合跨进程传递
  /// 在 handleMethodCallback 中调用 CastUtil.castStringToMap(call.arguments)
  static Map<String, dynamic> castStringToMap(String map) {
    return jsonDecode(map).cast<String, dynamic>();
  }

  /// 将一个 List<T> 转为 List<Map<String, dynamic>>，适合跨进程传递
  static List<Map<String, dynamic>> castList<T>(
    List<T> list,
    Map<String, dynamic> Function(T) toData,
  ) {
    return list.map((e) => toData(e)).toList();
  }

  /// 将 List<dynamic> 还原为 List<T>
  static List<T> castListFromData<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromData,
  ) {
    if (data is! List) {
      throw ArgumentError.value(
        data,
        'data',
        'Expected a List but got ${data.runtimeType}',
      );
    }
    return data.map((e) {
      if (e is! Map) {
        throw ArgumentError.value(
          e,
          'element',
          'Expected a Map but got ${e.runtimeType}',
        );
      }
      return fromData((e as Map).cast<String, dynamic>());
    }).toList();
  }

  /// 将一个 Map<String, T> 转为 Map<String, dynamic>
  static Map<String, dynamic> castMap<T>(
    Map<String, T> map,
    Map<String, dynamic> Function(T) toData,
  ) {
    return map.map((key, value) => MapEntry(key, toData(value)));
  }

  /// 将 Map<dynamic, dynamic> 还原为 Map<String, T>
  static Map<String, T> castMapFromData<T>(
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
    return (data as Map).cast<String, dynamic>().map((key, value) {
      if (value is! Map) {
        throw ArgumentError.value(
          value,
          'value',
          'Expected a Map inside the Map but got ${value.runtimeType}',
        );
      }
      return MapEntry(key, fromData(value as Map<String, dynamic>));
    });
  }

  /// 将 List<dynamic> 还原为 List<int>
  static List<int> castIntListFromData(dynamic data) {
    if (data is! List) {
      throw ArgumentError.value(
        data,
        'data',
        'Expected a List but got ${data.runtimeType}',
      );
    }
    // 使用 .cast<int>() 进行类型安全转换
    return data.cast<int>();
  }

  /// 将 List<dynamic> 还原为 List<double>
  static List<double> castDoubleListFromData(dynamic data) {
    if (data is! List) {
      throw ArgumentError.value(
        data,
        'data',
        'Expected a List but got ${data.runtimeType}',
      );
    }
    return data.cast<double>();
  }

  /// 将 List<dynamic> 还原为 List<String>
  static List<String> castStringListFromData(dynamic data) {
    if (data is! List) {
      throw ArgumentError.value(
        data,
        'data',
        'Expected a List but got ${data.runtimeType}',
      );
    }
    return data.cast<String>();
  }

  /// 将一个对象 T 转换为 Map<String, dynamic>
  static T castFromData<T>(
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
    final typedData = (data as Map).cast<String, dynamic>();

    return fromData(typedData);
  }
}
