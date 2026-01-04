import 'package:flutter/foundation.dart';
import 'package:tao996/tao996.dart';

class StackUtil {
  /// 允许打印的包名
  static final List<String> debugPackages = ['package:tao996'];

  /// 检查是否在打印的包内
  static bool inPackageLine(String line) {
    if (line.contains('debug_service.dart') ||
        line.contains('log_service.dart') ||
        line.contains('stack_util.dart')) {
      return false;
    }
    for (String package in debugPackages) {
      if (line.contains(package)) {
        return true;
      }
    }
    return false;
  }

  /// 添加包名
  static void logPackages(List<String> packages, {bool append = true}) {
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

  /// 打印栈信息
  static void output({
    required String color,
    List<String>? filterNames,
    bool first = false,
  }) {
    if (kDebugMode) {
      for (String line in getStackTraceString()) {
        if (inPackageLine(line)) {
          if (filterNames != null &&
              filterNames.any((name) => line.contains(name))) {
            continue;
          }
          tu.colorMsg.print(line, color);
          if (first) {
            return;
          }
        }
      }
    }
  }

  static List<String> getStackTraceString({StackTrace? stackTrace}) {
    StackTrace st = stackTrace ?? StackTrace.current;
    String stackTraceString = st.toString();
    return stackTraceString.split('\n');
  }
}
