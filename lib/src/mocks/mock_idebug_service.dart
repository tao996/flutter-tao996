import 'package:tao996/tao996.dart';

class MockIDebugService implements IDebugService {
  void _message(String? message, bool success, {bool? log}) {
    if (message == null || message.isEmpty) {
      return;
    }
    if (success) {
      dprint(tu.colorMsg.success('打印成功信息: $message'));
    } else {
      dprint(tu.colorMsg.error('打印失败信息:$message'));
    }
  }

  String _color = '';

  String get color => _color.isNotEmpty ? _color : tu.colorMsg.random();

  @override
  IDebugService begin() {
    _color = tu.colorMsg.random();
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
    for (String line in getStackTraceString()) {
      if (inPackageLine(line)) {
        tu.colorMsg.print(line, color);
        break;
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

    printCaller();
    tu.colorMsg.print('|__\t\t $object', color);
    if (args != null) {
      tu.colorMsg.print('|__\t\t $args', color);
    }

    return this;
  }

  void _printBlock(String tag, List<dynamic> items, {String? color}) {
    final pColor = color ?? tu.colorMsg.random();
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

    _printBlock('(((', [error.toString(), stackTrace.toString()], color: color);
    if (args != null) {
      tu.colorMsg.print(args, color);
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
    tu.colorMsg.print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', color);
    for (String line in getStackTraceString()) {
      if (inPackageLine(line)) {
        tu.colorMsg.print(line, color);
      }
    }
    tu.colorMsg.print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', color);

    return this;
  }

  @override
  IDebugService printList(List items) {
    _printBlock('<<<<<<', items, color: color);

    return this;
  }

  @override
  IDebugService printLists(List<List> items) {
    tu.colorMsg.print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', color);
    StackTrace stackTrace = StackTrace.current;
    String stackTraceString = stackTrace.toString();
    List<String> stackTraceLines = stackTraceString.split('\n');

    for (String line in stackTraceLines) {
      if (inPackageLine(line)) {
        tu.colorMsg.print(line, color);
      }
    }
    for (var item in items) {
      for (var e in item) {
        tu.colorMsg.print(e.toString(), color);
      }
    }
    tu.colorMsg.print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', color);

    return this;
  }

  final List<String> debugPackages = [
    'package:tao996',
    'package:batch_command_tool',
  ];

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

  void logPackages(List<String> packages, {bool append = true}) {
    if (append) {
      for (var package in packages) {
        package = package.startsWith('package:') ? package : 'package:$package';
        if (!debugPackages.contains(package)) {
          debugPackages.add(package);
        }
      }
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
