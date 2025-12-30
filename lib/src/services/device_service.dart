import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tao996/src/helpers/kv.dart';
/// 内核/系统家族， 用于判断核心架构、API 兼容性和基本文件系统结构。这是跨发行版保持一致的底层属性。
/// 注意区分 发行版/OS 标识符
enum OS { unknown, windows, linux, unix, macos, android, ios, fuchsia }

class DeviceService {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double statusBarHeight = 0;

  static void calScreenSize(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; // Get.width
    screenHeight = MediaQuery.of(context).size.height; // Get.height
    statusBarHeight = MediaQuery.of(context).padding.top;
  }

  /// 获取平台（小写）
  /// https://github.com/jonataslaw/getx?tab=readme-ov-file#other-advanced-apis
  static String platform() {
    return defaultTargetPlatform.toString().toLowerCase();
    /*
GetPlatform.isAndroid
GetPlatform.isIOS
GetPlatform.isMacOS
GetPlatform.isWindows
GetPlatform.isLinux
GetPlatform.isFuchsia

//Check the device type
GetPlatform.isMobile
GetPlatform.isDesktop
//All platforms are supported independently in web!
//You can tell if you are running inside a browser
//on Windows, iOS, OSX, Android, etc.
GetPlatform.isWeb
     */
  }

  static bool isPc() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static OS runtimeOS() {
    if (Platform.isAndroid) {
      return OS.android;
    } else if (Platform.isIOS) {
      return OS.ios;
    } else if (Platform.isLinux) {
      return OS.linux;
    } else if (Platform.isMacOS) {
      return OS.macos;
    } else if (Platform.isWindows) {
      return OS.windows;
    } else if (Platform.isFuchsia) {
      return OS.fuchsia;
    } else {
      return OS.unknown;
    }
  }

  /// has_command 检查的是外部可执行程序（.exe, .bat, .ps1），不是 shell 内置命令（比如 dir, ls, echo 等都不是可执行文件）
  /// 只有 curl, ping, notepad, powershell 才是可执行文件
  // /script = `where ` + cmd + ` >nul 2>&1 && exit 0 || exit 1`
  /// ✅ 使用 cmd /c，保证 >nul 语义正确
  /// ✅ PowerShell 安全写法：使用 $null + -ErrorAction
  ///	script = `powershell -c "try { Get-Command ` + cmd + ` -ErrorAction Stop | Out-Null; exit 0 } catch { exit 1 }"`
  static bool hasCommand(String cmd) {
    if (Platform.isWindows) {
      final pathEnv = Platform.environment['PATH'];
      if (pathEnv == null || pathEnv.isEmpty) return false;

      final exts = const ['.EXE', '.BAT', '.CMD', '.PS1', '.VBS'];
      final dirs = pathEnv
          .split(';')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty);

      for (final dir in dirs) {
        for (final ext in exts) {
          final fullPath = '$dir\\$cmd$ext';
          try {
            final stat = File(fullPath).statSync();
            if (stat.type == FileSystemEntityType.file) {
              return true;
            }
          } on FileSystemException {
            // file doesn't exist, or inaccessible — ignore
            continue;
          }
        }
      }
      return false;
    } else {
      // Prefer `which` (widely available), fallback to `command -v`
      final candidates = ['which', 'command'];
      for (final binary in candidates) {
        try {
          final result = Process.runSync(
            binary,
            [cmd],
            runInShell: false, // critical: no shell injection
            stdoutEncoding: utf8,
            stderrEncoding: utf8,
          );
          if (result.exitCode == 0 &&
              result.stdout is String &&
              result.stdout.trim().isNotEmpty) {
            // `which cmd` outputs full path → exists
            return true;
          }
        } on Exception {
          // binary not found (e.g., `which` missing on minimal Alpine) → try next
          continue;
        }
      }

      // Ultimate fallback: check PATH manually (like Go's exec.LookPath)
      final pathEnv = Platform.environment['PATH'];
      if (pathEnv == null) return false;

      final dirs = pathEnv
          .split(':')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty);
      for (final dir in dirs) {
        final fullPath = '$dir/$cmd';
        try {
          final stat = File(fullPath).statSync();
          if (stat.type == FileSystemEntityType.file) {
            return true;
          }
        } on FileSystemException {
          continue;
        }
      }

      return false;
    }
  }
}
