import 'dart:math';

import 'package:tao996/tao996.dart';

class NumberUtil {
  /// 将实际的金额（分，int）格式化成字符串（元，String）。
  /// 比如数据库中的 10001 分转换成 "100.01" 元。
  ///
  /// [num]: 存储的金额值，以“分”为单位（整数）。
  /// [fractionDigits]: 小数位数，通常为 2。
  /// [emptyText] 是否返回空字符串。如果为 true，则返回空字符串，否则返回 "0"。
  static String formatMoney(
    dynamic num, {
    int fractionDigits = 2,
    bool emptyText = true,
    bool trim = true,
  }) {
    if (num == 0 || num == null || num == '') {
      // 约定：如果金额为 0，返回 "0.00" 或 "0"
      return emptyText ? '' : 0.toStringAsFixed(fractionDigits);
    }

    final numData = DataUtil.getDouble(num);

    // 1. 将整数（分）转为 double（元）
    final double valueInCurrency = numData / (100); // 假设 fractionDigits 总是 2

    // 2. 使用 toStringAsFixed(fractionDigits) 格式化并处理补零
    final text = valueInCurrency.toStringAsFixed(fractionDigits);
    if (trim) {
      if (text.endsWith('.00')) {
        return text.substring(0, text.length - 3);
      }
    }
    return text;
  }

  /// 将用户输入的元（String）转换成分（int），以便保存到数据库中。
  /// 比如 "100,100.01" 元转换成 10010001 分。
  ///
  /// [money]: 用户输入的金额字符串（可能包含千分位符或空格）。
  ///
  /// 注意：该方法依赖于 money.replaceAll(',', '') 来移除千分位符。
  static int parseMoney(String? money) {
    if (money == null || money.isEmpty) {
      return 0;
    }

    // 1. 移除所有非数字和小数点的字符 (如千分位符, 空格等)
    // 允许负号 '-'、数字 '0-9' 和小数点 '.'
    final String cleanMoney = money.replaceAll(RegExp(r'[^\d\.\-]'), '');

    if (cleanMoney.isEmpty) {
      return 0;
    }

    // 2. 尝试将字符串解析为 double (元)
    final double? valueInCurrency = double.tryParse(cleanMoney);

    if (valueInCurrency == null) {
      return 0;
    }

    // 3. 转换为分（乘以 100）。
    // 使用 round() 是至关重要的，它避免了浮点数精度问题。
    // 例如：100.01 * 100 可能会是 10000.99999999999998，round() 确保它为 10001。
    final int valueInCents = (valueInCurrency * 100).round();

    return valueInCents;
  }

  static int parseInt(String? value) {
    return DataUtil.getInt(value);
  }

