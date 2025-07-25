import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../tao996.dart';


const isDebugMode = kDebugMode;

abstract class IDebugService {
  IDebugService d(
    Object? object, {
    Object? args,
    bool? log,
    String? errorMessage,
    String? successMessage,
  });

  IDebugService dd(
    Object? object, {
    Object? args,
    bool begin = false,
    bool end = false,
  });

  IDebugService exception(
    Object error,
    StackTrace stackTrace, {
    bool? log,
    String? errorMessage,
  });

  IDebugService stack(dynamic object);

  IDebugService stackList(List<dynamic> items);

  IDebugService stackLists(List<List<dynamic>> items);
}

// 定义一些常用的颜色常量，方便使用
class ConsoleColor {
  static const String reset = '\x1B[0m'; // 重置/默认
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m'; // 红色
  static const String green = '\x1B[32m'; // 绿色
  static const String yellow = '\x1B[33m'; // 黄色
  static const String blue = '\x1B[34m'; // 蓝色
  static const String magenta = '\x1B[35m'; // 紫色/品红
  static const String cyan = '\x1B[36m'; // 青色
  static const String white = '\x1B[37m';

  // 背景色
  static const String bgBlack = '\x1B[40m';
  static const String bgRed = '\x1B[41m';
  static const String bgGreen = '\x1B[42m';
  static const String bgYellow = '\x1B[43m';
  static const String bgBlue = '\x1B[44m';
  static const String bgMagenta = '\x1B[45m';
  static const String bgCyan = '\x1B[46m';
  static const String bgWhite = '\x1B[47m';

  // 样式
  static const String bold = '\x1B[1m'; // 粗体/高亮
  static const String faint = '\x1B[2m';
  static const String italic = '\x1B[3m'; // 斜体
  static const String underline = '\x1B[4m'; // 下划线
}

class DebugService implements IDebugService {
  static const List<String> colors = [
    ConsoleColor.red,
    ConsoleColor.green,
    ConsoleColor.yellow,
    ConsoleColor.blue,
    ConsoleColor.magenta,
    ConsoleColor.cyan,
  ];

  void _message(String? message, bool success){
    if (message == null || message.isEmpty){
      return;
    }
    if (success) {
      messageService.success(message);
    } else {
      messageService.error(message);
    }
  }

  @override
  IDebugService d(
    Object? object, {
    Object? args,
    bool? log,
    String? errorMessage,
    String? successMessage,
  }) {
    _message(errorMessage, false);
    _message(successMessage, true);
    if (kDebugMode) {
      String color = _blockColor.isEmpty ? _randomColor() : _blockColor;
      final hasArgs = args != null;
      if (hasArgs) {
        printColored('|----------', color);
      }
      printColored(object.toString(), color);
      if (hasArgs) {
        printColored(args.toString(), color);
      }
      if (hasArgs) {
        printColored('----------|', color);
      }
    }
    return this;
  }

  final ILogService logService = getILogService();
  final IMessageService messageService = getIMessageService();

  String _randomColor() {
    return colors[Random().nextInt(6)];
  }

  String _blockColor = '';

  @override
  IDebugService dd(
    Object? object, {
    Object? args,
    bool begin = false,
    bool end = false,
  }) {
    if (kDebugMode) {
      String color = _blockColor.isEmpty ? _randomColor() : _blockColor;
      if (begin) {
        _blockColor = color;
        // printColored('(((--------------------', color);
      }
      printColored(object.toString(), color);
      if (args != null) {
        printColored(args.toString(), color);
      }

      if (end) {
        // printColored(')))', color);
        _blockColor = '';
      }
    }
    return this;
  }

  @override
  IDebugService exception(
    Object error,
    StackTrace stackTrace, {
    bool? log,
    String? errorMessage,
  }) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      messageService.error(errorMessage);
    }
    if (kDebugMode) {
      String color = _randomColor();
      printColored(stackTrace.toString(), color);
      stack(error);
    }
    return this;
  }

  @override
  IDebugService stack(object) {
    if (kDebugMode) {
      StackTrace stackTrace = StackTrace.current;
      String stackTraceString = stackTrace.toString();
      List<String> stackTraceLines = stackTraceString.split('\n');

      debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      for (String line in stackTraceLines) {
        if (!line.contains('debug_service.dart')) {
          debugPrint(line);
        }
      }
      debugPrint('~~~~');
      debugPrint(object.toString());
      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    }
    return this;
  }

  @override
  IDebugService stackList(List items) {
    if (kDebugMode) {
      StackTrace stackTrace = StackTrace.current;
      String stackTraceString = stackTrace.toString();
      List<String> stackTraceLines = stackTraceString.split('\n');

      for (String line in stackTraceLines) {
        if (!line.contains('debug_service.dart')) {
          debugPrint(line);
        }
      }
      debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      for (var item in items) {
        debugPrint(item.toString());
      }
      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    }
    return this;
  }

  @override
  IDebugService stackLists(List<List> items) {
    if (kDebugMode) {
      StackTrace stackTrace = StackTrace.current;
      String stackTraceString = stackTrace.toString();
      List<String> stackTraceLines = stackTraceString.split('\n');

      for (String line in stackTraceLines) {
        if (!line.contains('debug_service.dart')) {
          debugPrint(line);
        }
      }
      debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      for (var item in items) {
        for (var e in item) {
          debugPrint(e.toString());
        }
      }
      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    }
    return this;
  }

  // 封装成一个函数方便使用
  void printColored(
    String text,
    String colorCode, {
    String? bgColorCode,
    bool bold = false,
  }) {
    String prefix = colorCode;
    if (bgColorCode != null) {
      prefix += bgColorCode;
    }
    if (bold) {
      prefix += ConsoleColor.bold;
    }
    debugPrint('$prefix$text${ConsoleColor.reset}');
  }
}
