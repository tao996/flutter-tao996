import 'package:intl/intl.dart';

import '../../../tao996.dart';

// 正则表达式：匹配 YYYY-MM-DDTXX:XX:XX.XXX... 的格式
// ^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+$ 匹配了日期、T、时间、点和至少一位数字
final RegExp _iso8601Regex = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3,6}$',
);

class DatetimeUtil {
  const DatetimeUtil();

  /// 仅使用正则表达式检查字符串是否匹配 toIso8601String() 的格式。
  /// 注意：此方法不验证日期（如 2025-02-30）或时间（如 25:00:00）的有效性。
  bool isIso8601FormatRegex(dynamic input) {
    if (input == null || input is! String) {
      return false;
    }
    return _iso8601Regex.hasMatch(input);
  }

  String getNowTime({String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).format(DateTime.now());
  }

  String formatDate(DateTime datetime) {
    return format(dateTime: datetime, format: DateTimeFormat.ymd);
  }

  String format({
    int timestamp = 0,
    DateTime? dateTime,
    String? iso8601,
    DateTimeFormat format = DateTimeFormat.ymdHms,
  }) {
    if (dateTime == null &&
        timestamp == 0 &&
        (iso8601 == null || iso8601.isEmpty)) {
      return '';
    }
    if (iso8601 != null && iso8601.isNotEmpty) {
      dateTime = DateTime.parse(iso8601);
    } else {
      dateTime ??= DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    int year = dateTime.year;

    int month = dateTime.month;
    String formattedMonth = month.toString().padLeft(2, '0');

    int day = dateTime.day;
    String formattedDay = day.toString().padLeft(2, '0');
    if (format == DateTimeFormat.ym) {
      return '$year-$formattedMonth';
    } else if (format == DateTimeFormat.ymd) {
      return '$year-$formattedMonth-$formattedDay';
    } else if (format == DateTimeFormat.ymdFile) {
      return '$year$formattedMonth$formattedDay';
    }
    int hour = dateTime.hour;
    String formattedHour = hour.toString().padLeft(2, '0');

    int minute = dateTime.minute;
    String formattedMinute = minute.toString().padLeft(2, '0');
    if (format == DateTimeFormat.hm) {
      return '$formattedHour:$formattedMinute';
    } else if (format == DateTimeFormat.ymdHm) {
      return '$year-$formattedMonth-$formattedDay $formattedHour:$formattedMinute';
    } else if (format == DateTimeFormat.ymdHmFile) {
      return '$year$formattedMonth$formattedDay-$formattedHour$formattedMinute';
    }
    int second = dateTime.second;
    String formattedSecond = second.toString().padLeft(2, '0');
    if (format == DateTimeFormat.ymdHmsFile) {
      return '$year$formattedMonth$formattedDay-$formattedHour$formattedMinute$formattedSecond';
    }
    return '$year-$formattedMonth-$formattedDay $formattedHour:$formattedMinute:$formattedSecond';
  }

  String formatYM({int timestamp = 0, DateTime? dateTime, String? iso8601}) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      iso8601: iso8601,
      format: DateTimeFormat.ym,
    );
  }

  String formatYMD({int timestamp = 0, DateTime? dateTime, String? iso8601}) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      iso8601: iso8601,
      format: DateTimeFormat.ymd,
    );
  }

  String formatYMDHM({int timestamp = 0, DateTime? dateTime, String? iso8601}) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      iso8601: iso8601,
      format: DateTimeFormat.ymdHm,
    );
  }

  String formatYMDHMS({
    int timestamp = 0,
    DateTime? dateTime,
    String? iso8601,
  }) {
    return format(
      dateTime: dateTime,
      timestamp: timestamp,
      iso8601: iso8601,
      format: DateTimeFormat.ymdHms,
    );
  }

  /// 时间格式化 [format] 'yyyy年MM月dd日 HH:mm'
  String formatWith(String format, DateTime datetime) {
    return DateFormat(format).format(datetime);
  }

  /// 日期解析
  /// [nowIfEmpty] 为空时返回当前时间
  /// [formatPattern] 时间格式，如果存在，则优先使用
  DateTime? parse(
    dynamic dateStr, {
    bool nowIfEmpty = false,
    String? formatPattern,
  }) {
    if (dateStr == null || dateStr == '') {
      return nowIfEmpty ? DateTime.now() : null;
    }
    final str = dateStr.toString().trim();
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

  int compareTo(dynamic a, dynamic b) {
    if (a == null || a == '') {
      return -1;
    } else if (b == null || b == '') {
      return 1;
    }
    if (a is String && b is String) {
      final at = parse(a);
      final bt = parse(b);
      if (at == null || bt == null) {
        return 0;
      }
      return at.compareTo(bt);
    }
    if (a is DateTime && b is DateTime) {
      return a.compareTo(b);
    }
    return 0;
  }

  /// 获取时间戳
  /// [l10] 10 位的时间戳，用于 php 之类的；
  /// [l13] 13 位毫秒级时间戳（自 Unix 纪元（1970-01-01 00:00:00 UTC）以来的毫秒数）
  /// 默认为 16 位微秒级时间戳（自 Unix 纪元以来的微秒数，1毫秒=1000微秒）
  int timestamp(DateTime dt, {bool l10 = false, bool l13 = false}) {
    if (l10) {
      return dt.millisecondsSinceEpoch % 1000;
    } else if (l13) {
      return dt.millisecondsSinceEpoch;
    }
    return dt.microsecondsSinceEpoch;
  }

  // 格式化分钟数
  String formatMinutes(int totalMinutes) {
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
