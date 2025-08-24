import '../../tao996.dart';

// 使用泛型优化的通用转换方法
T _getValue<T extends num>(dynamic v, T defaultValue) {
  if (v is T) {
    return v;
  } else if (v is num) {
    // 处理 int 到 double，或 double 到 int 的转换
    if (T == int) {
      return v.toInt() as T;
    } else if (T == double) {
      return v.toDouble() as T;
    }
  }
  return defaultValue;
}

class DataUtil {
  static final IDebugService _debugService = getIDebugService();

  static bool getBool(dynamic v, {bool defaultValue = false}) {
    if (v == null) {
      return defaultValue;
    } else if (v is num){
      return v > 0;
    }
    try {
      return v as bool;
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  static int getInt(dynamic v, {int defaultValue = 0}) {
    if (v == null) {
      return defaultValue;
    }
    try {
      // 处理 int 或 num 类型
      if (v is num) {
        return v.toInt();
      }

      // 处理 String 类型
      if (v is String) {
        // 使用 int.tryParse 安全地解析字符串
        return int.tryParse(v) ?? defaultValue;
      }
      return _getValue<int>(v, defaultValue);
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  static double getDouble(dynamic v, {double defaultValue = 0.0}) {
    if (v == null) {
      return defaultValue;
    }
    try {
      // 处理 double 或 num 类型
      if (v is num) {
        return v.toDouble();
      }

      // 处理 String 类型
      if (v is String) {
        // 使用 double.tryParse 安全地解析字符串
        return double.tryParse(v) ?? defaultValue;
      }
      return _getValue<double>(v, defaultValue);
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  static String getString(dynamic v, {String defaultValue = ''}) {
    if (v == null) {
      return defaultValue;
    }
    try {
      return v.toString();
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  static DateTime? getDateTime(
    dynamic v, {
    DateTime? defaultValue,
    String? formatPattern,
  }) {
    if (v == null) {
      return defaultValue;
    }
    try {
      return DatetimeUtil.parse(v, formatPattern: formatPattern);
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  static List<T>? getList<T>(
    dynamic v,
    T Function(Map<String, dynamic>) fromJson, {
    List<T>? defaultValue,
  }) {
    if (v == null || v == "") {
      return defaultValue;
    }
    try {
      return (v as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  /// 获取第一个不为 null 的值
  static dynamic firstValue(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }
    return null;
  }

  static int getIntFromBool(bool value) {
    return value ? 1 : 0;
  }

  static bool getBoolFromInt(int value) {
    return value == 1;
  }
}
