import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../tao996.dart';

const isDebugMode = kDebugMode;

abstract class IDebugService {
  IDebugService begin();

  IDebugService end();

  IDebugService d(
    Object? object, {
    Object? args,
    bool? log,
    String? errorMessage,
    String? successMessage,
  });

  /// 捕获异常
  IDebugService exception(
    Object error,
    StackTrace stackTrace, {
    Object? args,
    bool log = true,
    String? errorMessage,
  });

  /// 打印当前的堆栈信息
  IDebugService stack();

  IDebugService printList(List<dynamic> items);

  IDebugService printLists(List<List<dynamic>> items);
}

abstract class IDebugMessageService {
  dynamic success(String message);
  dynamic error(String message);
  dynamic notice(String message);
  dynamic warning(String message);
}

class DebugService implements IDebugService {
  final ILogService logService;
  final IDebugMessageService messageService;
  bool filterLine = true;

  DebugService({IDebugMessageService? messageSer, ILogService? logSer})
    : messageService = messageSer ?? getIMessageService(),
      logService = logSer ?? getILogService();

  void _message(String? message, bool success, {bool? log}) {
    if (message == null || message.isEmpty) {
      return;
    }
    if (success) {
      messageService.success(message);
      if (log == true) {
        logService.i(message);
      }
    } else {
      messageService.error(message);
      if (log == true) {
        logService.e(message);
      }
    }
  }

  String _color = '';

  String get color =>
      _color.isNotEmpty ? _color : tu.colorMsg.randomConsoleColor();

  @override
  IDebugService begin() {
    _color = tu.colorMsg.randomConsoleColor();
    tu.colorMsg.print('[[[----------', _color);
    return this;
  }

  @override
  IDebugService end() {
    tu.colorMsg.print('----------]]]', _color);
    _color = '';
    return this;
  }

  void printCaller() {
    for (String line in StackUtil.getStackTraceString()) {
      if (StackUtil.inPackageLine(line)) {
        tu.colorMsg.print(line, color);
      }
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
    final hasColor = _color.isNotEmpty;
    if (!hasColor) {
      _color = tu.colorMsg.randomConsoleColor();
    }
    _message(errorMessage, false, log: log);
    _message(successMessage, true, log: log);
    if (log == true) {
      // 需要记录日志
      if (object != null) {
        logService.i(object.toString());
      }
      if (args != null) {
        logService.i(args.toString());
      }
    } else if (kDebugMode) {
      tu.colorMsg.print('|== $object', _color);
      if (args != null) {
        tu.colorMsg.print('|==|== $args', _color);
      }
      printCaller();
    }
    if (!hasColor) {
      _color = '';
    }
    return this;
  }

  void _printBlock(String tag, List<dynamic> items, {String? color}) {
    final pColor = color ?? tu.colorMsg.randomConsoleColor();
    tu.colorMsg.print('$tag----------', pColor);
    for (final item in items) {
      tu.colorMsg.print(item, pColor);
    }
    tu.colorMsg.print('----------$tag', pColor);
  }

  @override
  IDebugService exception(
    Object error,
    StackTrace stackTrace, {
    Object? args,
    bool log = true, // 是否需要记录日志
    String? errorMessage,
  }) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      _message(errorMessage, false, log: false);
    }

    if (log == true) {
      List<String> data = ['ERROR:$error', 'ARGUS:$args'];
      for (String line in StackUtil.getStackTraceString(
        stackTrace: stackTrace,
      )) {
        if (StackUtil.inPackageLine(line)) {
          data.add(line);
        }
      }
      logService.e(data);
    } else if (kDebugMode) {
      _printBlock('(((', [
        error.toString(),
        stackTrace.toString(),
      ], color: color);
      if (args != null) {
        tu.colorMsg.print(args, color);
      }
    }
    return this;
  }

  @override
  IDebugService stack() {
    if (kDebugMode) {
      tu.colorMsg.print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', color);
      StackUtil.output(color: color);
      tu.colorMsg.print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', color);
    }
    return this;
  }

  @override
  IDebugService printList(List items) {
    if (kDebugMode) {
      _printBlock('<<<<<<', items, color: color);
    }
    return this;
  }

  @override
  IDebugService printLists(List<List> items) {
    if (kDebugMode) {
      tu.colorMsg.print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', color);
      StackTrace stackTrace = StackTrace.current;
      String stackTraceString = stackTrace.toString();
      List<String> stackTraceLines = stackTraceString.split('\n');

      for (String line in stackTraceLines) {
        if (StackUtil.inPackageLine(line)) {
          tu.colorMsg.print(line, color);
        }
      }
      for (var item in items) {
        for (var e in item) {
          tu.colorMsg.print(e.toString(), color);
        }
      }
      tu.colorMsg.print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', color);
    }
    return this;
  }
}
