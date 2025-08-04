import '../../tao996.dart';

class DataUtil {
  static final IDebugService _debugService = getIDebugService();

  static bool getBool(dynamic v, {bool defaultValue = false}) {
    if (v == null) {
      return defaultValue;
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
      return (v as num).toInt();
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
      return (v as num).toDouble();
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
      return (v as String);
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
  static dynamic firstValue(Map<String, dynamic> json, List<String> keys){
    for (var key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }
    return null;
  }
}
