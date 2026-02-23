import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../tao996.dart';

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
  const DataUtil();

  IDebugService get _debugService => getIDebugService();

  /// 获取 bool 值;
  /// [textCompare] 如果为 true，则会将 0/false/f/F/OFF/off/OFF 转为 false；将 1/true/t/T/ON/on/ON 转为 true
  /// 如果 [v] 为 null/空字符串则返回 [defaultValue] 默认值；
  /// [v] 为整数并且 >0 时，返回 true
  bool getBool(
    dynamic v, {
    bool defaultValue = false,
    bool textCompare = false,
  }) {
    if (v == null ||
        v == '' ||
        (textCompare &&
            (v == '0' ||
                v == 'false' ||
                v == 'f' ||
                v == 'F' ||
                v == 'OFF' ||
                v == 'off'))) {
      return defaultValue;
    } else if (textCompare &&
        (v == '1' ||
            v == 'true' ||
            v == 't' ||
            v == 'T' ||
            v == 'on' ||
            v == 'ON')) {
      return true;
    } else if (v is num) {
      return v > 0;
    }
    try {
      return v as bool;
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  int getInt(dynamic v, {int defaultValue = 0}) {
    if (v == null || v == '') {
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

  double? tryGetDouble(dynamic v) {
    if (v == null || v == '') {
      return null;
    }
    return getDouble(v);
  }

  double getDouble(dynamic v, {double defaultValue = 0.0}) {
    if (v == null || v == '') {
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

  String getString(dynamic v, {String defaultValue = ''}) {
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

  DateTime? getDateTime(
    dynamic v, {
    DateTime? defaultValue,
    String? formatPattern,
  }) {
    if (v == null || v == '') {
      return defaultValue;
    }
    try {
      final rst = tu.date.parse(v, formatPattern: formatPattern);
      return rst ?? defaultValue;
    } catch (e, stackTrace) {
      _debugService.exception(e, stackTrace);
    }
    return defaultValue;
  }

  List<T>? getList<T>(
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
  dynamic firstValue(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }
    return null;
  }

  int getIntFromBool(bool value) {
    return value ? 1 : 0;
  }

  bool getBoolFromInt(int value) {
    return value == 1;
  }

  /// 验证字符串 [data] 是否符合指定的正则表达式 [pattern]
  bool hasMatch(String data, String pattern) {
    return RegExp(pattern).hasMatch(data);
  }

  /// 从字符串 [input] 中获取所有匹配项，匹配项的格式为 [pattern]
  List<String> getAllMatches(String pattern, String input) {
    // 使用 allMatches() 来获取所有匹配项的迭代器
    final Iterable<RegExpMatch> matches = RegExp(pattern).allMatches(input);
    final List<String> result = [];
    if (matches.isNotEmpty) {
      for (final match in matches) {
        result.add(match.group(0)!);
      }
    }
    return result;
  }

  /// 从字符串 [input] 中获取第一个匹配项，匹配项的格式为 [pattern]
  String? getFirstMatch(String pattern, String input) {
    final match = RegExp(pattern).firstMatch(input);
    return match?.group(0);
  }

  /// 验证用户输入的 [pattern] 是否为一个有效的正则表达式；注意跟原始字符串的区别
  bool isValidUserInputRegexPattern(String pattern) {
    return (pattern.startsWith('r"') && pattern.endsWith('"')) ||
        (pattern.startsWith("r'") && pattern.endsWith("'"));
  }

  /// 清除用户输入的正则表达式，返回一个可用户的系统正则表达式；
  String getUserInputRegexPattern(String input) {
    // 1. 移除字符串两端的空白符
    String cleaned = input.trim();
    // 2. 检查是否为原始字符串字面量格式 (r'...' 或 r"...")
    if (cleaned.length >= 3 && cleaned.startsWith('r')) {
      String firstQuote = cleaned[1];
      String lastQuote = cleaned[cleaned.length - 1];
      if (firstQuote == lastQuote && (firstQuote == "'" || firstQuote == '"')) {
        // 如果是，直接剥离 'r' 和引号，返回中间的内容
        // 这里不对内容做任何处理，因为 r'' 的作用就是保留所有字符的字面量
        return cleaned.substring(2, cleaned.length - 1);
      }
    }
    return cleaned;
  }

  /// 获取数据运行时的类型
  Type getType(dynamic data) {
    return data.runtimeType;
  }

  /// 将字符串转换为 MD5 哈希值
  String generateMd5(String input) {
    // 1. 将字符串转为 UTF-8 字节流
    var bytes = utf8.encode(input);
    // 2. 计算 MD5
    var digest = md5.convert(bytes);
    // 3. 以十六进制字符串形式输出
    return digest.toString();
  }

  /// 无法适用于 Map
  dynamic copy(dynamic data) {
    return jsonDecode(jsonEncode(data));
  }

  /// 专门克隆 `Map<String, Map<String, String>>` 的方法
  Map<String, Map<String, String>> cloneNestedMap(
    Map<String, Map<String, String>> source,
  ) {
    return source.map(
      (key, value) => MapEntry(
        key,
        Map<String, String>.from(value), // 这里对子 Map 进行了克隆
      ),
    );
  }

  /// 更通用的泛型克隆方法 (支持` Map<String, T>`)
  Map<String, T> cloneMap<T>(Map<String, T> source) {
    return Map<String, T>.from(
      source.map((key, value) {
        if (value is Map) {
          // 如果内部还是 Map，递归克隆
          return MapEntry(key, Map.from(value) as T);
        }
        return MapEntry(key, value);
      }),
    );
  }

  String jsonString(dynamic data) => jsonEncode(
    data,
    toEncodable: (item) {
      if (item is DateTime) {
        return item.toIso8601String(); // 转为 "2026-02-21T11:14:08..."
      }
      return item;
    },
  );
}
