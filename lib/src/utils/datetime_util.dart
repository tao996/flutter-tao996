import 'package:intl/intl.dart';

import '../../tao996.dart';

enum DateTimeFormat { ymd, ymdHm, ymdHms }

class DatetimeUtil {
  static String getNowTime({String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).format(DateTime.now());
  }

  static String format({
    int timestamp = 0,
    DateTime? dateTime,
    DateTimeFormat format = DateTimeFormat.ymdHms,
  }) {
    if (dateTime == null && timestamp == 0) {
      return '';
    }
    dateTime ??= DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    int year = dateTime.year;

    int month = dateTime.month;
    String formattedMonth = month.toString().padLeft(2, '0');

    int day = dateTime.day;
    String formattedDay = day.toString().padLeft(2, '0');

    if (format == DateTimeFormat.ymd) {
      return '$year-$formattedMonth-$formattedDay';
    }
    int hour = dateTime.hour;
    String formattedHour = hour.toString().padLeft(2, '0');

    int minute = dateTime.minute;
    String formattedMinute = minute.toString().padLeft(2, '0');
    if (format == DateTimeFormat.ymdHm) {
      return '$year-$formattedMonth-$formattedDay $formattedHour:$formattedMinute';
    }
    int second = dateTime.second;
    String formattedSecond = second.toString().padLeft(2, '0');
    return '$year-$formattedMonth-$formattedDay $formattedHour:$formattedMinute:$formattedSecond';
  }

  static String formatYMD({int timestamp = 0, DateTime? dateTime}) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      format: DateTimeFormat.ymd,
    );
  }

  static String formatYMDHM({int timestamp = 0, DateTime? dateTime}) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      format: DateTimeFormat.ymdHm,
    );
  }

  static String formatYMDHMS({int timestamp = 0, DateTime? dateTime}) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      format: DateTimeFormat.ymdHms,
    );
  }

  /// 时间格式化 [format] 'yyyy年MM月dd日 HH:mm'
  static String formatWith(String format, DateTime datetime) {
    return DateFormat(format).format(datetime);
  }

  /// 日期解析
  /// [nowIfEmpty] 为空时返回当前时间
  /// [formatPattern] 时间格式，如果存在，则优先使用
  static DateTime? parse(
    dynamic dateStr, {
    bool nowIfEmpty = true,
    String? formatPattern,
  }) {
    if (dateStr == null) {
      return nowIfEmpty ? DateTime.now() : null;
    }
    final str = (dateStr as String).trim();
    if (str.isEmpty) {
      return nowIfEmpty ? DateTime.now() : null;
    }
    if (formatPattern != null && formatPattern.isNotEmpty) {
      try {
        return DateFormat(formatPattern).parse(str);
      } catch (_) {
        getIDebugService().d('format:[$formatPattern] 无法解析日期 [$str]');
      }
    }
    try {
      return DateTime.parse(str);
    } on FormatException catch (_) {
      /*
EEE: 解析星期几的缩写。
dd: 解析日期，两位数。
MMM: 解析月份的缩写。
yyyy: 解析年份，四位数。
HH: 解析小时，24小时制，两位数。
mm: 解析分钟，两位数。
ss: 解析秒，两位数。
Z: 解析时区偏移。intl 包的 DateFormat 能够识别 RFC 822 格式中的 +HHMM 或 -HHMM 时区偏移。
 */
      const dateFormatPatterns = [
        'EEE, dd MMM yyyy HH:mm:ss Z', // Thu, 22 May 2025 13:04:00 +0800
        'EEE, d MMM yyyy HH:mm:ss Z',
        'EEE, dd MMM yyyy HH:mm:ss',
        'EEE, d MMM yyyy HH:mm:ss',
        'yyyy-MM-dd HH:mm:ss Z',
      ]; // 可能有多种格式
      for (final pattern in dateFormatPatterns) {
        try {
          final format = DateFormat(pattern);
          final rst = format.parse(str);
          return rst;
        } catch (_) {
          // getIDebugService().pp('[日期解析失败]:[$str],模式:[$pattern],错误: $error');
        }
      }
    }

    getILogService().w('[日期解析失败]:[$str]');
    if (nowIfEmpty) {
      return DateTime.now();
    } else {
      return null;
    }
  }
}

extension DateTimeExt on DateTime {
  String formatYMD() {
    int year = this.year;
    int month = this.month;
    String formattedMonth = month.toString().padLeft(2, '0');

    int day = this.day;
    String formattedDay = day.toString().padLeft(2, '0');
    return '$year-$formattedMonth-$formattedDay';
  }
}
