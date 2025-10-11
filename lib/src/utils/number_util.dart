import 'package:tao996/tao996.dart';

class NumberUtil {
  /// 将实际的金额（分，int）格式化成字符串（元，String）。
  /// 比如数据库中的 10001 分转换成 "100.01" 元。
  ///
  /// [num]: 存储的金额值，以“分”为单位（整数）。
  /// [fractionDigits]: 小数位数，通常为 2。
  /// [emptyText] 是否返回空字符串。如果为 true，则返回空字符串，否则返回 "0"。
  static String formatMoney(
    int? num, {
    int fractionDigits = 2,
    bool emptyText = true,
    bool trim = true,
  }) {
    if (num == 0 || num == null) {
      // 约定：如果金额为 0，返回 "0.00" 或 "0"
      return emptyText ? '' : 0.toStringAsFixed(fractionDigits);
    }

    // 1. 将整数（分）转为 double（元）
    final double valueInCurrency = num / (100); // 假设 fractionDigits 总是 2

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
}