  static String formatMinutes(int totalMinutes) {
    if (totalMinutes <= 0) return '';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// 将多种类型的数字格式化为带逗号分隔的字符串
  /// [number]：支持 null、String、int、double 类型
  /// [decimalDigits]：保留的小数位数（默认 null，自动保留有效小数）
  /// [allowTrailingZeros]：是否保留小数末尾的 0（默认 false）
  /// 返回：格式化字符串，若无法解析则返回 "0"
  static String formatNumberWithComma(
    dynamic number, {
    int? decimalDigits,
    bool allowTrailingZeros = false,
  }) {
    // 1. 处理 null 情况
    if (number == null) {
      return "0";
    }

    // 2. 转换为 num 类型（处理 String、int、double）
    num? parsedNumber;
    if (number is num) {
      parsedNumber = number;
    } else if (number is String) {
      // 尝试解析字符串（支持整数、小数、负数）
      if (number.isEmpty) {
        return "0";
      }
      // 移除可能存在的逗号（避免已格式化的字符串重复加逗号）
      final cleaned = number.replaceAll(',', '');
      // 先尝试解析为 int，失败则尝试解析为 double
      parsedNumber = int.tryParse(cleaned) ?? double.tryParse(cleaned);
    }

    // 若解析失败，返回默认值 "0"
    if (parsedNumber == null || parsedNumber.isNaN) {
      return "0";
    }

    // 3. 处理小数部分
    String numberStr;
    if (decimalDigits != null) {
      // 限制小数位数（四舍五入）
      final rounded = parsedNumber.toStringAsFixed(decimalDigits);
      if (!allowTrailingZeros) {
        // 移除小数末尾的0和多余的小数点
        numberStr = rounded.replaceAll(
          RegExp(r'(\.0*$)|(\.([0-9]*[1-9])0*$)'),
          r'$2',
        );
      } else {
        numberStr = rounded;
      }
    } else {
      // 自动保留有效小数（整数不显示小数点）
      if (parsedNumber is int || parsedNumber == parsedNumber.roundToDouble()) {
        numberStr = parsedNumber.toInt().toString();
      } else {
        numberStr = parsedNumber.toString();
        // 处理科学计数法
        if (numberStr.contains('e') || numberStr.contains('E')) {
          numberStr = parsedNumber
              .toStringAsFixed(10)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
        }
      }
    }

    // 4. 拆分整数和小数部分
    final parts = numberStr.split('.');
    final intPart = parts[0]; // 可能包含负号
    final decimalPart = parts.length > 1 ? ".${parts[1]}" : "";

    // 5. 处理整数部分的逗号分隔
    String formattedIntPart;
    if (intPart.startsWith('-')) {
      final absIntPart = intPart.substring(1);
      formattedIntPart = "-${_addCommaToPositiveInt(absIntPart)}";
    } else {
      formattedIntPart = _addCommaToPositiveInt(intPart);
    }

    // 6. 拼接结果
    return "$formattedIntPart$decimalPart";
  }

  /// 给正整数字符串添加逗号分隔
  static String _addCommaToPositiveInt(String positiveIntStr) {
    final length = positiveIntStr.length;
    if (length <= 3) return positiveIntStr;

    final sb = StringBuffer();
    final firstSegmentLength = length % 3 == 0 ? 3 : length % 3;

    sb.write(positiveIntStr.substring(0, firstSegmentLength));

    for (int i = firstSegmentLength; i < length; i += 3) {
      sb.write(",${positiveIntStr.substring(i, min(i + 3, length))}");
    }

    return sb.toString();
  }

  static double formatDoubleWithRegex(double value) {
    String s = value.toString();
    // 匹配字符串末尾的 ".0"
    if (s.endsWith('.0')) {
      return double.parse(s.substring(0, s.length - 2));
    }
    return value;
  }

  static num sum(List<num> list) {
    return list.fold(0.0, (previous, current) => previous + current);
  }

  static bool numGte(dynamic a, int b) {
    if (a == null) {
      return false;
    } else if (a is num) {
      return a >= b;
    } else if (a is String) {
      try {
        return int.parse(a) >= b;
      } catch (e) {
        dprint('RecordSearchHelper._numGte failed: $a');
      }
    }
    return false;
  }

  static bool numLte(dynamic a, int b) {
    if (a == null) {
      return false;
    } else if (a is num) {
      return a <= b;
    } else if (a is String) {
      try {
        return int.parse(a) <= b;
      } catch (e) {
        dprint('RecordSearchHelper._numLte failed: $a');
      }
    }
    return false;
  }

  static int numCompare(dynamic a, dynamic b) {
    if (a == null || b == null) {
      return -1;
    }
    try {
      if (a is num) {
        if (b is num) {
          return a.compareTo(b);
        } else if (b is String) {
          return a.compareTo(int.parse(b));
        }
      }
      if (a is String) {
        if (b is num) {
          return int.parse(a).compareTo(b);
        } else if (b is String) {
          return int.parse(a).compareTo(int.parse(b));
        }
      }
    } catch (e) {
      dprint('RecordSearchHelper._numCompare failed: $a, $b');
    }
    return -1;
  }
}
