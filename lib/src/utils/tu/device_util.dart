import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tao996/tao996.dart';

class DeviceUtil {
  const DeviceUtil();

  double get screenWidth => DeviceService.screenWidth;

  double get screenHeight => DeviceService.screenHeight;

  double get statusBarHeight => DeviceService.statusBarHeight;

  String get platform => DeviceService.platform();

  bool get isPc => DeviceService.isPc();

  bool get isMobile => DeviceService.isMobile();

  OS get runtimeOS => DeviceService.runtimeOS();

  /// has_command 检查的是外部可执行程序（.exe, .bat, .ps1），不是 shell 内置命令（比如 dir, ls, echo 等都不是可执行文件）
  /// 只有 curl, ping, notepad, powershell 才是可执行文件
  // /script = `where ` + cmd + ` >nul 2>&1 && exit 0 || exit 1`
  /// ✅ 使用 cmd /c，保证 >nul 语义正确
  /// ✅ PowerShell 安全写法：使用 $null + -ErrorAction
  ///	script = `powershell -c "try { Get-Command ` + cmd + ` -ErrorAction Stop | Out-Null; exit 0 } catch { exit 1 }"`
  bool hasCommand(String cmd) {
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

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<Directory> getTemporaryDirectory() async {
    return await getIPathService().getTemporaryDirectoryPath();
  }

  Future<Directory> getApplicationDocumentsDirectory() async {
    return await getIPathService().getApplicationDocumentsDirectoryPath();
  }

  Future<Directory> getApplicationSupportDirectory() async {
    return await getIPathService().getApplicationSupportDirectoryPath();
  }

  Future<Directory> getApplicationCacheDirectory() async {
    return await getIPathService().getApplicationCacheDirectoryPath();
  }

  Future<Directory?> getDownloadsDirectory() async {
    return await getIPathService().getDownloadsDirectoryPath();
  }

  /// 获取用户的家目录
  Future<String> homeDir() async {
    return await getIPathService().homeDir();
  }
}
