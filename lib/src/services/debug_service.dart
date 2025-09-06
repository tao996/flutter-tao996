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

  /// 设置需要记录的包名，注意：包名不需要添加 package:前缀
  void logPackages(List<String> packages, {bool append = true});
}

abstract class IDebugMessageService {
  dynamic success(String message);

  dynamic error(String message);
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

  String get color => _color.isNotEmpty ? _color : ColorUtil.random();

  @override
  IDebugService begin() {
    _color = ColorUtil.random();
    ColorUtil.print('[[[----------', _color);
    return this;
  }

  @override
  IDebugService end() {
    ColorUtil.print('----------]]]', _color);
    _color = '';
    return this;
  }

  void printCaller() {
    for (String line in getStackTraceString()) {
      if (inPackageLine(line)) {
        ColorUtil.print(line, color);
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
      ColorUtil.print('|== $object', color);
      if (args != null) {
        ColorUtil.print('|==|== $args', color);
      }
      printCaller();
    }
    return this;
  }

  void _printBlock(String tag, List<dynamic> items, {String? color}) {
    final pColor = color ?? ColorUtil.random();
    ColorUtil.print('$tag----------', pColor);
    for (final item in items) {
      ColorUtil.print(item, pColor);
    }
    ColorUtil.print('----------$tag', pColor);
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
      for (String line in getStackTraceString(stackTrace: stackTrace)) {
        if (inPackageLine(line)) {
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
        ColorUtil.print(args, color);
      }
    }
    return this;
  }

  List<String> getStackTraceString({StackTrace? stackTrace}) {
    StackTrace st = stackTrace ?? StackTrace.current;
    String stackTraceString = st.toString();
    return stackTraceString.split('\n');
  }

  @override
  IDebugService stack() {
    if (kDebugMode) {
      ColorUtil.print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', color);
      for (String line in getStackTraceString()) {
        if (inPackageLine(line)) {
          ColorUtil.print(line, color);
        }
      }
      ColorUtil.print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', color);
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
      ColorUtil.print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', color);
      StackTrace stackTrace = StackTrace.current;
      String stackTraceString = stackTrace.toString();
      List<String> stackTraceLines = stackTraceString.split('\n');

      for (String line in stackTraceLines) {
        if (inPackageLine(line)) {
          ColorUtil.print(line, color);
        }
      }
      for (var item in items) {
        for (var e in item) {
          ColorUtil.print(e.toString(), color);
        }
      }
      ColorUtil.print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', color);
    }
    return this;
  }

  final List<String> debugPackages = ['package:tao996'];

  bool inPackageLine(String line) {
    if (line.contains('debug_service.dart') ||
        line.contains('log_service.dart')) {
      return false;
    }
    for (String package in debugPackages) {
      if (line.contains(package)) {
        return true;
      }
    }
    return false;
  }

  @override
  void logPackages(List<String> packages, {bool append = true}) {
    if (append) {
      packages.forEach((package) {
        package = package.startsWith('package:') ? package : 'package:$package';
        if (!debugPackages.contains(package)) {
          debugPackages.add(package);
        }
      });
    } else {
      debugPackages.clear();
      debugPackages.addAll(
        packages
            .map(
              (package) =>
                  package.startsWith('package:') ? package : 'package:$package',
            )
            .toList(),
      );
    }
  }
}
